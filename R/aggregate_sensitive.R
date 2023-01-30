# Task 2: Aggregate sensitive data -------------------------------

#' Aggregate sensitive data
#'
#' @param data data frame
#' @param date_var Date variable
#' @param date_old_format Format of old date variable
#' @param date_new_format Format for new date variable
#' @param date_new_var Name for new date variable
#' @param var_zip Variable for zip code
#'
#' @return datafile for which indicated variables have been aggregated
#' @export
aggregate_sensitive <- function(data,
                                date_var = "birthday",
                                date_old_format = "%Y-%m-%d",
                                date_new_format = "%Y",
                                date_new_var = "birthyear",
                                var_zip = "plz",
                                var_new_zip = "plz4"){
  # check if birthday variable is 8 (without centuries) or 10 digits

  data[, date_var] <- as.Date(data[, date_var], date_old_format, tz = "UTC")
  data[, date_new_var] <- as.numeric(format(data[, date_var], format = date_new_format))

  # Shorten 6 digit Zipcodes from Zurich (starts with 8) to 4 digits, by removing last two numbers

  index <- ifelse(nchar(data[, var_zip]) %in% 6 & grepl("^8", data[, var_zip]) ,TRUE,FALSE)

  # force overwrite NAs in index
  index <- index %in% TRUE

  data[index,var_new_zip] <- gsub('.{2}$', '', data[index, var_zip])

  # for all others just keep original zip code
  data[!index, var_new_zip] <- data[!index, var_zip]

  return(data)
}


