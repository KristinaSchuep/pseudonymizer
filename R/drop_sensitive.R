# Task 4: Drop sensitive data --------------------------------

#' Drop sensitive data
#'
#' @param data Dataframe
#' @param drop Variables to drop. Default: c("ahvnr", "firstname", "surname", "birthday")
#' @param drop_add Additional variables to drop
#'
#' @return Dataset from which indicated variables have been dropped.
#' @export
drop_sensitive <- function(data,
                           drop = c("ahvnr", "firstname", "surname", "birthday"),
                           drop_add = NA){
  data <- data[, setdiff(colnames(data), c(drop, drop_add))]
  return(data)
}
