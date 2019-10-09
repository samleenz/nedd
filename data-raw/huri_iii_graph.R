## code to prepare `huri_iii_graph` dataset goes here

huri <- readr::read_tsv("A:/SVI-HOLIEN/networks/baseNets/HuRI-Luck2019.tsv")

# not dropping any interactions (each has at least one screen for evidence)

# map ENSG to uniprot IDs
gprof <- gprofiler2::gconvert(union(huri$Ensembl_gene_id_a, huri$Ensembl_gene_id_b), target = "UNIPROTSWISSPROT") %>%
  dplyr::distinct(target, .keep_all = T)


huri$nodeA <- gprof$target[match(huri$Ensembl_gene_id_a, gprof$input)]
huri$nodeB <- gprof$target[match(huri$Ensembl_gene_id_b, gprof$input)]

# drop interactions (1473) that do not have both uniprot IDs
huri <- huri[! (is.na(huri$nodeA) | is.na(huri$nodeB)) , c("nodeA", "nodeB")]

huri_graph <- igraph::graph_from_data_frame(huri.uniprot, directed = F) %>%
  igraph::simplify()

# get largest connected subgraph ------------------------------------------

clust <- igraph::clusters(huri_graph)
vertex_lcs <- igraph::V(huri_graph)[clust$membership == which.max(clust$csize)]
huri_graph <- igraph::induced_subgraph(huri_graph, vertex_lcs)

usethis::use_data(huri_graph)
