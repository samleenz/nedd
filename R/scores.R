#' Zero to One: range scaling
#'
#' Utility function: converts a numeric vector to the range [0,1] or (0,1)
#'
#' @param x Numeric vector to be scaled
#' @param incZero Logical: whether the bottom of the interval should be open or closed
#'
#' @return the rescaled vector x, the range will be [0,1] or (0,1) depending on the value of \code{incZero}
#' @export
#'
#' @examples
z2o <- function(x, incZero = TRUE){

  # check length > 0
  if(! length(x) > 0){
    stop("x must have length > 0")
  }

  # check if x is a numeric vector
  if(! is.numeric(x)){
    stop("x must be numeric")
  }

  # check incZero is logical

  if(! is.logical(incZero)){
    stop("incZero must be a logical")
  }


  if(! isTRUE(incZero)){
    x <- c(0, x)
  }

  # rearrange scale vector x from 0 to 1
  x_ret <- (x-min(x))/(max(x)-min(x))

  if(! isTRUE(incZero)){
    x_ret <- x_ret[-1]
  }

  return(x_ret)
}

#' Filter scores
#'
#' Filter a set of scores (i.e. a 2 col dataframe) to remove scored
#' proteins that are not in our graph of interest.
#'
#' @param s A 2 column data-frame with \code{col_names = c("protein", "score")}
#' @param g An igrpah graph object
#'
#' @return A 2 column data-frame with \code{col_names = c("protein", "score")}.
#'   Where all proteins are present as nodes of \code{g}
#' @export
#'
#' @examples
filterScores <- function(s, g){

  # -- checks


  # --

  p <- igraph::V(g)$name
}
