library(shiny)
library(ggplot2)
library(htmlwidgets)
library(DT)
library(shinyjs)

source('R/bipartiteNetworkWidget.R')

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

server <- function(input, output, session) {

  correlationMatrix <- eventReactive(input$fileUpload, {
    req(input$fileUpload)
    file <- input$fileUpload

    fileExtension <- tools::file_ext(file$name)

    tryCatch({
      if (fileExtension %in% c('tab','tsv')) {
        matrixData <- read.table(file$datapath, header = TRUE, sep = '\t')
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
    
    ggplot(data.frame(cor_values = corValues), aes(x = cor_values)) +
      geom_histogram(bins = 30, fill = 'steelblue') +
      labs(title = "Distribution of Correlation Coefficients", x = 'Correlation Coefficient', y = 'Frequency') +
      theme_minimal()
  })

  unfilteredPvalues <- reactive({
    correlationMatrix <- req(correlationMatrix())
    # todo fix this to take two data tables and find correlations and pvalues ourselves
    # this is a placeholder
    p_values <- abs(rnorm(length(correlationMatrix[lower.tri(correlationMatrix)]), .05, .5))*.0001
    return(p_values)
  })

  output$pValueHistogram <- renderPlot({
    pVals <- req(unfilteredPvalues())
    
    ggplot(data.frame(p_values = pVals), aes(x = p_values)) +
      geom_histogram(bins = 30, fill = 'steelblue') +
      labs(title = "Distribution of P-Values", x = 'P-Value', y = 'Frequency') +
      theme_minimal()
  })

  edgeList <- eventReactive({
    input$updateFilters
    correlationMatrix()
  }, {
    print("creating edge list")
    # todo maybe use lower.tri to remove dups?
    edge_list <- expand.grid(source = row.names(correlationMatrix()),
                             target = colnames(correlationMatrix()))
   
    edge_list <- subset(edge_list, as.character(edge_list$source) != as.character(edge_list$target))
    
    edge_list$value <- mapply(function(source, target) {
                                correlationMatrix()[source, target]
                              },
                              edge_list$source, edge_list$target)
    
    return(edge_list)
  })

  filteredEdgeList <- reactive({
    edgeList <- req(edgeList())
print(nrow(edgeList))
    edgeList <- subset(edgeList, abs(edgeList$value) >= input$correlationFilter)
    edgeList <- subset(edgeList, edgeList$value <= input$pValueFilter)
   print("filtered")
   print(nrow(edgeList))
    return(edgeList)
  })

  output$correlationMatrix <- renderDT({
    edgeList <- req(filteredEdgeList())
  })

  output$bipartiteNetwork <- renderBipartiteNetwork({
    edgeList <- req(filteredEdgeList())
    network <- bipartiteNetwork(edgeList, width = '100%', height = '400px')
    print(network)
    return(network)
  })

}
