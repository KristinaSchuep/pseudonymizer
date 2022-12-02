# Task 4: Drop sensitive data --------------------------------

#' Drop sensitive data
#'
#' @param data Dataframe
#' @param drop Variables to drop. Default: c("ahvnr", "firstname", "surname", "birthday")
#'
#' @return Dataset from which indicated variables have been dropped.
#' @export
drop_sensitive <- function(data,
                           drop = c("ahvnr", "firstname", "surname", "birthday")){
  data <- data[, setdiff(colnames(data), drop)]
  return(data)
}
