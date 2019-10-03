#' Filter scores
#'
#' Filter a set of scores (i.e. a 2 col dataframe) to remove scored
#' proteins that are not in our graph of interest.
#'
#' @param s A 2 column data-frame with \code{col_names = c("protein", "score")}
#' @param g An igrpah graph object
#'
#' @return A 2 column data-frame with \code{col_names = c("protein", "score")}.
#'   Where all proteins are present as nodes of \code{g}
#' @export
#'
#' @examples
filterScores <- function(s, g){

  # -- checks


  # --

  p <- igraph::V(g)$name
}
