.onAttach <- function(lib, pkg){
  info <- utils::packageDescription("rTLsDeep")
  if (is.null(info$Date)){info$Date= "2022-07-10 10:11:17 UTC"}
  base::packageStartupMessage(
    paste('\n##----------------------------------------------------------------##\n',
          'rTLsDeep package, version ', info$Version, ', Released ', info$Date, '\n',
          'This package is based upon work supported by the XXX ',
          'XXX ',
          'grants No. XXX \n',
          '##----------------------------------------------------------------##',
          sep="")
  )
}
