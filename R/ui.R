#' @importFrom shinyjs useShinyjs
#' @import shiny
#' @importFrom bslib bs_theme
#' @importFrom DT DTOutput
ui <- shiny::fluidPage(
  theme = bslib::bs_theme(),
  shiny::tags$head(
    shiny::tags$style(
      shiny::HTML(".shiny-notification { position:fixed; top: calc(20%); left: calc(50%); }")
    )
  ),
  shinyjs::useShinyjs(),
  shiny::titlePanel("Correlation Matrix as Network Visualization"),

  shiny::fluidRow(
    shiny::column(3, 
           shiny::wellPanel(
             shiny::fileInput("fileUpload", shiny::strong("Upload Correlation Matrix"), accept = c(".tab", ".rds")),
             shiny::hr(),
             shiny::numericInput("correlationFilter", shiny::strong("Correlation Coefficient Threshold:"), 0, min = -1, max = 1),
             shiny::plotOutput("correlationHistogram", height = "200px"),
             shiny::p(),
             shiny::numericInput("pValueFilter", shiny::strong("P-Value Threshold:"), 0, min = 0, max = 1),
             shiny::plotOutput("pValueHistogram", height = "200px"),
             shiny::p(),
             shiny::actionButton("updateFilters", "Update Filters"),
             shiny::hr(),
             shiny::tags$div(id = "legendPlaceholder", "Legend will be displayed here.")
           )
    ),
    shiny::column(9,
           tabsetPanel(
             type = "tabs",
             tabPanel("Network",
               bipartiteNetworkOutput("bipartiteNetwork")
             ),
             tabPanel("Table",
               DT::DTOutput("correlationMatrix") 
             )
           )
    )
  )
)
