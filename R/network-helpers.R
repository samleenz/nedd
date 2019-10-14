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
#' @seealso \code{\link[igraph]{degree}}, \code{\link[igraph]{betweenness}},
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


#' colourGraphStat
#'
#' Given a graph
#'
#' @param g the igraph graph you want to analyse
#' @param nStatFunc a function that returns a node level statistic. Default is
#'   \code{\link[igraph]{degree}}
#' @param pal a palette function, should take an integer arguement and return
#'   a character vector of colours. See \code{\link[grDevices]{colorRamp}}
#' @param scale Whether to scale the output of the nStatFunc function
#'
#' @return a set of colour codes to be assigned to V(g)$colour
#' @export
#'
#' @examples
makeContCol <- function(
  g, nStatFunc = igraph::degree, pal =  grDevices::colorRampPalette(viridisLite::viridis(5)), scale = FALSE
){
  # take a graph as input
  # and a function for calculation a node statistic (default is degree)
  # optionally a colour pallete (5 col viridis default)
  ###
  # returns colours to be assigned to V(g)$color
  nStat <- nStatFunc(g)
  if(scale == TRUE){
    nStat <- scale(nStat)
  }

  cols <- stats::setNames(
    pal(length(unique(nStat))),
    sort(unique(as.numeric(nStat)))
  )

  return(cols[as.character(nStat)])
}


#' Get Subnetwork
#'
#' Given an igraph graph and a set of nodes, return the induced subgraph
#'   with self and multiple edges removed
#'
#' @param g an igraph graph object, with \code{$name} node attribute
#' @param v A character vector of node names
#'
#' @return An igraph object
#' @export
#'
#' @examples
getSubnet <- function(g, v){
  if(! igraph::is.igraph(g)){
    stop("g must be an igraph graph object")
  }

  if(! all(v %in% igraph::V(g)$name)){
    stop("Not all input nodes are in the graph")
  }

  g <- igraph::induced_subgraph(g, V(g)[V(g)$name %in% v]) %>%
    igraph::simplify()

  return(g)
}


#' Get largest connected subgraph
#'
#' Given an igraph, g, return the largest connected subgraph.
#'
#' @param g an igraph graph object
#' @param simplify_g whether to remove self / multiple edges before returning
#'   the graph, usually not neccessary.
#'
#' @return an igraph object
#' @export
#'
#' @examples
getLCS <- function(g, simplify_g = F){

  if(! igraph::is.igraph(g)){
    stop("g must be an igraph graph object")
  }
  if(igraph::is.directed(g)){
    stop("This function is only implemented for undirected graphs")
  }

  clust <- igraph::clusters(g)
  lcs <- igraph::V(g)[clust$membership == which.max(clust$csize)]
  lcs <- igraph::induced_subgraph(g, lcs)

  if(isTRUE(simplify_g)){
    return(
      igraph::simplify(lcs)
    )
  } else {
    return(
      lcs
    )
  }
}

#' v2e
#'
#' Vertex to edge: reloaded
#'
#' Transform a vertex-weighted undirected graph to an edge weighted graph
#'
#' @param g an igraph graph object
#' @param method See details ~~to write~~
#' @param w Numerical vector of vertex weights
#'
#' @return A vector of edge weights for the graph \code{g}
#' @export
#'
#' @examples
v2e <- function(g, method, w = NULL){
  if(is.null(w)){
    w <- igraph::V(g)$weight
  }
  # checks
  if(! igraph::is.igraph(g)){
    stop("g must be an igraph graph object")
  }
  ## w is length vcount(g)

  ## method is a valid option

  ## weights are numeric

  # ---

  # call internal method
  if(method == "vSum"){
    edge_weight <- .v2e_vSum(g, w)
  }


  return(edge_weight)
}

#' Sum vertex weights over edges
#'
#' internal for v2e.
#'
#' @param g graph
#' @param w vertex weights
#'
#' @return
#'
#' @examples
.v2e_vSum <- function(g, w){
  igraph::V(g)$w1 <- w

  e_pairs <- igraph::ends(g, igraph::E(g))

  e_weight <- apply(
    e_pairs,
    1,
    function(x) sum(igraph::vertex_attr(g, "w1", igraph::V(g)[x]))
  )

  return(e_weight)
}
