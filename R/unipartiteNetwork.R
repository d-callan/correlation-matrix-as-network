#' unipartiteNetwork
#' 
#' Create a unipartiteNetwork widget
#' 
#' @param data a data frame with source, target, and value columns
#' @param width the width of the widget
#' @param height the height of the widget
#' @param elementId the ID of the widget
#' @import htmlwidgets
#' @importFrom r2d3 html_dependencies_d3
#' @import dplyr
#' @export
unipartiteNetwork <- function(data, width = NULL, height = NULL, elementId = NULL) {
  if (!inherits(data, "data.frame") || !all(c("source", "target", "value") %in% names(data))) {
    stop("Data must be a data frame with source, target, and value columns.")
  }
  
  unique_sources <- unique(data$source)
  unique_targets <- unique(data$target)
  edge_data <- data %>% 
    filter(source %in% unique_sources & target %in% unique_targets) %>%
    distinct(source, target, .keep_all = TRUE)

  params <- list(data = list(links = edge_data, column1NodeIds = unique_sources, column2NodeIds = unique_targets))
  attr(params, 'TOJSON_ARGS') <- list(dataframe = 'rows')
  
  network <- htmlwidgets::createWidget(
    name = 'unipartitenetwork',
    x = params,
    width = width,
    height = height,
    package = 'corGraph',
    elementId = elementId,
    dependencies = r2d3::html_dependencies_d3(version = "5")
  )

  return(network)
}

#' Shiny bindings for unipartiteNetwork
#' 
#' Output function for using unipartiteNetwork within Shiny apps
#' 
#' @param outputId output variable to read from
#' @param width,height Must be a valid CSS unit (like \code{'100\%'}, '400px', or 'auto')
#' @export
unipartiteNetworkOutput <- function(outputId, width = '100%', height = '400px'){
  htmlwidgets::shinyWidgetOutput(outputId, 'unipartitenetwork', width, height, package = 'corGraph')
}

#' Shiny bindings for unipartiteNetwork
#' 
#' Render function for using unipartiteNetwork within Shiny apps
#' 
#' @param expr an expression that generates unipartiteNetwork
#' @param env the environment in which to evaluate \code{expr}
#' @param quoted Is \code{expr} a quoted expression (with \code{quote()})? This
#'   is useful if you want to save an expression in a variable
#' @export
renderUnipartiteNetwork <- function(expr, env = parent.frame(), quoted = FALSE) {
  if (!quoted) { expr <- substitute(expr) } 
  htmlwidgets::shinyRenderWidget(expr, unipartiteNetworkOutput, env, quoted = TRUE)
}
