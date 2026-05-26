test_that("get_validation_classes returns character vector", {
  train_path <- system.file("extdata", "train", package = "rTLsDeep")
  skip_if_not(dir.exists(train_path))

  classes <- get_validation_classes(file_path = train_path)
  expect_true(is.character(classes))
  expect_true(length(classes) > 0)
})

test_that("get_validation_classes returns class names", {
  train_path <- system.file("extdata", "train", package = "rTLsDeep")
  skip_if_not(dir.exists(train_path))

  classes <- get_validation_classes(file_path = train_path)
  expect_true(is.character(classes))
  expect_true(all(grepl("^C[0-9]+$", classes)))
})

test_that("get_validation_classes with validation directory", {
  validation_path <- system.file("extdata", "validation", package = "rTLsDeep")
  skip_if_not(dir.exists(validation_path))

  classes <- get_validation_classes(file_path = validation_path)
  expect_true(is.character(classes))
  expect_true(length(classes) > 0)
})
