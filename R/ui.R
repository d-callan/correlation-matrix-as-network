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
             shiny::fileInput("fileUpload", shiny::strong("Upload Data Table"), accept = c(".tab", "tsv",".rds")),
             shiny::fileInput("fileUpload2", shiny::strong("Upload Second Data Table (optional)"), accept = c(".tab", "tsv",".rds")),
             shiny::hr(),
             #div(style="display:inline-block",
              selectInput("correlationMethod", shiny::strong("Correlation Method:"),
                c("Spearman" = "spearman",
                  "Pearson" = "pearson")),
             #),
             # commenting this for now. after reading https://www.nature.com/articles/ismej2015235
             # i think i want to add more methods and maybe the ability to filter rare taxa prior to correlation
             #div(style="display:inline-block",
             # shinyWidgets::switchInput("dataAreCompositonal", "log transform", 
             #   value = FALSE,
             #   onLabel = "Yes",
             #   offLabel = "No",
             #   size = "normal",
             #   inline = TRUE,
             #   labelWidth = "100px")
             #),
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
                bipartiteNetworkOutput("bipartiteNetwork"), # need to add node labels and legend here
             ),
             tabPanel("Table",
               DT::DTOutput("correlationMatrix") 
             )
           )
    )
  )
)
