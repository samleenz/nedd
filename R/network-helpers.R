#' Network statistics
#'
#' Given an \code{igraph} graph object return a table with vertex statistics
#'
#' @param g the igraph graph you want to analyse
#' @param norm Whether to normalise the scores to between 0 and 1
#'
#' @return A data.frame with four columns: \code{c(degree, betweeness, closeness, eigen_centrality)}.
#'   For details on what each of these represent see each of the respective \code{igraph} functions.
#' @export
#'
#' @seealso \code{\link[igraph]{degree}}, \code{\link[igraph]{betweeness}},
#'   \code{\link[igraph]{closeness}}, \code{\link[igraph]{eigen_centrality}}
#'
#' @examples
#' # a graph
#' grph <- igraph::barabasi.game(30, directed = FALSE)
#' netStats(grph)
netStats <- function(g, norm = FALSE){
  # checks

  # check g is an igraph object
  if(! igraph::is.igraph(g)){
    stop("g must be an igraph graph object")
  }

  # check norm is logical
  if(! is.logical(norm)){
    stop("norm must be a logical (default false)")
  }

  # body
  tab <- data.frame(
    "degree" = igraph::degree(g, normalized = norm),
    "betweenness" = igraph::betweenness(g, normalized = norm),
    "closeness" = igraph::closeness(g, normalized = norm),
    "eigen_centrality" = igraph::eigen_centrality(g)$vector
  )

  return(tab)
}
