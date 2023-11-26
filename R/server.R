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
#' @importFrom stats rnorm
#' @import ggplot2
server <- function(input, output, session) {

  correlationMatrix <- eventReactive({
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

      corrData <- cor(data1, data2, use = 'na.or.complete')
      return(corrData)
    }, error = function(e) {
      shiny::showNotification(paste('Error:', e$message), type = 'error')
    })
    
    return(NULL)
  })
  
  unfilteredCorrelations <- reactive({
    correlationMatrix <- req(correlationMatrix())

    unfiltered_values <- as.vector(correlationMatrix[lower.tri(correlationMatrix)])
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
    correlationMatrix <- req(correlationMatrix())
    # todo fix this to take two data tables and find correlations and pvalues ourselves
    # this is a placeholder
    p_values <- abs(stats::rnorm(length(correlationMatrix[lower.tri(correlationMatrix)]), .05, .5))*.0001
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
    corrResult <- correlationMatrix()
    
    edge_list <- expand.grid(source = row.names(corrResult),
                             target = colnames(corrResult))
   
    deDupedEdges <- edge_list[as.vector(upper.tri(corrResult)),]
    edge_list <- cbind(deDupedEdges, corrResult[upper.tri(corrResult)])
    colnames(edge_list) <- c("source","target","value")
    
    return(edge_list)
  })

  filteredEdgeList <- reactive({
    edgeList <- req(edgeList())

    edgeList <- subset(edgeList, abs(edgeList$value) >= input$correlationFilter)
    edgeList <- subset(edgeList, edgeList$value <= input$pValueFilter)

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
