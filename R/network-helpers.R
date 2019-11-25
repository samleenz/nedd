#' Network statistics
#'
#' Given an \code{igraph} graph object return a table with vertex statistics.
#' If the graph is names (or `named` is `TRUE`) F-pocket druggability statistics
#' are returned too
#'
#' @param g the igraph graph you want to analyse
#' @param norm Whether to normalise the scores to between 0 and 1
#' @param named are graph vertices named? If true F-pocket drug score will be included
#'   in the table
#'
#' @return A data.frame with four or five columns: \code{c(degree, betweeness, closeness, eigen_centrality, maybe(drug_score))}.
#'   For details on what each of these represent see each of the respective \code{igraph} functions.
#' @export
#'
#' @seealso \code{\link[igraph]{degree}}, \code{\link[igraph]{betweenness}},
#'   \code{\link[igraph]{closeness}}, \code{\link[igraph]{eigen_centrality}}
#'
#' @examples
#' # a graph
#' grph <- igraph::barabasi.game(30, directed = FALSE)
#' igraph::V(grph)$name <- c(letters, LETTERS[1:4])
#' netStats(grph)
netStats <- function(g, norm = FALSE, named = NULL){
  # checks

  # check g is an igraph object
  if(! igraph::is.igraph(g)){
    stop("g must be an igraph graph object")
  }

  # check norm is logical
  if(! is.logical(norm)){
    stop("norm must be a logical (default false)")
  }

  # check whether vertex weights are NuLL or > 0
  if(! (is.null(igraph::E(g)$weight) | all(igraph::E(g)$weight > 0))) {
    stop("edge weights must be > 0 if supplied")
  }

  # set value of named
  if(is.null(named)){
    named <- ifelse(
      igraph::is_named(g),
      TRUE,
      FALSE
      )
  }

  # body
  tab <- data.frame(
    "degree" = igraph::degree(g, normalized = norm),
    "betweenness" = igraph::betweenness(g, normalized = norm),
    "closeness" = igraph::closeness(g, normalized = norm),
    "eigen_centrality" = igraph::eigen_centrality(g)$vector
  )

  if(isTRUE(named)){
    tab <- cbind(
      tab,
      "drug_score" = nedd::getDrugScore(igraph::V(g)$name)
    )
  }
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

  g <- igraph::induced_subgraph(g, igraph::V(g)[igraph::V(g)$name %in% v]) %>%
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
#' Transform a vertex-weighted undirected graph to an edge weighted graph.
#'
#' Different approaches to transform weights are:
#' \itemize{
#'   \item{\code{vSum} -- blah}
#'   \item{\code{vMax} -- blah}
#'   \item{\code{directed} -- blah}
#' }
#'
#'
#' @param g an igraph graph object
#' @param method Character, one of \{X,Y,Z\}
#' @param w Numerical vector of vertex weights
#'
#' @return the graph \code{g} with weighted edges
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
    # edge_weight <- .v2e_vSum(g, w)
    g_new <- .v2e_vSum(g, w)
  } else if(method == "vMax"){
    g_new <- .v2e_vMax(g, w)
  } else if(method == "directed"){
    g_new <- .v2e_directed(g, w)
  }


  return(g_new)
}

#' Sum vertex weights over edges
#'
#' internal for v2e. Takes a graph and vertex weights as input.
#' For each edge in the graph the weight is defined as the sum of the
#' weights of the two adjacent vertices
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

  igraph::E(g)$weight <- e_weight
  g <- igraph::remove.vertex.attribute(g, "w1")
  return(g)
}

#' max of vertex weights over edges
#'
#' internal for v2e. Takes a graph and vertex weights as input.
#' For each edge in the graph the weight is defined as the sum of the
#' weights of the two adjacent vertices
#'
#' @param g graph
#' @param w vertex weights
#'
#' @return
#'
#' @examples
.v2e_vMax <- function(g, w){
  igraph::V(g)$w1 <- w

  e_pairs <- igraph::ends(g, igraph::E(g))

  e_weight <- apply(
    e_pairs,
    1,
    function(x) max(igraph::vertex_attr(g, "w1", igraph::V(g)[x]))
  )

  igraph::E(g)$weight <- e_weight
  g <- igraph::remove.vertex.attribute(g, "w1")
  return(g)
}

#' Incoming directed weights
#'
#' internal for v2e. Takes a graph and vertex weights as input.
#' Each edge in the graph is replaced by mutual directed edges, that is:
#' the edge \code{A:-:B} becomes the edges \code{A:->:B} and \code{A:<-:B}
#' The weight of the vertex at the head of each edge then
#' becomes the edge weight.
#'
#' @param g graph
#' @param w vertex weights
#'
#' @return
#'
#' @examples
.v2e_directed <- function(g, w){
  igraph::V(g)$w1 <- w

  g <- igraph::as.directed(g, "mutual")

  # for each edge find the head vertex, then extract the weight
  e_weight <- igraph::vertex_attr(g, "w1", igraph::head_of(g, igraph::E(g)))

  igraph::E(g)$weight <- e_weight
  g <-  igraph::remove.vertex.attribute(g, "w1")
  return(g)
}
