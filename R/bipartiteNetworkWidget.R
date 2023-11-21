library(htmlwidgets)
library(dplyr)
library(r2d3)

bipartiteNetwork <- function(data, width = NULL, height = NULL, elementId = NULL) {
  if (!inherits(data, "data.frame") || !all(c("source", "target", "value") %in% names(data))) {
    stop("Data must be a data frame with source, target, and value columns.")
  }
  unique_sources <- unique(data$source)
  unique_targets <- unique(data$target)
  edge_data <- data %>% 
    filter(source %in% unique_sources & target %in% unique_targets) %>%
    distinct(source, target, .keep_all = TRUE)

  htmlwidgets::createWidget(
    name = 'bipartitenetwork',
    x = list(data = edge_data),
    width = width,
    height = height,
    package = 'correlationMatrixAsNetwork',
    elementId = elementId,
    dependencies = r2d3::html_dependencies_d3(version = "5")
  )
}

bipartiteNetworkOutput <- function(outputId, width = '100%', height = '400px'){
  htmlwidgets::shinyWidgetOutput(outputId, 'bipartitenetwork', width, height, package = 'correlationMatrixAsNetwork')
}

renderBipartiteNetwork <- function(expr, env = parent.frame(), quoted = FALSE) {
  if (!quoted) { expr <- substitute(expr) } 
  htmlwidgets::shinyRenderWidget(expr, bipartiteNetworkOutput, env, quoted = TRUE)
}
