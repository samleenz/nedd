test_that("Inputs are of the correct type", {
  # do things
  expect_error(
    z2o("cat", incZero = TRUE),
    "x must be numeric"
    )
  expect_error(
    z2o(c(1,5,2), incZero = "cat"),
    "incZero must be a logical"
  )
})


test_that("Scaling is correct", {
  vec <- c(sample(1:50, 10))

  scaled <- z2o(vec)

  scaled_manual <- (vec-min(vec))/(max(vec)-min(vec))

  expect_equal(scaled, scaled_manual)
})
