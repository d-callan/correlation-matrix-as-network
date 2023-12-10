#' corGraph Shiny App
#' 
#' Launches the corGraph Shiny App 
#'
#' @importFrom shiny shinyApp
#' @param ... arguments to pass to \code{shinyApp}
#' @export
corGraph <- function(...) {
  shiny::shinyApp(ui, server, ...)
}