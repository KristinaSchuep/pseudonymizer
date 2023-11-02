# Task 2: Aggregate sensitive data -------------------------------

#' Aggregate sensitive data
#'
#' @param data data frame
#' @param date_var Date variable
#' @param date_old_format Format of old date variable
#' @param date_new_format Format for new date variable
#' @param date_new_var Name for new date variable
#'
#' @return datafile for which indicated variables have been aggregated
#' @export
aggregate_sensitive <- function(data,
                                date_var = "birthday",
                                date_old_format = "%Y-%m-%d",
                                date_new_format = "%Y",
                                date_new_var = "birthyear"){
  # check if birthday variable is 8 (without centuries) or 10 digits

  data[, date_var] <- as.Date(data[, date_var], date_old_format, tz = "UTC")

  data[, date_new_var] <- as.numeric(format(data[, date_var], format = date_new_format))

  return(data)
}


