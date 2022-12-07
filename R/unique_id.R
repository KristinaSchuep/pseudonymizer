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
  # Check that id is of the expected format
  expect <- paste0("^[[:", id_expected_format, ":]]+$") # all characters are of expected format
  if(!all(grepl(expect, data[, id]))){
    ids <- data[, id]
    ids <- gsub(pattern = paste0("[^[:", id_expected_format, ":]]"), replacement = "", ids)
    data[, id] <- ids
  }

  # Check that id is of expected length
  expect <- paste0("[[:", id_expected_format, ":]]", "{", id_expected_length, "}")
  assertthat::assert_that(all(grepl(expect, data[, id])|is.na(data[, id])), msg = "The id-variable does not have the expected format and cannot be transformed automatically. Please transform the id-variable manually or change the expected format")

  # ID to character (necessary for hash function)
  data[, id] <- as.character(data[, id])

  # Pseudonymize id-variable
  data[, "pseudo_id"] <- openssl::sha256(x = data[, id], key = salt)

  return(data)
}


