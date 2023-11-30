readData <- function(file) {
  if (is.null(file)) {
    return(NULL)
  }

  fileExtension <- tools::file_ext(file$name)
  if (fileExtension %in% c('tab','tsv')) {
    matrixData <- utils::read.table(file$datapath, header = TRUE, sep = '\t')
  } else if (fileExtension == 'rds') {
    matrixData <- readRDS(file$datapath)
  } else {
    stop('Unsupported file type')
  }

  return(matrixData)
}

#' @importFrom DT renderDT
#' @importFrom utils read.table
#' @importFrom Hmisc rcorr
#' @importFrom data.table as.data.table
#' @importFrom data.table melt
#' @import ggplot2
server <- function(input, output, session) {
  correlationMatrix <- shiny::reactiveValues(corr_matrix = NULL)
  pValuesMatrix <- shiny::reactiveValues(p_values = NULL)

  shiny::observeEvent({
    input$fileUpload
    input$fileUpload2
  }, {
    file1 <- req(input$fileUpload)
    file2 <- input$fileUpload2

    tryCatch({
      data1 <- readData(file1)
      if (!is.null(file2)) {
        data2 <- readData(file2)
      }

      lastData1ColIndex <- length(data1)
      firstData2ColIndex <- length(data1) + 1
      corrResult <- Hmisc::rcorr(as.matrix(data1), as.matrix(data2))
      print(corrResult)
      # this bc Hmisc::rcorr cbinds the two data.tables and runs the correlation
      # so we need to extract only the relevant values
      pValuesMatrix$p_values <- corrResult$P[1:lastData1ColIndex, firstData2ColIndex:length(colnames(corrResult$P))]
      print(pValuesMatrix$p_values)
      correlationMatrix$corr_matrix <- corrResult$r[1:lastData1ColIndex, firstData2ColIndex:length(colnames(corrResult$r))]
      print(correlationMatrix$corr_matrix)
    }, error = function(e) {
      shiny::showNotification(paste('Error:', e$message), type = 'error')
    })
  })
  
  unfilteredCorrelations <- reactive({
    unfiltered_values <- as.vector(correlationMatrix$corr_matrix)

    # ill leave this in case i decide to support unipartite networks as well in the same app
    #unfiltered_values <- as.vector(correlationMatrix[lower.tri(correlationMatrix)])
    return(unfiltered_values)
  })

  output$correlationHistogram <- renderPlot({
    corValues <- req(unfilteredCorrelations())
    
    ggplot2::ggplot(data.frame(cor_values = corValues), ggplot2::aes(x = cor_values)) +
      ggplot2::geom_histogram(bins = 30, fill = 'steelblue') +
      ggplot2::labs(title = "Distribution of Correlation Coefficients", x = 'Correlation Coefficient', y = 'Frequency') +
      ggplot2::theme_minimal()
  })

  unfilteredPvalues <- reactive({
    p_values <- as.vector(pValuesMatrix$p_values)

    return(p_values)
  })

  output$pValueHistogram <- renderPlot({
    pVals <- req(unfilteredPvalues())
    
    ggplot2::ggplot(data.frame(p_values = pVals), ggplot2::aes(x = p_values)) +
      ggplot2::geom_histogram(bins = 30, fill = 'steelblue') +
      ggplot2::labs(title = "Distribution of P-Values", x = 'P-Value', y = 'Frequency') +
      ggplot2::theme_minimal()
  })

  edgeList <- reactive({
    corrResult <- data.table::as.data.table(req(correlationMatrix$corr_matrix), keep.rownames = TRUE)
    pVals <- data.table::as.data.table(req(pValuesMatrix$p_values), keep.rownames = TRUE)

    if (is.null(corrResult) || is.null(pVals)) {
      return(NULL)
    }

    meltedCorrResult <- data.table::melt(corrResult, id.vars=c('rn'))
    meltedPVals <- data.table::melt(pVals, id.vars=c('rn'))
    edge_list <- data.frame(
      source = meltedCorrResult[['rn']],
      target = meltedCorrResult[['variable']],
      value = meltedCorrResult[['value']],
      # should we do a merge just to be sure?
      p_value = meltedPVals[['value']]
    )

    # leave this in case i decide to support unipartite networks as well in the same app    
    #edge_list <- expand.grid(source = row.names(corrResult),
    #                         target = colnames(corrResult))
    #
    #deDupedEdges <- edge_list[as.vector(upper.tri(corrResult)),]
    #edge_list <- cbind(deDupedEdges, corrResult[upper.tri(corrResult)])
    #edge_list <- cbind(edge_list, pVals[upper.tri(pVals)])

    #colnames(edge_list) <- c("source","target","value","p_value")
    
    return(edge_list)
  })

  filteredEdgeList <- reactive({
    edgeList <- req(edgeList())

    edgeList <- subset(edgeList, abs(edgeList$value) >= input$correlationFilter)
    edgeList <- subset(edgeList, edgeList$p_value <= input$pValueFilter)

    return(edgeList)
  })

  output$correlationMatrix <- DT::renderDT({
    edgeList <- req(filteredEdgeList())
  })

  output$bipartiteNetwork <- renderBipartiteNetwork({
    edgeList <- req(filteredEdgeList())
    bipartiteNetwork(edgeList, width = '100%', height = '400px')
  })

}
