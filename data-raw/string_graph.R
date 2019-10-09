## code to prepare `string_graph` dataset goes here

library(tidyverse)
library(stringr)
library(igraph)
library(STRINGdb)
library(igraph)
library(UniProt.ws)

library(UniProt.ws)

# Get human STRING graph, scores > 400 only
STRdb <- STRINGdb::STRINGdb$new(
  version = "10",
  species = 9606,
  score_threshold = 400,
  input_directory = "A:/SVI-HOLIEN/networks/baseNets/"
)


STRING_graph <- STRdb$get_graph()


# Convert ensembl protein names to uniprot names
ens_prot <- igraph::vertex_attr(STRING_graph, "name") %>%
  stringr::str_remove("9606\\.")

# Convert ensembl protein id to uniprot id using gprofiler2
gprof <- gprofiler2::gconvert(ens_prot, target = "UNIPROTSWISSPROT") %>%
  dplyr::distinct(target, .keep_all = T)


# drop vertexes we could not rename
ver_keep <- igraph::vertex_attr(STRING_graph, "name")[ens_prot %in% gprof$input]
STRING_graph_uniprot <- igraph::induced_subgraph(STRING_graph, ver_keep) %>%
  igraph::set_vertex_attr("ensp", value = stringr::str_remove(ver_keep, "9606\\."))

# set name attribute
igraph::V(STRING_graph_uniprot)$name <- gprof$target[match(igraph::V(STRING_graph_uniprot)$ensp, gprof$input)]


# full STRING graph with UNIPROT labels
STRING_graph_uniprot <- igraph::delete_vertex_attr(STRING_graph_uniprot, "ensp")

# Change graph to edge type "experimental" only
# drop edges with experimental score < 400
d_edges <- igraph::edge_attr(STRING_graph_uniprot, "experiments") < 400
STRING_graph_uniprot <- igraph::delete_edges(STRING_graph_uniprot, igraph::E(STRING_graph_uniprot)[d_edges])


# remove self / multiple edges
# (this doesn't do anything as the graph is already simple.
#  more for consistency with other graphs :~) )
STRING_graph_uniprot <- igraph::simplify(STRING_graph_uniprot)

# get largest connected subgraph
clust <- igraph::clusters(STRING_graph_uniprot)
vertex_lcs <- igraph::V(STRING_graph_uniprot)[clust$membership == which.max(clust$csize)]
STRING_graph <- igraph::induced_subgraph(STRING_graph_uniprot, vertex_lcs)


# save the data object
usethis::use_data(STRING_graph)
