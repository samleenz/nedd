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



#' getDrugScore
#'
#' given a vector of protein names return
#' the druggability scores as a vector
#'
#' @param v character vector of uniprot IDs
#'
#' @return vector of druggability scores, NA if the score is missing
#' @export
#'
#' @examples
getDrugScore <- function(v) {
  #checks
  if(! is.character(v)){
    stop("v must be a character vector")
  }

  # check if names are in drug table
  if(0 == sum(v %in% drug_score$name)) {
    warning("names are not in the drug score table, vector of NAs returned")
    return(rep(NA, length(v)))
  } else{
    message(paste(
      scales::percent(sum(v %in% drug_score$name) / length(v), accuracy = 3),
      "of input names are in the drug score table"
    ))
  }

  # join drug table and names
  suppressMessages(scores <- dplyr::left_join(tibble::tibble(name = v), drug_score))

  # return scores
  return(scores$druggability)

}

#' rankTable
#'
#' Given a data.frame with numerical scores return the rank table. Scores are
#' converted to ranks and then aggregated using \code{aggFUN}
#'
#' @param x a data.frame with numerical scores to be ranked
#' @param nameCol the column name containing row labels, or NULL if no labels.
#'   Default = NULL
#' @param aggFUN the function used to aggregate ranks, see details. Default =
#'   geometric mean
#' @param ties.method how tied ranks should be dealt with. See
#'   \code{\link[matrixStats]{colRanks}}
#'
#' @details If \code{nameCol} is used to specify a column this will be held
#'   aside when ranks are calculated then re-added before the rank table is
#'   returned
#'
#' @return a data.frame with the same shape as the input. Each column is
#'   trasformed to ranks (max value gets max rank) and then each row aggregated
#'   under \code{aggRank} using \code{aggFUN}
#' @export
#'
#' @examples
rankTable <- function(
  x, nameCol = NULL, aggFUN = geometricMean, ties.method = "min"){
  # check nameCol
  if(! (is.null(nameCol) || nameCol %in% colnames(x))){
  # if(! (nameCol %in% colnames(x) | is.null(nameCol))){
    stop("nameCol must be a column name of x or NULL")
  }
  # set aside name column
  if(! is.null(nameCol)){
    rowLabel <- x[[nameCol]]
    x <- x[, ! colnames(x) == nameCol]
  }

  # continue checks
  if(! all(apply(x, 2, is.numeric))){
    stop("All non-label rows of x must be numeric")
  }
  if(! is.function(aggFUN)){
    stop("aggFun must be a function")
  }

  # message(paste("Using", match.call(aggFUN)[2], "to aggregate ranks"))

  # main

  colLabel <- colnames(x)

  ## generate ranks
  x_rank <- matrixStats::colRanks(
    as.matrix(x),
    ties.method = ties.method,
    preserveShape = TRUE
    )

  colnames(x_rank) <- colLabel

  ## aggreagate ranks
  aggRank <- apply(
    x_rank,
    1,
    aggFUN
  )

  x_rank <- cbind(
    x_rank,
    aggRank = aggRank
  )

  if(! is.null(nameCol)){
    x_rank <- data.frame(
      rowLabel,
      x_rank,
      stringsAsFactors = FALSE
    )
    colnames(x_rank)[1] <- nameCol
  } else {
    x_rank <- as.data.frame(
      x_rank
    )
  }

  return(x_rank)

  }

#' geometricMean
#'
#' Calculate geometric mean. This is an internal for `rankTable` as such
#' there is no testing. it will break if `any(x < 1 | is.na(x))`
#'
#' @param x numeric vector where all `x > 0`
#'
#' @return
#'
geometricMean <- function(x){
  exp((mean(log(x))))
}
