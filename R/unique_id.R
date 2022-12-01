# Task 1: Generate unique ID from AHV-number -------------------------
# - the same AHV number always gives the same ID
# - no different AHV numbers lead to same ID
# - no possibility to infer AHV number from ID 

# Usage:
# unique_id(data = data, id = id, salt = "bla")

unique_id <- function(data, 
                      id, 
                      salt, 
                      expected_id_format = "digit", 
                      expected_id_length = 13){
  # Check that id is of the expected format
  expect <- paste0("^[[:", expected_id_format, ":]]+$") # all characters are of expected format
  if(!all(grepl(expect, data[, id]))){
    ids <- data[, id] 
    ids <- gsub(pattern = paste0("[^[:", expected_id_format, ":]]"), replacement = "", ids)
    data[, id] <- ids
  }
  
  # Check that id is of expected length
  expect <- paste0("[[:", expected_id_format, ":]]", "{", expected_id_length, "}")
  assertthat::assert_that(all(grepl(expect, data[, id])), msg = "The id-variable does not have the expected format and cannot be transformed automatically. Please transform the id-variable manually or change the expected format")
  
  # ID to character (necessary for hash function)
  data[, id] <- as.character(data[, id])
  
  # Pseudonymize id-variable
  data[, "pseudo_id"] <- openssl::sha256(x = data[, id], key = salt)
  
  return(data)
}


