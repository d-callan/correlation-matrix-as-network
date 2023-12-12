#' `mpg` city and highway miles per gallon
#'
#' A subset of the `mpg` dataset from the `ggplot2` package.
#' It contains only the `cty` and `hwy` variables.
#'
#' @format ## `mpg_cty_hwy`
#' A data frame with 234 rows and 2 columns:
#' \describe{
#'   \item{cty}{City miles per gallon}
#'   \item{hwy}{Highway miles per gallon}
#' }
#' @source <https://github.com/tidyverse/ggplot2>
"mpg_cty_hwy"


#' `mpg` year, cylinders, and displacement
#'
#' A subset of the `mpg` dataset from the `ggplot2` package.
#' It contains only the `year`, `cyl` and `displ` variables.
#'
#' @format ## `mpg_year_cyl`
#' A data frame with 234 rows and 3 columns:
#' \describe{
#'   \item{year}{Year of manufacture}
#'   \item{cyl}{Number of cylinders}
#'   \item{displ}{Displacement in litres}
#' }
#' @source <https://github.com/tidyverse/ggplot2>
"mpg_year_cyl"

#' `mpg` continuous variables
#'
#' A subset of the `mpg` dataset from the `ggplot2` package.
#' It contains only the integer and numeric variables.
#'
#' @format ## `mpg_all_cont`
#' A data frame with 234 rows and 5 columns:
#' \describe{
#'   \item{cty}{City miles per gallon}
#'   \item{hwy}{Highway miles per gallon}
#'   \item{year}{Year of manufacture}
#'   \item{cyl}{Number of cylinders}
#'   \item{displ}{Displacement in litres}
#' }
#' @source <https://github.com/tidyverse/ggplot2>
"mpg_all_cont"

#' BONUS-CF Relative Abundance of Species
#' 
#' Data from MicrobiomeDB.org, study BONUS-CF
#' 
#' @format ## `species`
#' A data frame with 1279 rows and 602 columns:
#' \describe{
#'   \item{Oscillibacter.sp..57_20..EUPATH_0009257_Bacteria_0.}{Relative Abundance of Oscillibacter sp. 57_20}
#'   ...
#' }
#' @source <https://microbiomedb.org>
"species"

#' BONUS-CF Pathway Abundance
#' 
#' Data from MicrobiomeDB.org, study BONUS-CF
#' 
#' @format ## `pathways`
#' A data frame with 1279 rows and 496 columns:
#' \describe{
#'   \item{X1CMET2.PWY..N10.formyl.tetrahydrofolate.biosynthesis..EUPATH_0009248_1CMET2_PWY.}{Abundance of pathway with BioCyc ID 1CMET2.PWY.}
#'   ...
#' }
#' @source <https://microbiomedb.org>
"pathways"