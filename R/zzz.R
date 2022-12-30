.onAttach <- function(lib, pkg){
  info <- utils::packageDescription("rTLsDeep")
  if (is.null(info$Date)){info$Date= "2022-07-10 10:11:17 UTC"}
  base::packageStartupMessage(
    paste('\n##----------------------------------------------------------------##\n',
          'rTLsDeep package, version ', info$Version, ', Released ', info$Date, '\n',
          'This package is based upon work supported by the grants 2020-67030-30714\n',
          '##----------------------------------------------------------------##',
          sep="")
  )
}
