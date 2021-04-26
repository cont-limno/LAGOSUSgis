test_that("query works", {
  expect_s3_class(
    query_gis("state"),
    "data.frame"
  )
})
