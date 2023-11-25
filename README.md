# corGraph
I recently found [gpt-pilot](https://github.com/Pythagora-io/gpt-pilot) and wanted a semi-complex project to give it a try with. I decided to port an app in development for [MicrobiomeDB](microbiomedb.org) to an R Shiny app.

## Someday, hopefully, this will be:
An R Shiny app to visualize a correlation matrix as a network. For the first implementation I'm anticipating trying to produce a bipartite network for displaying correlation matrices produced w two disparate data.frames.
A practical example, from the microbiome space, might be the correlations between various taxonomic abundance and pathway abundance. In this example, taxa would represent a column of nodes in the visualization and pathways a second,
and separate column of nodes. Links between these two columns of nodes are weighted by the absolute value of the correlation coefficient and colored by the direction of the correlation.

## Currently, this is:
An R Shiny app that uploads a file and attempts to validate it. It will produce a histogram of correlation coefficients, and a histogram of (for now, dummy) p-values. There are inputs to filter the edges of the network by correlation coefficient and p-value. Currently, the edges are visible in a network and a table.
Run what I currently have, after installing the package in R, like this: `corGraph::corGraph()`
Once the app has started, use the provided test file `inst/extdata/test_cor_matrix.tsv`.

## Some things I really need to do
Outside of playing w gpt-pilot, I think this is a cool app and want to do some housekeeping so that it can actually be destributed as a package. So I need to:
* clean up the test data/
* write some tests
* add a second file input
* run the correlation myself and produce real p-values
* add labels to the nodes in the network diagram
* make the network interactive so you get a scatter plot when you click an edge
