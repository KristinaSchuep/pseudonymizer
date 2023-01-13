#' Generate unique, pseudonymized ID
#'
#' This function generates a unique, pseudonymized identifier using SHA-256,
#' a vectorized hash function. Choose a random key ('salt') that is only known to
#' you for additional security.
#'
#' @param data Dataframe
#' @param id ID-variable that needs to by pseudonymized
#' @param salt Salt value
#' @param id_expected_format Expected pattern of ID-variable strings. If the ID-variable
#' does not have the expected pattern, the function will remove any characters that are
#' not of the expected format (Default = 'digit', i.e. letters, punctuation and spaces
#' will be removed from the original ID before applying the hash function).
#'
#' @return Dataframe with pseudo_id as additional variable. If id does not have
#' the expected format, the dataframe will contain the corrected value.
#' @export
#' @examples
#' unique_id(data = testdata, id = "ahvnr", salt = "myverygoodsalt")
unique_id <- function(data,
                      id = "ahvnr",
                      salt,
                      id_expected_format = "digit"){

  # ID to character (necessary for hash function)
  data[,id] <- as.character(data[, id])
  ids <- data[,id]

  # Remove all strings that are not of the expected format
  # (if id_expected_format is 'digit', this removes everything that is not a digit, i.e.
  # all letters, punctuation and spaces)
  ids <- gsub(pattern = paste0("[^[:", id_expected_format, ":]]"), replacement = "", ids)

  # Pseudonymize id-variable
  data[, "pseudo_id"] <- openssl::sha256(x = ids, key = salt)

  #Save as character vector
  class(data$pseudo_id) <- "character"

  # pseudo_id as first variable
  col_order <- c("pseudo_id", setdiff(colnames(data), c("pseudo_id")))
  data <- data[, col_order]

  return(data)
}
