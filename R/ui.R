library(shiny)
library(shinyjs)
library(bslib)
library(DT)

ui <- fluidPage(
  theme = bs_theme(),
  tags$head(
    tags$style(
      HTML(".shiny-notification { position:fixed; top: calc(20%); left: calc(50%); }")
    )
  ),
  useShinyjs(),
  titlePanel("Correlation Matrix as Network Visualization"),

  fluidRow(
    column(3, 
           wellPanel(
             fileInput("fileUpload", strong("Upload Correlation Matrix"), accept = c(".tab", ".rds")),
             hr(),
             numericInput("correlationFilter", strong("Correlation Coefficient Threshold:"), 0, min = -1, max = 1),
             plotOutput("correlationHistogram", height = "200px"),
             p(),
             numericInput("pValueFilter", strong("P-Value Threshold:"), 0, min = 0, max = 1),
             plotOutput("pValueHistogram", height = "200px"),
             p(),
             actionButton("updateFilters", "Update Filters"),
             hr(),
             tags$div(id = "legendPlaceholder", "Legend will be displayed here.")
           )
    ),
    column(9,
           DTOutput("correlationMatrix"),
           bipartiteNetworkOutput("bipartiteNetwork")
    )
  )
)
