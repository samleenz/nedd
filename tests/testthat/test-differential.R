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

test_that("diff_n gives expected result", {
  g <- igraph::barabasi.game(15, directed = F)
  g1 <- g
  g2<- g
  vertex_attr(g1, "weight") <- sample(50, vcount(g))
  vertex_attr(g2, "weight") <- sample(50, vcount(g))

  gdiff <- nedd::diff_n(g1, g2)



  expect_equal((V(g1)$weight - V(g2)$weight), V(nedd::diff_n(g1, g2))$weight)
})
