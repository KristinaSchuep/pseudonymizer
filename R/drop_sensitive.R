# Task 4: Drop sensitive data --------------------------------

#' Drop sensitive data
#'
#' @param data Dataframe
#' @param sensitive Sensitive variables to drop. Default: c("ahvnr", "firstname", "surname", "birthday")
#'
#' @return Dataset from which indicated variables have been dropped.
#' @export
drop_sensitive <- function(data,
                           sensitive = c("ahvnr", "firstname", "surname", "birthday")){
  data <- data[, setdiff(colnames(data), sensitive)]
  return(data)
}
