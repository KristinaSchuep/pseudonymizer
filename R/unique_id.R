# Task 1: Generate unique ID from AHV-number -------------------------

#' Generate unique ID from AHV-number
#'
#' @param data Dataframe
#' @param id ID-variable that needs to by pseudonymized
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
                      salt,
                      id_expected_format = "digit",
                      id_expected_length = 13){

  # ID to character (necessary for hash function)
  ids <- as.character(data[, id])

  # Generate a variable with the format of the id
  # (this allows the researcher who receives the final pseudonymized data
  # to check whether there were any anomalies in the id)
  data[, "id_format"] <- gsub('(?<=.{3})[[:digit:]]', 'x', ids, perl = TRUE)

  # Remove all strings that are not of the expected format
  # (if id_expected_format is 'digit', this removes everything that is not a digit, i.e.
  # all letters, punctuation and spaces)
  ids <- gsub(pattern = paste0("[^[:", id_expected_format, ":]]"), replacement = "", ids)

  # # Check that id is of expected length
  # expect <- paste0("[[:", id_expected_format, ":]]", "{", id_expected_length, "}")
  # assertthat::assert_that(all(grepl(expect, ids)|is.na(ids)), msg = "The id-variable does not have the expected format and cannot be transformed automatically. Please transform the id-variable manually or change the expected format")

  # Pseudonymize id-variable
  data[, "pseudo_id"] <- openssl::sha256(x = ids, key = salt)

  #Save as character vector
  class(data$pseudo_id) <- "character"

  return(data)
}

# Test ids
ids <- c('7560000000002', '7560000000002 ', 7560000000002, 7560000000002.00,
         7560000000002.01,
         '75600..000000.02', '7560000000a02')

ids <- c(7560000000002, 7560000000002.00, 7560000000002.01)
