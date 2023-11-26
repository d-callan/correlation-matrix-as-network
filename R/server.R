validateCorrelationMatrix <- function(corMat) {
  return(inherits(corMat, 'matrix') &&
           all(row.names(corMat) == colnames(corMat)) &&
           all(apply(corMat, c(1, 2), is.numeric)) &&
           all(apply(corMat, c(1, 2), function(x) x >= -1 && x <= 1)))
}

addRowNames <- function(corMat) {
  if (all(row.names(corMat) != colnames(corMat))) {
    warning("No rownames found in correlation matrix. Will use column names for row names as well.")
    row.names(corMat) <- colnames(corMat)
  }

  return(corMat)
}

#' @importFrom DT renderDT
#' @importFrom utils read.table
#' @importFrom stats rnorm
#' @import ggplot2
server <- function(input, output, session) {

  correlationMatrix <- eventReactive(input$fileUpload, {
    req(input$fileUpload)
    file <- input$fileUpload

    fileExtension <- tools::file_ext(file$name)

    tryCatch({
      if (fileExtension %in% c('tab','tsv')) {
        matrixData <- utils::read.table(file$datapath, header = TRUE, sep = '\t')
      } else if (fileExtension == 'rds') {
        matrixData <- readRDS(file$datapath)
      } else {
        stop('Unsupported file type')
      }

      matrixData <- data.matrix(addRowNames(matrixData))
      if (validateCorrelationMatrix(matrixData)) {
        shiny::showNotification('Success: Valid correlation matrix uploaded', type = 'message')
        return(matrixData)
      } else {
        shiny::showNotification('The uploaded file is not a valid correlation matrix', type = 'error')
      }
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
