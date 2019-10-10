#measures betweenness of 3 graphs and saves to .json

rm(list = ls()) # Remove all the objects we created so far.

library(igraph) # Load the igraph package
library(RJSONIO) 

load(file = "../../../data/huri_graph.rda")
load(file = "../../../data/STRING_graph.rda")
load(file = "../../../data/ascher_graph.rda")


between2json <- function(graph,name){
  b  <- igraph::betweenness(graph, directed = FALSE)
  exportJson <- toJSON(b)
  write(exportJson,name)
}

between2json(ascher_graph,"ascher_rawBetween.json")
between2json(huri_graph,"huri_rawBetween.json")
between2json(STRING_graph,"STRING_rawBetween.json")