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
  data1 <- shiny::reactiveValues(matrix = NULL)
  data2 <- shiny::reactiveValues(matrix = NULL)
  correlationMatrix <- shiny::reactiveValues(corr_matrix = NULL)
  pValuesMatrix <- shiny::reactiveValues(p_values = NULL)
  upload_state <- reactiveValues(file1 = NULL, file2 = NULL)
  output$correlationNetwork <- shiny::renderUI({})
  outputOptions(output, "correlationNetwork", suspendWhenHidden = FALSE)

  output$file1 <- renderUI({
    input$resetData ## Create a dependency with the reset button
    shiny::fileInput("fileUpload", shiny::strong("Upload Data Table"), accept = c(".tab", "tsv",".rds"))
  })

  observeEvent(input$fileUpload, {
    upload_state$file1 <- 'uploaded'
  })

  output$file2 <- renderUI({
    input$resetData
    shiny::fileInput("fileUpload2", shiny::strong("Upload Second Data Table (optional)"), accept = c(".tab", "tsv",".rds"))
  })

  observeEvent(input$fileUpload2, {
    upload_state$file2 <- 'uploaded'
  })

  shiny::observeEvent(input$resetData, {
    print("Resetting data...")
    data1$matrix <- NULL
    data2$matrix <- NULL
    correlationMatrix$corr_matrix <- NULL
    pValuesMatrix$p_values <- NULL
    upload_state$file1 <- "reset"
    upload_state$file2 <- "reset"
  })

  listenForFileUPloads <- reactive({
    list(upload_state$file1, upload_state$file2)
  })

  shiny::observeEvent(listenForFileUPloads(), {
    if (is.null(input$fileUpload) && is.null(input$fileUpload2)) {
      return(NULL)
    }
    if (upload_state$file1 == 'reset' && upload_state$file2 == 'reset') {
      file1 <- NULL
      file2 <- NULL
    } else if (upload_state$file1 == 'uploaded' && (is.null(upload_state$file2) || upload_state$file2 == 'reset')) {
      file1 <- input$fileUpload
      file2 <- NULL
    } else if (upload_state$file2 == 'uploaded' && (is.null(upload_state$file1) || upload_state$file1 == 'reset')) {
      shiny::showNotification('Please upload the first file first.', type = 'error')
    } else {
      file1 <- input$fileUpload
      file2 <- input$fileUpload2
    }

    tryCatch({
      if (!is.null(file1)) {
        data1$matrix <- readData(file1)
        if (!is.null(file2)) {
          data2$matrix <- readData(file2)
        }
      }

    }, error = function(e) {
      shiny::showNotification(paste('Error:', e$message), type = 'error')
    })
  })
  
  shiny::observeEvent({
    data1$matrix
    data2$matrix
    input$correlationMethod
  }, {
    if (is.null(data1$matrix)) {
      return(NULL)
    }

    if (is.null(data2$matrix)) {
      corrResult <- Hmisc::rcorr(as.matrix(data1$matrix), type = input$correlationMethod)  
    } else {   
      corrResult <- Hmisc::rcorr(as.matrix(data1$matrix), as.matrix(data2$matrix), type = input$correlationMethod)    
    }    

    pValuesMatrix$p_values <- corrResult$P
    correlationMatrix$corr_matrix <- corrResult$r
  })

  output$correlationHistogram <- renderPlot({
    corValues <- req(edgeList()$value)
    
    ggplot2::ggplot(data.frame(cor_values = corValues), ggplot2::aes(x = cor_values)) +
      ggplot2::geom_histogram(bins = 30, fill = 'steelblue') +
      ggplot2::labs(title = "Distribution of Correlation Coefficients", x = 'Correlation Coefficient', y = 'Frequency') +
      ggplot2::theme_minimal()
  })

  output$pValueHistogram <- renderPlot({
    pVals <- req(edgeList()$p_value)
    
    ggplot2::ggplot(data.frame(p_values = pVals), ggplot2::aes(x = p_values)) +
      ggplot2::geom_histogram(bins = 30, fill = 'steelblue') +
      ggplot2::labs(title = "Distribution of P-Values", x = 'P-Value', y = 'Frequency') +
      ggplot2::theme_minimal()
  })

  edgeList <- eventReactive({
    correlationMatrix$corr_matrix
    pValuesMatrix$p_values
  },{
    if (is.null(correlationMatrix$corr_matrix) || is.null(pValuesMatrix$p_values)) {
      return(NULL)
    }

    if (is.null(data2$matrix)) {
      # deduplicate
      pVals <- pValuesMatrix$p_values
      corrResult <- correlationMatrix$corr_matrix

      edge_list <- expand.grid(source = row.names(corrResult),
                               target = colnames(corrResult))
    
      deDupedEdges <- edge_list[as.vector(upper.tri(corrResult)),]
      edge_list <- cbind(deDupedEdges, corrResult[upper.tri(corrResult)])
      edge_list <- cbind(edge_list, pVals[upper.tri(pVals)])

      colnames(edge_list) <- c("source","target","value","p_value")
    } else {
      lastData1ColIndex <- length(data1$matrix)
      firstData2ColIndex <- length(data1$matrix) + 1

      # this bc Hmisc::rcorr cbinds the two data.tables and runs the correlation
      # so we need to extract only the relevant values
      p_values <- pValuesMatrix$p_values[1:lastData1ColIndex, firstData2ColIndex:length(colnames(pValuesMatrix$p_values))]
      corr_matrix <- correlationMatrix$corr_matrix[1:lastData1ColIndex, firstData2ColIndex:length(colnames(correlationMatrix$corr_matrix))]

      corr_matrix <- data.table::as.data.table(corr_matrix, keep.rownames = TRUE)
      p_values <- data.table::as.data.table(p_values, keep.rownames = TRUE)

      if (is.null(corr_matrix) || is.null(p_values)) {
        return(NULL)
      }

      meltedCorrResult <- data.table::melt(corr_matrix, id.vars=c('rn'))
      meltedPVals <- data.table::melt(p_values, id.vars=c('rn'))
      edge_list <- data.frame(
        source = meltedCorrResult[['rn']],
        target = meltedCorrResult[['variable']],
        value = meltedCorrResult[['value']],
        # should we do a merge just to be sure?
        p_value = meltedPVals[['value']]
      )
    }

    return(edge_list)
  })

  filteredEdgeList <- reactive({
    edgeList <- req(edgeList())

    if (is.null(edgeList)) {
      return(NULL)
    }

    edgeList <- subset(edgeList, abs(edgeList$value) >= input$correlationFilter)
    edgeList <- subset(edgeList, edgeList$p_value <= input$pValueFilter)

    return(edgeList)
  })

  output$correlationMatrix <- DT::renderDT({
    edgeList <- req(filteredEdgeList())
    return(edgeList)
  })

  # eventually offer the option to show either bipartite or unipartite for any input data
  output$correlationNetwork <- renderUI({
    if (is.null(data1$matrix)) {
      return(NULL)
    } else {
      if (is.null(data2$matrix)) {
        unipartiteNetworkOutput("unipartiteNetwork")
      } else {
        bipartiteNetworkOutput("bipartiteNetwork")
      }
    }
  })

  output$unipartiteNetwork <- renderUnipartiteNetwork({
    edgeList <- req(filteredEdgeList())

    if (is.null(edgeList) || nrow(edgeList) == 0 || !is.null(data2$matrix)) {
      return(NULL)
    }

    network <- unipartiteNetwork(edgeList, width = '100%', height = '400px')
    return(network)
  })

  output$bipartiteNetwork <- renderBipartiteNetwork({
    edgeList <- req(filteredEdgeList())

    if (is.null(edgeList) || nrow(edgeList) == 0 || is.null(data2$matrix)) {
      return(NULL)
    }

    network <- bipartiteNetwork(edgeList, width = '100%', height = '400px')
    return(network)
  })

}
