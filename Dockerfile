FROM r-base:latest

WORKDIR /app

COPY . /app

RUN R -e "install.packages(c('bslib', 'data.table', 'dplyr', 'DT', 'ggplot2', 'Hmisc', 'htmlwidgets', 'r2d3', 'shiny', 'shinyjs', 'shinyWidgets'), repos='http://cran.rstudio.com/')"

EXPOSE 3838

ENV PORT 3838

CMD ["R", "-e", "shiny::runApp('/app/R')"]
