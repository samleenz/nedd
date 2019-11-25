# z2o tests ---------------------------------------------------------------

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


# getDrugScore tests ------------------------------------------------------

test_that("Input is a character vector of length > 0", {
  input_good <- c("O75417", "O60749", "bar", "P45985", "P51610", "foo")
  input_bad <- list(2, TRUE, "cat", "genes")

  expect_error(
    getDrugScore(input_bad),
    "v must be a character vector"
  )

  expect_error(
    getDrugScore(c()),
    "v must be a character vector"
  )

  expect_error(
    getDrugScore(input_good),
    NA
  )
})
