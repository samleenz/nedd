#' Differential node weighting
#'
#' Set of differential network methods taken from O. Basha et al., Bioinformatics (2020).
#'
#' Takes two networks that differ only in  node weights (canonically log2 expression).
#' \code{diff_n} calculates the weight \code{n} of the output network as the difference between the weight in network one to that in network two.
#'  In the case of a multigroup comparison (classes > 2) the second network node weights should be the median of each class's weights.
#'
#' @param g1 a node weighted igraph network
#' @param g2 a node weighted igraph network
#' @param name1 deafult 'weight', the name of the node attribute to be used for g1
#' @param name2 deafult 'weight', the name of the node attribute to be used for g2
#' @param nameOut deafult 'weight', the name of the node attribute to be used for the otuput graph
#'
#' @return a network where the node weights reprsent the difference in node weights from the two input networks.
#' @export
#'
#' @examples
diff_n <- function(g1, g2, name1 = "weight", name2 = "weight", nameOut = "weight"){

  # test that nodes and edges of g1 and g2 are the same
  if(! igraph::identical_graphs(
    strip_attr(g1),
    strip_attr(g2)
  )) {
    stop("Input graphs must have the same nodes and edges")
  }

  n1 <- igraph::vertex_attr(g1, name1)
  n2 <- igraph::vertex_attr(g2, name2)

  # test that weights are numeric
  if(! is.numeric(c(n1, n2))){
    stop("Node weights must be numeric")
  }


  gOut <- g1
  nOut <- n1 - n2

  igraph::vertex_attr(gOut, nameOut) <- nOut

  return(gOut)

}


#' Preferential node weighting
#'
#' Set of differential network methods taken from O. Basha et al., Bioinformatics (2020).
#' \code{pref_n} calculate the preferential expression of a node as described by  A. R. Sonawane et al., Cell Reports. 21, 1077–1088 (2017).
#'
#' The preferential score of a node is effectively the differential node weighting divided by the IQR of the score in g2

#'
#' @param g1 a node weighted igraph network
#' @param g2 a node weighted igraph network
#' @param name1 deafult 'weight', the name of the node attribute to be used for g1
#' @param name2 deafult 'weight', the name of the node attribute to be used for g2
#' @param nameOut deafult 'weight', the name of the node attribute to be used for the otuput graph
#'
#' @return
#' @export
#'
#' @examples
pref_n <- function(g1, g2, name1 = "weight", name2 = "weight", nameOut = "weight"){

  # test that nodes and edges of g1 and g2 are the same
  if(! igraph::identical_graphs(
    strip_attr(g1),
    strip_attr(g2)
  )) {
    stop("Input graphs must have the same nodes and edges")
  }

  # get the diff_n score
  gDiff <- diff_n(g1, g2, name1 = name1, name2 = name2)

  gOut <- g1
  nOut <-  igraph::vertex_attr(gDiff, "weight") / IQR(igraph::vertex_attr(g2, name2))
  igraph::vertex_attr(gOut, nameOut) <- nOut

  return(gOut)
}


#' Preferntial edge weighting
#'
#' Set of differential network methods taken from O. Basha et al., Bioinformatics (2020).
#'
#' Computed as the sum of the preferential scores (pref_n's)of the interacting nodes.
#'
#' @param g1 a node weighted igraph network
#' @param g2 a node weighted igraph network
#' @param name1 deafult 'weight', the name of the node attribute to be used for g1
#' @param name2 deafult 'weight', the name of the node attribute to be used for g2
#' @param nameOut deafult 'weight', the name of the edge attribute to be used for the otuput graph
#'
#' @return
#' @export
#'
#' @examples
pref_i <- function(g1, g2, name1 = "weight", name2 = "weight", nameOut = "weight"){

  # test that nodes and edges of g1 and g2 are the same
  if(! igraph::identical_graphs(
    strip_attr(g1),
    strip_attr(g2)
  )) {
    stop("Input graphs must have the same nodes and edges")
  }

  # check that an edge attribute called `nameOut` doesn't already exist in g1
  if(nameOut %in% igraph::edge_attr_names(g1)){
    warning(paste(nameOut, "is already an edge attribute, overwriting..."))
  }

  # get the preferential node scores
  gPref <- pref_n(g1, g2, name1 = name1, name2 = name2)

  # create a 2col where entries are vertex scores for each end of each edge in the graph
  vertex_index <- ends(gPref, es = E(gPref))
  vertex_pref <- apply(vertex_index, 2, function(x) V(gPref)$weight[x])

  # get sum of vertex prefs per edge
  edge_pref <- apply(vertex_pref, 1, sum)

  gOut <- igraph::delete_vertex_attr(g1, name1)
  igraph::edge_attr(gOut, nameOut) <- edge_pref

  return(gOut)
}


#' Differential interaction weighting
#'
#' Set of differential network methods taken from O. Basha et al., Bioinformatics (2020).
#'
#' @param x
#'
#' @return
#' @export
#'
#' @examples
diff_i <- function(x){

}

#' Strip graph attributes
#'
#' removes all vertex and edge attributes from a graph.
#' internal function for prepping graphs to test if structures are the same
#'
#' @param g
#'
#' @return the graph g with al vertex attributes removed
#'
strip_attr <- function(g){

  gOut <- g
  for(name in igraph::vertex_attr_names(gOut)){
    message(paste("Removing", name, "from vertices"))
    gOut <- igraph::delete_vertex_attr(gOut, name)
  }

  for(name in igraph::edge_attr_names(gOut)){
    message(paste("Removing", name, "from edges"))
    gOut <- igraph::delete_edge_attr(gOut, name)
  }

  return(gOut)
}
