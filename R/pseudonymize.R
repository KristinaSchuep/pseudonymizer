# Task 6: Write wrapper function -----------------------------


#' Pseudonymize data
#'
#' @param data_name Name of data
#' @param import_filename Filename (and path) of dataset to import
#' @param import_sheetname Sheetname
#' @param import_skiprows Number of rows to skip
#' @param import_oldnames Variable names to change
#' @param import_newnames New variable names
#' @param id ID-variable that needs to by pseudonymized
#' @param id_salt Salt value
#' @param id_expected_format Expected format of ID-variable (Default: 'digit').
#' If the ID-variable does not have the expected format, the function will try to
#' convert it.
#' @param id_expected_length Expected length of ID-variable (Default: 13). If the
#' ID-variable does not have the expected length, the function will give an error.
#' @param date_var Date variable
#' @param date_new_format Format for new date variable
#' @param date_new_var Name for new date variable
#' @param path Path exported data
#' @param export_address TRUE (Default) to export address variables
#' @param address_vars Variables to export for address file
#' @param keytable_vars Variables to export for keytable
#' @param sensitive_vars Variables to drop from final pseudonymized data.
#' @param data_summary TRUE (Default) to print head of pseudonymized data.
#' @param var_street Variable for street name
#' @param var_number Variable for street number
#' @param var_zip Variable for zip code
#' @param var_new_zip Variable for new zip code format
#' @param var_egid Variable of official building registry
#' @param var_ewid Variable of official flat registry
#'
#' @return Export of following files: keytable, address file, pseudonymized data
#' @export
pseudonymize <- function(
  data_name,
  import_filename,
  import_sheetname = NULL,
  import_skiprows = 0,
  import_oldnames,
  import_newnames,
  id,
  id_salt,
  id_expected_format = "digit",
  id_expected_length = 13,
  date_var = "birthday",
  date_new_format = "%Y",
  date_new_var = "birthyear",
  var_street = "strasse",
  var_number = "hausnr",
  var_egid = "egid",
  var_ewid = "ewid",
  var_zip = "plz",
  var_new_zip = "plz4",
  path,
  export_address = TRUE,
  address_vars,
  keytable_vars,
  sensitive_vars,
  data_summary = TRUE){

  # Check if output directory already exists otherwise create
  # dir.create("output", showWarnings = FALSE)

  data <- import_raw_data(filename = import_filename,
                          sheetname = import_sheetname,
                          skiprows = import_skiprows,
                          oldnames = import_oldnames,
                          newnames = import_newnames)

  data <- unique_id(data = data,
                    id = id,
                    salt = id_salt,
                    id_expected_format = id_expected_format,
                    id_expected_length = id_expected_length)

  data <- aggregate_sensitive(data = data,
                              date_var = date_var,
                              date_new_format = date_new_format,
                              date_new_var = date_new_var,
                              var_zip = var_zip,
                              var_new_plz = var_new_zip)

  data <- unique_geo_id(df = data,
                        var_street = var_street,
                        var_number = var_number,
                        var_zip = var_zip,
                        var_egid = var_egid,
                        var_ewid = var_ewid)

  message("1) Append keytable:")
  append_keytable(df = data,
                  path = path,
                  keytable_vars = keytable_vars,
                  id = id)

  message(" ")
  if(export_address == TRUE){
    message("2) Export address file:")
    export_address(data = data,
                   path = path,
                   data_name = data_name,
                   vars = address_vars)
  } else message("2) Export address file: no addresses exported.")

  message(" ")
  message("3) Export pseudonymized data:")
  export_pseudonymized(data = data,
                       sensitive_vars = sensitive_vars,
                       path = path,
                       data_name = data_name,
                       data_summary = data_summary)
}
