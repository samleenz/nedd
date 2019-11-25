# netStats tests ----------------------------------------------------------
g <- igraph::barabasi.game(5, directed = FALSE)

test_that("g is a graph", {
  expect_error(
    netStats("cat", norm = FALSE),
    "g must be an igraph graph object"
  )
})

test_that("norm is a logical", {
  expect_error(
    netStats(g, "cat"),
    "norm must be a logical"
  )
})

test_that("Drug scores are NA if requested and missing", {
  input_na   <- c("goo", "foo", "bar", "cat", "dog")
  expect_equal(
    netStats(igraph::set_vertex_attr(g, "name", value = input_na))$drug_score,
    rep(NA, 5)
    )
})

test_that("Returned values are numeric", {
  expect_true(
    all(apply(
      netStats(g, named = FALSE),
      2,
      is.numeric
    ))
  )
})
