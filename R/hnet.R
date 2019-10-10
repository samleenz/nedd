#' Hnet Prepare
#'
#' Prepare a PPI graph for use with Hierarchical Hotnet
#'
#' @param g The PPI graph to be used, as an igraph object
#' @param out_dir where to save the graph files, default is `getwd()`
#'
#' @return
#' @export
#'
#' @examples
hnet_prepare <- function(g, out_dir = getwd()){

  # checks
  if(! igraph::is.igraph(g)){
    stop("g must be an igraph graph object")
  }
  if(! dir.exists(out_dir)){
    stop("out_dir does not exist, please create it before running this function!")
  }

  # get graph name
  gname <- substitute(g)


  edge_list <- igraph::as_edgelist(g)

  graph_index <- edge_list %>%
    as.vector() %>%
    unique() %>%
    sort() %>%
    data.frame(name = ., index = 1:length(.))

  graph_index_vec <- stats::setNames(
    graph_index$index,
    graph_index$name
  )

  edge_list_index <- matrix(graph_index_vec[edge_list], ncol = 2)

  outname <- substitute(g)  %>%
    stringr::str_remove("_graph$") %>%
    paste0(".tsv")

  # Gene index
  readr::write_tsv(
    data.frame(graph_index[, 2:1]), # index and then name
    file.path(out_dir, paste("index_gene", outname, sep = "_")),
    col_names = F
  )

  # Indexed edge list
  readr::write_tsv(
    data.frame(edge_list_index),
    file.path(out_dir, paste("edge_list", outname, sep = "_")),
    col_names = F
  )

  message(paste("Graph files saved to", out_dir))

  return(NULL)


}


#' Hnet read results
#'
#' Read the results file from Hierarchical Hotnet
#'
#' @param file Path to the results file
#' @param first_clust Logical, whether to return the first (largest) cluster
#'  or all of them.
#'
#' @return If `first_clust == TRUE` then a vector containing the uniprot IDs of the largest cluster from the Hierarchical Hotnet
#'
#'   If `first_clust == FALSE` then a list containing a vector of uniprot IDs for each cluster returned in descending order of size
#' @export
#'
#' @examples
hnet_read_results <- function(file, first_clust = TRUE){
  # checks
  if(! file.exists(file)){
    stop("The input file does not exist!")
  }
  fle <- readr::read_lines(file, n_max = 7)
  if(! all(startsWith(fle, "#"))){ # check valid file type
    stop("Are you sure this file is a valid results file? First 7 lines don't look right")
  }

  # body
  fle <- readr::read_lines(file, skip = 7)
  if(isTRUE(first_clust)){
    return(sapply(fle, stringr::str_split, pattern = "\\\t", USE.NAMES = FALSE)[[1]])
  } else {
    return(sapply(fle, stringr::str_split, pattern = "\\\t", USE.NAMES = FALSE))
  }
}
