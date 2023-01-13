#' Aggregate sensitive data
#'
#' This function aggregates a date variable (e.g. date of birth to year of birth).
#'
#' @param data Dataframe
#' @param date_var Date variable(s)
#' @param date_old_format Format of old date variable(s)
#' @param date_new_format Format for new date variable(s)
#' @param date_new_var Name for new date variable(s)
#'
#' @return Original dataframe plus the new date variable(s)
#' @export
#' @examples
#' testdata <- cbind(testdata,
#'                   data.frame("other_date" = c("20.03.2000", "12.06.1998", "26.12.1989")))
#' aggregate_sensitive(data = testdata,
#'                     date_var = c("birthday", "other_date"),
#'                     date_old_format = c("%Y-%m-%d", "%d.%m.%Y"),
#'                     date_new_format = c("%Y", "%Y"),
#'                     date_new_var = c("birthyear", "otheryear"))
aggregate_sensitive <- function(data,
                                date_var = "birthday",
                                date_old_format = "%d.%m.%Y",
                                date_new_format = "%Y",
                                date_new_var = "birthyear"){
  if(length(date_var) == 1){
    # Simpler version with only one date_var:
    data[, date_var] <- as.Date(data[, date_var], date_old_format, tz = "UTC")
    data[, date_new_var] <- as.numeric(format(data[, date_var], format = date_new_format))
  } else {
    data[, date_var] <- mapply(as.Date, data[, date_var], format = date_old_format,
                               tz = rep(c("UTC"), length.out = length(date_var)),
                               SIMPLIFY = FALSE)
    data[, date_new_var] <- mapply(FUN = function(dat, format){
      as.numeric(format(dat, format = format))},
      dat = data[, date_var], format = date_new_format)
  }
  return(data)
}


