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

  filteredCorrelationMatrix <- eventReactive({
    input$updateFilters
    correlationMatrix()
  },{
    print("filtering correlation matrix")
    correlationMatrix <- req(correlationMatrix())

    filtered_values <- correlationMatrix[abs(correlationMatrix) >= input$correlationFilter]
    # todo implement this when we fix the pvalues issue
    #filtered_values <- filtered_values[ <= input$pValueFilter]
    return(filtered_values)
  })

  edgeList <- reactive({
    filteredCorrelationMatrix <- req(filteredCorrelationMatrix())
    
    print("creating edge list")
    edge_list <- expand.grid(source = row.names(filteredCorrelationMatrix),
                             target = colnames(filteredCorrelationMatrix))
    edge_list <- subset(edge_list, source != target)
    edge_list$value <- mapply(function(source, target) {
                                filteredCorrelationMatrix[source, target]
                              },
                              edge_list$source, edge_list$target)

    print(edge_list)
    return(edge_list)
  })

  output$correlationMatrix <- renderText({
    edgeList <- req(edgeList())
    return(class(edgeList))
  })

  output$bipartiteNetwork <- renderBipartiteNetwork({
    #req(edgeList())
    network <- bipartiteNetwork(edgeList(), width = '100%', height = '400px')
    print(network)
    return(network)
  })

}
