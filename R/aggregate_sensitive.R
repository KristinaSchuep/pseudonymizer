# Task 2: Aggregate sensitive df -------------------------------

#' Aggregate sensitive df
#'
#' @param df dfframe
#' @param date_var Date variable
#' @param date_old_format Format of old date variable
#' @param date_new_format Format for new date variable
#' @param date_new_var Name for new date variable
#'
#' @return dffile for which indicated variables have been aggregated
#' @export
aggregate_sensitive <- function(df,
                                date_var = "birthday",
                                date_old_format = "%Y-%m-%d",
                                date_new_format = "%Y",
                                date_new_var = "birthyear",
                                zip_var = "plz",
                                zip_new_var = "plz4"){
  # check if birthday variable is 8 (without centuries) or 10 digits

  df[, date_var] <- as.Date(df[, date_var], date_old_format, tz = "UTC")
  df[, date_new_var] <- as.numeric(format(df[, date_var], format = date_new_format))

  # Shorten 6 digit Zipcodes from Zurich (starts with 8) to 4 digits, by removing last two numbers

  index <- ifelse(nchar(df[, zip_var]) %in% 6 & grepl("^8", df[, zip_var]) ,TRUE,FALSE)

  # force overwrite NAs in index
  index <- index %in% TRUE

  df[index,zip_new_var] <- gsub('.{2}$', '', df[index, zip_var])

  # for all others just keep original zip code
  df[!index, zip_new_var] <- df[!index, zip_var]

  return(df)
}


