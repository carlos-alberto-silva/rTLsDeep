test_that("getTLS2D returns a raster object", {
  lasfile <- system.file("extdata", "tree_c1.laz", package = "rTLsDeep")
  skip_if_not(file.exists(lasfile))
  las <- lidR::readLAS(lasfile)

  func <- ~list(Z = max(Z))
  gtree <- getTLS2D(las, res = 0.05, by = "xz", func = func, scale = TRUE)

  expect_s4_class(gtree, "SpatRaster")
  expect_true(nrow(gtree) > 0)
  expect_true(ncol(gtree) > 0)
})

test_that("getTLS2D works with different view orientations", {
  lasfile <- system.file("extdata", "tree_c1.laz", package = "rTLsDeep")
  skip_if_not(file.exists(lasfile))
  las <- lidR::readLAS(lasfile)

  func <- ~list(Z = max(Z))

  # xz view
  gtree_xz <- getTLS2D(las, res = 0.1, by = "xz", func = func, scale = TRUE)
  expect_s4_class(gtree_xz, "SpatRaster")

  # yz view
  gtree_yz <- getTLS2D(las, res = 0.1, by = "yz", func = func, scale = TRUE)
  expect_s4_class(gtree_yz, "SpatRaster")
})

test_that("getTLS2D handles scale parameter", {
  lasfile <- system.file("extdata", "tree_c1.laz", package = "rTLsDeep")
  skip_if_not(file.exists(lasfile))
  las <- lidR::readLAS(lasfile)

  func <- ~list(Z = max(Z))

  gtree_scaled <- getTLS2D(las, res = 0.1, by = "xz", func = func, scale = TRUE)
  gtree_unscaled <- getTLS2D(las, res = 0.1, by = "xz", func = func, scale = FALSE)

  expect_s4_class(gtree_scaled, "SpatRaster")
  expect_s4_class(gtree_unscaled, "SpatRaster")
})
