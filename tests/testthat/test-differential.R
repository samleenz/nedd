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
  igraph::vertex_attr(g1, "weight") <- sample(50, igraph::vcount(g))
  igraph::vertex_attr(g2, "weight") <- sample(50, igraph::vcount(g))

  gdiff <- nedd::diff_n(g1, g2)



  expect_equal((igraph::V(g1)$weight - igraph::V(g2)$weight), igraph::V(nedd::diff_n(g1, g2))$weight)
})

test_that("diff_i gives expected result", {
  g <- igraph::barabasi.game(15, directed = F)
  g1 <- g
  g2<- g
  igraph::edge_attr(g1, "weight") <- sample(50, igraph::ecount(g))
  igraph::edge_attr(g2, "weight") <- sample(50, igraph::ecount(g))

  gdiff <- nedd::diff_i(g1, g2)

  # manually calculate differential interaction score
  norm_1 <- igraph::edge_attr(g1, "weight") / max(igraph::edge_attr(g1, "weight"))
  norm_2 <- igraph::edge_attr(g2, "weight") / max(igraph::edge_attr(g2, "weight"))

  diff_i_manual <- norm_1 - norm_2


  expect_equal(diff_i_manual, igraph::E(nedd::diff_i(g1, g2))$weight)
})


test_that("Diff funcs all fail in presence of NAs",{
  g <- igraph::barabasi.game(15, directed = F)
  g1 <- g
  g2<- g
  igraph::vertex_attr(g1, "weight") <- sample(50, igraph::vcount(g))
  igraph::vertex_attr(g2, "weight") <- sample(50, igraph::vcount(g))
  igraph::edge_attr(g1, "weight") <- sample(50, igraph::ecount(g))
  igraph::edge_attr(g2, "weight") <- sample(50, igraph::ecount(g))

  # introduce NA
  igraph::vertex_attr(g1, "weight")[5] <- NA
  igraph::edge_attr(g1, "weight")[5] <- NA

  expect_error(nedd::diff_n(g1, g2), "Input weights cannot contain NAs")
  expect_error(nedd::diff_i(g1, g2), "Input weights cannot contain NAs")
  expect_error(nedd::pref_n(g1, g2), "Input weights cannot contain NAs")
  expect_error(nedd::pref_i(g1, g2), "Input weights cannot contain NAs")

})
