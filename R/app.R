#' corGraph Shiny App
#' 
#' Launches the corGraph Shiny App 
#'
#' @importFrom shiny shinyApp
#' @export
corGraph <- function(...) {
  shiny::shinyApp(ui, server, ...)
}