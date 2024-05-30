<!-- badges: start -->
  [![R-CMD-check](https://github.com/microbiomeDB/corGraph/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/microbiomeDB/corGraph/actions/workflows/R-CMD-check.yaml)
  <!-- badges: end -->

# corGraph

This package is home to some html widgets which build interactive correlation network diagrams. It also contains a Shiny app where you can upload 1-2 data tables, produce correlation coefficients and p-values and then visualize the results with the custom widgets.

The widgets are designed to re-create the diagrams from the MicrobiomeDB.org correlation apps. They are built in d3 and are admittedly a bit of a work-in-progress currently. If you would like to use them with microbiome (or similar) data in R, see our [MicrobiomeDB](https://github.com/microbiomedb/MicrobiomeDB) package.


## Installation

Use the R package [remotes](https://cran.r-project.org/web/packages/remotes/index.html) to install corGraph. From the R command prompt:

```R
remotes::install_github('microbiomeDB/corGraph')
```

## Usage

After installing the package, you can launch the shiny app like this: 

```R
corGraph::corGraph() 
```

Once the app has started, use the provided test files in inst/extdata. If you would like to test the unipartite network, we recommend the file mpg-all-continuous.tsv. If you would like to test the bipartite network, we would recommend the files mpg-cty-hwy.tsv and mpg-year-cyl.tsv.


## Contributing

Pull requests are welcome and should be made to the **dev** branch.

For major changes, please open an issue first to discuss what you would like to change.

Please make sure to update tests as appropriate.


## License
[Apache 2.0](https://www.apache.org/licenses/LICENSE-2.0.txt)
