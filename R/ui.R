#' @importFrom shinyjs useShinyjs
#' @import shiny
#' @importFrom bslib bs_theme
#' @importFrom DT DTOutput
#' @importFrom shinyWidgets switchInput
ui <- shiny::fluidPage(
  theme = bslib::bs_theme(),
  shiny::tags$head(
    shiny::tags$style(
      shiny::HTML(".shiny-notification { position:fixed; top: calc(20%); left: calc(50%); }"),
      shiny::HTML("hr { margin-top: 10px; margin-bottom: 10px }")
    )
  ),
  shinyjs::useShinyjs(),
  shiny::titlePanel("Correlation Matrix as Network Visualization"),

  shiny::fluidRow(
    shiny::column(3, 
           shiny::wellPanel(
             uiOutput('file1'),
             uiOutput('file2'),
             shiny::actionButton("resetData", shiny::strong("Reset Data")),
             shiny::hr(),
              selectInput("correlationMethod", shiny::strong("Correlation Method:"),
                c("Spearman" = "spearman",
                  "Pearson" = "pearson")),
             shiny::p(),
             shiny::numericInput("correlationFilter", shiny::strong("Correlation Coefficient Threshold:"), 0, min = -1, max = 1),
             shiny::plotOutput("correlationHistogram", height = "200px"),
             shiny::p(),
             shiny::numericInput("pValueFilter", shiny::strong("P-Value Threshold:"), 0.05, min = 0, max = 1),
             shiny::plotOutput("pValueHistogram", height = "200px")
           )
    ),
    shiny::column(9,
           tabsetPanel(
             type = "tabs",
             tabPanel("Network",
                uiOutput("correlationNetwork")
             ),
             tabPanel("Table",
               DT::DTOutput("correlationMatrix") 
             )
           )
    )
  )
)
