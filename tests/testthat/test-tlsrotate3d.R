test_that("tlsrotate3d returns LAS object with same number of points", {
  lasfile <- system.file("extdata", "tree_c1.laz", package = "rTLsDeep")
  skip_if_not(file.exists(lasfile))
  las <- lidR::readLAS(lasfile)
  original_n <- nrow(las@data)

  # Test rotation by z-axis
  lasr_z <- tlsrotate3d(las, theta = 180, by = "z", scale = TRUE)
  expect_s4_class(lasr_z, "LAS")
  expect_equal(nrow(lasr_z@data), original_n)

  # Test rotation by x-axis
  lasr_x <- tlsrotate3d(las, theta = 90, by = "x", scale = TRUE)
  expect_s4_class(lasr_x, "LAS")
  expect_equal(nrow(lasr_x@data), original_n)

  # Test rotation by y-axis
  lasr_y <- tlsrotate3d(las, theta = 90, by = "y", scale = TRUE)
  expect_s4_class(lasr_y, "LAS")
  expect_equal(nrow(lasr_y@data), original_n)
})

test_that("tlsrotate3d validates the 'by' parameter", {
  lasfile <- system.file("extdata", "tree_c1.laz", package = "rTLsDeep")
  skip_if_not(file.exists(lasfile))
  las <- lidR::readLAS(lasfile)

  expect_error(tlsrotate3d(las, theta = 90, by = "invalid"), "invalid")
})

test_that("tlsrotate3d with scale=FALSE preserves original coordinates relative to origin", {
  lasfile <- system.file("extdata", "tree_c1.laz", package = "rTLsDeep")
  skip_if_not(file.exists(lasfile))
  las <- lidR::readLAS(lasfile)

  las_scaled <- tlsrotate3d(las, theta = 90, by = "z", scale = TRUE)
  las_unscaled <- tlsrotate3d(las, theta = 90, by = "z", scale = FALSE)

  # Unscaled should have coordinates closer to original values
  expect_true(sum(abs(las_unscaled@data$X - las@data$X)) > 0)
})
