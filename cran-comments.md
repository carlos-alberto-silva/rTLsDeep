# 29/03/2023 - Version 0.0.4 submission

This package has been described in this paper: Klauberg et al. (2023) <doi:10.3390/rs15041165>.

We've fixed some issues
  pointed by Benjamin Altmann.

1) Shorten title to at most 64 characters.
2) Better description details and citation to the above mentioned paper.
3) Remove prints and cats from functions.
4) Added explicit output_path parameter for setting where to save outputs instead of saving to the current directory.

# 29/03/2023 - Version 0.0.5 submission

1. Added cran-comments.md to .Rbuildignore

## R CMD check results

`R CMD check` for multiple platforms returns only one error if python env is not set, because we use tensorflow python wrappers from the tensorflow package. 

* This is a new package