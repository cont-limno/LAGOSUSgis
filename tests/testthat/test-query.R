test_that("query works", {

  expect_s3_class(
    query_gis("state"),
    "data.frame"
  )
})

test_that("query works with id info", {
  expect_s3_class(
    query_gis("state", "state_name", "Michigan"),
    "data.frame"
  )
})

test_that("query works with extent info", {
  lake_coordinates <- query_gis("LAGOS_US_All_Lakes_1ha_points",
                                "lagoslakeid", "1")

  expect_s3_class(
    query_gis("LAGOS_US_All_Lakes_1ha",
              extent = sf::st_bbox(lake_coordinates)),
    "data.frame"
  )

  expect_s3_class(
    query_gis_(query = "SELECT * FROM LAGOS_US_All_Lakes_1ha",
               extent = sf::st_bbox(lake_coordinates)),
    "data.frame"
  )
})

