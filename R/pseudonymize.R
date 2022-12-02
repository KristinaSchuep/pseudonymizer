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
#' @param export_address_filename Filename (and path) for address file
#' @param export_address_vars Variables to export for address file
#' @param export_pseudonymized_filename Filename (and path) for pseudonymized file
#' @param export_pseudonymized_drop Variables to drop or pseudonymized.
#' Default: c("ahvnr", "firstname", "surname", "birthday")
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
  export_address_filename,
  export_address_vars =  c('pseudo_id', 'firstname', 'surname', 'plz', 'wohnort'),
  export_pseudonymized_filename,
  export_pseudonymized_drop = c("ahvnr", "firstname", "surname", "birthday")){

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

# append_keytable()

export_address(data = data,
               filename = export_address_filename,
               vars = export_address_vars)

data <- drop_sensitive(data = data, drop = export_pseudonymized_drop)

write.csv(x = data, file = export_pseudonymized_filename)
print(paste0('Pseudonymized file written to ', export_pseudonymized_filename, '.'))

}
