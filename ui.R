library(shiny)
library(shinyjs)
library(bslib)

ui <- fluidPage(
  theme = bs_theme(),
  tags$head(
    tags$style(
      HTML(".shiny-notification {
               position:fixed;
               top: calc(20%);
               left: calc(50%);
             }"
      )
    )
  ),
  useShinyjs(), # Initialize shinyjs
  titlePanel("Correlation Matrix as Network Visualization"),

  fluidRow(
    column(3, 
           wellPanel(
             fileInput("fileUpload", "Upload Correlation Matrix", accept = c(".tab", ".rds")),
             hr(),
             numericInput("correlationFilter", "Correlation Coefficient Threshold:", 0, min = -1, max = 1),
             plotOutput("correlationHistogram"), # Add this line for the correlation histogram plot
             numericInput("pValueFilter", "P-Value Threshold:", 0, min = 0, max = 1),
             plotOutput("pValueHistogram"), # Adjust the placement of this line to be after the pValueFilter input
             actionButton("updateFilters", "Update Filters"),
             hr(),
             tags$div(id = "legendPlaceholder", "Legend will be displayed here.")
           )
    ),
    column(9,
           tags$div(id = "networkVisualizationPlaceholder", "Network Visualization will be displayed here.")
    )
  )
)