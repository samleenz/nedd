test_that("g is a graph", {
  expect_error(
    netStats("cat", norm = FALSE),
    "g must be an igraph graph object"
  )
})

test_that("norm is a logical", {
  expect_error(
    netStats(igraph::barabasi.game(5), "cat"),
    "norm must be a logical"
  )
})

