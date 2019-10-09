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
