#'Plot confusion matrix
#'
#'@description This function plots the confusion matrix for classification assessement
#'
#'@usage gcmplot(cm,colors, title, prop)
#'
#'@param cm An confusion matrix object of class "confusionMatrix". Output of the [rTLsDeep::confmatrix_damage()] function.
#'@param colors A vector defining the low and high colors. Default is c(low="white", high="#009194").
#'@param title A character defining the title of the figure.
#'@param prop If TRUE percentage values will be plotted to the figure otherwise Freq.
#'
#'@return Returns an object of class gg and ggplot and plot of the confusion matrix.
#'
#'
#'@examples
#'
#'# Path to rds file
#'rdsfile <- system.file("extdata", "cm_vgg.rds", package="rTLsDeep")
#'
#'# Read RDS fo;e
#'cm_vgg<-readRDS(rdsfile)
#'
#'# Plot confusion matrix
#'gcmplot_vgg<-gcmplot(cm_vgg,
#'                     colors=c(low="white", high="#009194"),
#'                     title="densenet")
#'
#'@import ggplot2 ggplot
#'@export
#'
#'
gcmplot<-function(cm,colors=c(low="white", high="#009194"), title="cm", prop=TRUE){

  if ( prop==TRUE){
    rowsums = apply(cm$table, 1, sum)
    cm$table<-round(cm$table/rowsums,3)*100
  }
  plt <- as.data.frame(cm$table)
  plt$Prediction <- factor(plt$Prediction, levels=levels(plt$Prediction))
  plt$Reference <- factor(plt$Reference, levels=rev(levels(plt$Reference)))

  g<-ggplot2::ggplot(plt, ggplot2::aes(Prediction,Reference, fill= Freq)) +
    ggplot2::geom_tile() + ggplot2::geom_text(ggplot2::aes(label=Freq)) +
    #scale_fill_distiller(palette=pal, direction=1) +
    ggplot2::scale_fill_gradient(low=colors[1], high=colors[2])+
    #scale_fill_gradientn(colors=colors)+
    ggplot2::labs(x = "Reference",y = "Prediction") +
    ggplot2::scale_x_discrete(labels=paste0("C", levels(plt$Prediction))) +
    ggplot2::scale_y_discrete(labels=paste0("C", rev(levels(plt$Prediction)))) +
    ggplot2::ggtitle(title) + ggplot2::theme(plot.title = ggplot2::element_text(hjust = 0.5))


  if ( prop==TRUE){

    g<- g + ggplot2::labs(fill='Pct (%)')
  } else {

    g<- g + ggplot2::labs(fill='Freq (n)')

  }


  print(g)

  return(g)
}
