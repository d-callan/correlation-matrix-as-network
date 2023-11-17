library(shiny)
library(ggplot2)
library(htmlwidgets)
library(DT)
library(shinyjs)

validateCorrelationMatrix <- function(corMat) {
  return(inherits(corMat, c('matrix','data.frame')) &&
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
  values <- reactiveValues(filteredMatrix = NULL)

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

      matrixData <- addRowNames(matrixData)
      if (validateCorrelationMatrix(matrixData)) {
        shiny::showNotification('Success: Valid correlation matrix uploaded', type = 'message')
        values$filteredMatrix <- matrixData
      } else {
        shiny::showNotification('The uploaded file is not a valid correlation matrix', type = 'error')
      }
    }, error = function(e) {
      shiny::showNotification(paste('Error:', e$message), type = 'error')
    })
  })

  observe({
    req(input$updateFilters)
    req(values$filteredMatrix)

    # Placeholder for filtering logic
    # values$filteredMatrix <- Your filtering logic here
  })

  output$pValueHistogram <- renderPlot({
    req(values$filteredMatrix)
    # Placeholder for histogram data extraction
    # p_values <- Your p-value extraction logic here

    ggp <- ggplot(data.frame(p_values), aes(x=p_values)) +
      geom_histogram(bins = 30, fill = 'blue') +
      labs(x = 'P-Value', y = 'Frequency') +
      theme_minimal()

    print(ggp)
  })
}
