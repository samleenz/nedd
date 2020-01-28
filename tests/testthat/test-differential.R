test_that("strip_attr works", {
  g <- igraph::barabasi.game(25, directed = F)
  g2 <- g

  igraph::vertex_attr(g2, "weight") <- sample(igraph::vcount(g2))
  igraph::edge_attr(g2, "weight") <- sample(igraph::ecount(g2))

  g2 <- nedd:::strip_attr(g2)

  expect_true(
    all(igraph::V(g) == igraph::V(g2)) & all(igraph::E(g) == igraph::E(g2))
  )

})

# test_that("Input graphs are isomorphic"){
#
# }
