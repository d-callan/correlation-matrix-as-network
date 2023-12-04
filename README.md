# corGraph
I recently found [gpt-pilot](https://github.com/Pythagora-io/gpt-pilot) and wanted a semi-complex project to give it a try with. I decided to port an app in development for [MicrobiomeDB](microbiomedb.org) to an R Shiny app. That was super fun, and I have no regrets, but it didn't last more than a few days. I think gpt-pilot managed to add a single file input, the correlation coefficient and p-value histograms and filter inputs... that was about it.

## Currently, this is:
An R Shiny app that uploads a file and generates a bunch of pairwise correlations with p-values. If an optional second file is provided it will find the pairwise correlations only between the data in the two files. It will produce a histogram of correlation coefficients, and a histogram of p-values. There are inputs to filter the edges of the network by correlation coefficient and p-value. Currently, the edges are visible in a network and a table. If you provided a single input file you will get a network diagram in the regular way. If you provide two input files you will get a bipartite network with two columns of rodes, where each column represents a file and each node a variable in the file.
Run what I currently have, after installing the package in R, like this: `corGraph::corGraph()`
Once the app has started, use the provided test files in `inst/extdata`. If you would like to test the unipartite network, I recommend the file `mpg-all-continuous.tsv`. If you would like to test the bipartite network, I would recommend the files `mpg-cty-hwy.tsv` and `mpg-year-cyl.tsv`.

## Some things I really need to do
Outside of playing w gpt-pilot, I think this is a cool app and want to do some housekeeping so that it can actually be distributed as a package. So I need to:
* fix bug where unipartite network doesnt show w single file upload unless you reset data
* research and add more correlation methods, or other association metrics
* write some tests
* make the network interactive so you get a scatter plot when you click an edge
* add a legend
* add tooltips to the bipartite network
* add colored links and labels to the unipartite network
* consider setting the nodes radius by degree
* make sure resizing works
* get some more interesting test data
