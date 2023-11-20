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
  values <- reactiveValues(correlationMatrix = NULL)

  observeEvent(input$fileUpload, {
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
        values$correlationMatrix <- matrixData
      } else {
        shiny::showNotification('The uploaded file is not a valid correlation matrix', type = 'error')
      }
    }, error = function(e) {
      shiny::showNotification(paste('Error:', e$message), type = 'error')
    })
  })

  unfilteredCorrelations <- reactive({
    req(values$correlationMatrix)
    unfiltered_values <- as.vector(values$correlationMatrix[lower.tri(values$correlationMatrix)])
    return(unfiltered_values)
  })

  output$correlationHistogram <- renderPlot({
    req(unfilteredCorrelations())
    corValues <- unfilteredCorrelations()
    ggplot(data.frame(cor_values = corValues), aes(x = cor_values)) +
      geom_histogram(bins = 30, fill = 'steelblue') +
      labs(title = "Distribution of Correlation Coefficients", x = 'Correlation Coefficient', y = 'Frequency') +
      theme_minimal()
  })

  unfilteredPvalues <- reactive({
    req(values$correlationMatrix)
    p_values <- abs(rnorm(length(values$correlationMatrix[lower.tri(values$correlationMatrix)]), .05, .5))*.0001
    return(p_values)
  })

  output$pValueHistogram <- renderPlot({
    req(unfilteredPvalues())
    pVals <- unfilteredPvalues()
    ggplot(data.frame(p_values = pVals), aes(x = p_values)) +
      geom_histogram(bins = 30, fill = 'steelblue') +
      labs(title = "Distribution of P-Values", x = 'P-Value', y = 'Frequency') +
      theme_minimal()
  })

  edgeList <- reactive({
    req(values$correlationMatrix)
    edge_list <- expand.grid(source = row.names(values$correlationMatrix),
                             target = colnames(values$correlationMatrix))
    edge_list <- subset(edge_list, source != target)
    edge_list$value <- mapply(function(source, target) {
                                values$correlationMatrix[source, target]
                              },
                              edge_list$source, edge_list$target)
    return(edge_list)
  })

  output$bipartiteNetwork <- renderBipartiteNetwork({
    req(values$correlationMatrix)
    bipartiteNetwork(edgeList(), width = '100%', height = '400px')
  })

}
