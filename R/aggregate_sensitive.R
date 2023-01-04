# Task 2: Aggregate sensitive data -------------------------------

#' Aggregate sensitive data
#'
#' @param data Dataframe
#' @param date_var Date variable
#' @param date_old_format Format of old date variable
#' @param date_new_format Format for new date variable
#' @param date_new_var Name for new date variable
#'
#' @return Datafile for which indicated variables have been aggregated
#' @export
aggregate_sensitive <- function(data,
                                date_var = "birthday",
                                date_old_format = "%d.%m.%Y",
                                date_new_format = "%Y",
                                date_new_var = "birthyear",
                                zip_var = "plz",
                                zip_new_var = "plz4"){
  data[, date_var] <- as.Date(data[, date_var], date_old_format, tz = "UTC")
  data[, date_new_var] <- as.numeric(format(data[, date_var], format = date_new_format))
  data[, zip_new_var] <- gsub('.{2}$', '', data[, zip_var])
  return(data)
}


