# Task 1: Generate unique ID from AHV-number -------------------------

#' Generate unique ID from AHV-number
#'
#' @param data Dataframe
#' @param id ID-variable that needs to by pseudonymized
#' @param pseudo_id Pseudonymized ID-variable
#' @param salt Salt value
#' @param id_expected_format Expected format of ID-variable (Default: 'digit').
#' If the ID-variable does not have the expected format, the function will try to
#' convert it.
#' @param id_expected_length Expected length of ID-variable (Default: 13). If the
#' ID-variable does not have the expected length, the function will give an error.
#'
#' @return Dataframe with pseudo_id as additional variable. If id does not have
#' the expected format, the dataframe will contain the converted value.
#' @export
unique_id <- function(data,
                      id = "ahvnr",
                      pseudo_id,
                      salt,
                      id_expected_format = "digit",
                      id_expected_length = 13){

  # ID to character (necessary for hash function)
  data[, id] <- as.character(data[, id])
  ids <- data[, id]

  # Generate a variable with the format of the id
  # (this allows the researcher who receives the final pseudonymized data
  # to check whether there were any anomalies in the id)
  data[, "id_format"] <- gsub("(?<=.{3})[[:digit:]]", "9", ids, perl = TRUE)

  # Remove all strings that are not numeric or characters
  # AHV Number should be all numeric,
  # by keeping the characters, people with systematically deviating ahv numbers can be distinguished from each other

  ids <- gsub(pattern = "[^[:alnum:]]", replacement = "", ids)

  # Save this cleaned ahv-number
  data[, id] <- ids

  # # Check that id is of expected length
  # expect <- paste0("[[:", id_expected_format, ":]]", "{", id_expected_length, "}")
  # assertthat::assert_that(all(grepl(expect, ids)|is.na(ids)), msg = "The id-variable does not have the expected format and cannot be transformed automatically. Please transform the id-variable manually or change the expected format")

  # Pseudonymize id-variable
  data[, pseudo_id] <- openssl::sha256(x = ids, key = salt)

  #Save as character vector
  class(data[, pseudo_id]) <- "character"

  return(data)
}
