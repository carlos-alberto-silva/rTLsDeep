test_that("confmatrix_treedamage returns confusionMatrix object", {
  predict_class <- c("C1", "C1", "C2", "C2", "C1", "C2")
  test_classes <- c("C1", "C2", "C2", "C2", "C1", "C1")
  class_list <- c("C1", "C2")

  cm <- confmatrix_treedamage(
    predict_class = predict_class,
    test_classes = test_classes,
    class_list = class_list
  )

  expect_s3_class(cm, "confusionMatrix")
  expect_true(!is.null(cm$overall))
  expect_true(!is.null(cm$byClass))
})

test_that("confmatrix_treedamage handles single class", {
  skip("caret::confusionMatrix requires at least 2 factor levels in the data")
})

test_that("confmatrix_treedamage with perfect predictions gives accuracy 1", {
  predict_class <- c("C1", "C2", "C3")
  test_classes <- c("C1", "C2", "C3")
  class_list <- c("C1", "C2", "C3")

  cm <- confmatrix_treedamage(
    predict_class = predict_class,
    test_classes = test_classes,
    class_list = class_list
  )

  expect_equal(as.numeric(cm$overall["Accuracy"]), 1)
})
