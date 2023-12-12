
test_that("reactives and outputs update", {
  # todo try setting data1 and data2 directly from already loaded data?
  # the file reading doesnt seem to work in this context and idk why
  # something like:
  # data1$matrix <- utils::read.table("inst/extdata/mpg-cty-hwy.csv", header = TRUE, sep = '\t')
  # data2$matrix <- utils::read.table("inst/extdata/mpg-year-cyl.csv", header = TRUE, sep = '\t')
  # session$flushReact()
  shiny::testServer(server, {
    session$setInputs(fileUpload = "inst/extdata/mpg-cty-hwy.csv", 
                      fileUpload2 = "inst/extdata/mpg-year-cyl.csv", 
                      correlationMethod = "spearman",
                      correlationFilter = 0,
                      pValueFilter = 0.05)

    data1$matrix <- corGraph::mpg_cty_hwy
    data2$matrix <- corGraph::mpg_year_cyl
    session$flushReact()

    # trying to make sure we rendered some stuff
    output$pValueHistogram
    output$correlationHistogram
    output$correlationMatrix
    output$correlationNetwork
    output$bipartiteNetwork

    # checking reactiveValues have values
    expect_equal(upload_state$file1, 'uploaded')
    expect_equal(upload_state$file2, 'uploaded')
    expect_equal(is.null(data1$matrix), FALSE)
    expect_equal(is.null(data2$matrix), FALSE) 
    expect_equal(is.null(correlationMatrix$corr_matrix), FALSE)
    expect_equal(is.null(pValuesMatrix$p_values), FALSE)

    # checking edgeList
    expect_equal(class(edgeList()$value), "numeric")
    expect_equal(class(edgeList()$p_value), "numeric")
    expect_equal(class(edgeList()$source), "character")
    expect_equal(class(edgeList()$target), "factor")
    expect_equal(nrow(edgeList()) > 0, TRUE)
    expect_equal(all(edgeList()$source %in% colnames(data1$matrix)), TRUE)
    expect_equal(all(edgeList()$target %in% colnames(data2$matrix)), TRUE)
    expect_equal(any(edgeList()$target %in% colnames(data1$matrix)), FALSE)
    expect_equal(any(edgeList()$source %in% colnames(data2$matrix)), FALSE)

    # checking filteredEdgeList did work
    expect_equal(nrow(filteredEdgeList()) < nrow(edgeList()), TRUE)

    # reset data and check
    session$setInputs(resetData = TRUE,
                      correlationMethod = "spearman",
                      correlationFilter = 0,
                      pValueFilter = 0.05)
    session$flushReact()
    expect_equal(upload_state$file1, "reset")
    expect_equal(upload_state$file2, "reset")
    expect_equal(is.null(data1$matrix), TRUE)
    expect_equal(is.null(data2$matrix), TRUE)
    expect_equal(is.null(correlationMatrix$corr_matrix), TRUE)
    expect_equal(is.null(pValuesMatrix$p_values), TRUE)
    expect_error(edgeList())

    # upload single file this time
    session$setInputs(fileUpload = "inst/extdata/mpg-all-continuous.tsv",
                      fileUpload2 = NULL,
                      correlationMethod = "spearman",
                      correlationFilter = 0,
                      pValueFilter = 0.05)

    session$setInputs(resetData = TRUE)
    data1$matrix <- mpg_all_cont
    session$flushReact()

    expect_equal(is.null(data1$matrix), FALSE)
    expect_equal(is.null(data2$matrix), TRUE) 
    expect_equal(is.null(correlationMatrix$corr_matrix), FALSE)
    expect_equal(is.null(pValuesMatrix$p_values), FALSE)

    # checking edgeList
    expect_equal(class(edgeList()$value), "numeric")
    expect_equal(class(edgeList()$p_value), "numeric")
    expect_equal(class(edgeList()$source), "factor")
    expect_equal(class(edgeList()$target), "factor")
    expect_equal(nrow(edgeList()) > 0, TRUE)
    expect_equal(any(edgeList()$source %in% edgeList()$target), TRUE)

    # checking filteredEdgeList did work
    expect_equal(nrow(filteredEdgeList()) < nrow(edgeList()), TRUE)

    # check unipartiteNetwork
    output$correlationNetwork

  })
})