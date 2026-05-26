test_that("get_best_angle returns a numeric value between 0 and 360", {
  lasfile <- system.file("extdata", "tree_c1.laz", package = "rTLsDeep")
  skip_if_not(file.exists(lasfile))
  las <- lidR::readLAS(lasfile)

  angle <- get_best_angle(las)
  expect_true(is.numeric(angle))
  expect_true(angle >= 0 && angle < 360)
})

test_that("get_best_angle returns consistent results", {
  lasfile <- system.file("extdata", "tree_c1.laz", package = "rTLsDeep")
  skip_if_not(file.exists(lasfile))
  las <- lidR::readLAS(lasfile)

  angle1 <- get_best_angle(las)
  angle2 <- get_best_angle(las)

  expect_equal(angle1, angle2)
})
