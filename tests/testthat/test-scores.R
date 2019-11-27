# z2o tests ---------------------------------------------------------------

test_that("z2o inputs are of the correct type", {
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


# rankTable tests ---------------------------------------------------------

df <- data.frame(
  n = letters[1:11],
  x = c(sample(10), 11),
  y = c(sample(10), 11),
  z = c(sample(10), 11),
  stringsAsFactors = FALSE
)

test_that("rankTable inputs are of the correct type", {
  # do things
  expect_error(
    rankTable(df),
    "All non-label rows of x must be numeric"
  )
  expect_error(
    rankTable(df, 12),
    "nameCol must be a column name of x or NULL"
  )

})

test_that("rankTable with `prod` gives the expected answer", {
  rT <- rankTable(df, "n", aggFUN = prod)
  expect_equal(which.max(rT$aggRank), 11)
})
