# function to calculate confusion matrix between reference and prediction
confmatrix_treedamage = function(pred_df, class_list) {
  # pred_df is the output from the predict_treedamage function, the data frame with prediction and reference
  # class_list is an array of available classes e.g. c(1,2,3,5,6)

  # get reference classes
  ref = factor(pred_df$ref_class, levels = class_list)
  pred = factor(pred_df$predict_class, levels = class_list)

  # confusion matrix
  require(caret)
  cm = caret::confusionMatrix(pred, ref)
  print(cm)

  # return
  return(cm)
}
