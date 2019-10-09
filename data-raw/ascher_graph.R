## code to prepare `ascher_graph` dataset goes here

# load data file provided by Ascher lab (Baker Institute)
ascher <- readr::read_tsv("A:/SVI-HOLIEN/networks/baseNets/ascher-UniProtNormalizedTabular-highconfidenceinteractions.txt")

# create igraph object and drop self edges
ascher_graph <- igraph::graph_from_data_frame(ascher[,1:2], directed = F)
ascher_graph <- igraph::simplify(ascher_graph)

# get largest connected subgraph
clust <- igraph::clusters(ascher_graph)
vertex_lcs <- igraph::V(ascher_graph)[clust$membership == which.max(clust$csize)]
ascher_graph <- igraph::induced_subgraph(ascher_graph, vertex_lcs)


usethis::use_data(ascher_graph)
