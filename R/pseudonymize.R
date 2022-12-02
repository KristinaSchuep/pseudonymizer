# Task 6: Write wrapper function -----------------------------


#' Pseudonymize data
#'
#' @param import_filename Filename (and path) of dataset to import
#' @param import_sheetname Sheetname
#' @param import_skiprows Number of rows to skip
#' @param import_oldnames Variable names to change
#' @param import_newnames New variable names
#' @param id_original ID-variable that needs to by pseudonymized
#' @param id_salt Salt value
#' @param id_expected_format Expected format of ID-variable (Default: 'digit').
#' If the ID-variable does not have the expected format, the function will try to
#' convert it.
#' @param id_expected_length Expected length of ID-variable (Default: 13). If the
#' ID-variable does not have the expected length, the function will give an error.
#' @param date_var Date variable
#' @param date_new_format Format for new date variable
#' @param date_new_var Name for new date variable
#' @param export_keytable_path Path for keytable export
#' @param export_address_filename Filename (and path) for address file
#' @param export_address_vars Variables to export for address file
#' @param export_pseudonymized_filename Filename (and path) for pseudonymized file
#' @param sensitive Variables to drop. Default: c("ahvnr", "firstname", "surname", "birthday")
#' @param data_summary TRUE (Default) to print head of pseudonymized data.
#'
#' @return Export of following files: keytable, address file, pseudonymized data
#' @export
pseudonymize <- function(
  import_filename,
  import_sheetname = NULL,
  import_skiprows = 0,
  import_oldnames,
  import_newnames,
  id_original = "ahvnr",
  id_salt,
  id_expected_format = "digit",
  id_expected_length = 13,
  date_var = "birthday",
  date_new_format = "%Y",
  date_new_var = "birthyear",
  export_keytable_path,
  export_address_filename,
  export_address_vars =  c('pseudo_id', 'firstname', 'surname', 'plz', 'wohnort'),
  export_pseudonymized_filename,
  sensitive = c("ahvnr", "firstname", "surname", "birthday"),
  data_summary = TRUE){

data <- import_raw_data(filename = import_filename,
                        sheetname = import_sheetname,
                        skiprows = import_skiprows,
                        oldnames = import_oldnames,
                        newnames = import_newnames)

data <- unique_id(data = data,
                  id = id_original,
                  salt = id_salt,
                  id_expected_format = id_expected_format,
                  id_expected_length = id_expected_length)

data <- aggregate_sensitive(data = data,
                            date_var = date_var,
                            date_new_format = date_new_format,
                            date_new_var = date_new_var)

append_keytable(df = data,
                path = export_keytable_path,
                sensitive = sensitive,
                id_original = id_original)

export_address(data = data,
               filename = export_address_filename,
               vars = export_address_vars)

data <- drop_sensitive(data = data, sensitive = sensitive)

utils::write.csv(x = data, file = export_pseudonymized_filename)

# Message:
message(" ")
message(paste0('Pseudonymized file with ', nrow(data), ' rows written to ',
               export_pseudonymized_filename, '.'))
message(paste0('The file contains the following variables: ',
               paste(colnames(data), collapse = ", ")))
if(data_summary == TRUE){
  message(" ")
  print(utils::head(tidyr::as_tibble(data)))
}
}
