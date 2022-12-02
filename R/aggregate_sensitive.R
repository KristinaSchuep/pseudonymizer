# Task 2: Aggregate sensitive data -------------------------------

#' Aggregate sensitive data
#'
#' @param data Dataframe
#' @param date_var Date variable
#' @param date_new_format Format for new date variable
#' @param date_new_var Name for new date variable
#'
#' @return Datafile for which indicated variables have been aggregated
#' @export
aggregate_sensitive <- function(data,
                                date_var = "birthday",
                                date_new_format = "%Y",
                                date_new_var = "birthyear"){
  date_var_ <- data[, date_var]
  date_var_ <- as.Date(date_var_)
  date_var_ <- as.numeric(format(date_var_, format = date_new_format))
  data[, date_new_var] <- date_var_
  return(data)
}

