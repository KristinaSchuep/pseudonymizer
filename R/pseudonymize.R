#' Pseudonymize data
#'
#' This function performs six steps:
#'
#' 1) Import a data set
#' 2) Generate a unique, stable, pseudonymized identifier from a sensitive identifier for each observation unit
#' 3) Aggregate some sensitive data (like aggregate date of birth to year of birth)
#' 4) Optional: Generate a keytable which holds the sensitive and the pseudonymized identifier
#' 5) Optional: Generate an address file
#' 6) Drop sensitive data and export
#'
#' @param data_name Name of data set
#' @param import_filename File name (and path) of dataset to import
#' @param import_sheetname Sheet name
#' @param import_skiprows Number of rows to skip
#' @param import_oldnames Variable names to change
#' @param import_newnames New variable names
#' @param id_original ID-variable that needs to by pseudonymized
#' @param id_salt Salt value
#' @param id_expected_format Expected pattern of ID-variable strings. If the ID-variable
#' does not have the expected pattern, the function will remove any characters that are
#' not of the expected format (Default = 'digit', i.e. letters, punctuation and spaces
#' will be removed from the original ID before applying the hash function).
#' @param date_var Date variable(s)
#' @param date_new_format Format for new date variable(s)
#' @param date_new_var Name for new date variable(s)
#' @param export_path Path to exported data
#' @param export_address TRUE (Default) to export address variables
#' @param address_vars Variables to export for address file
#' @param keytable_vars Variables to export for keytable
#' @param sensitive_vars Variables to drop from final pseudonymized data.
#' @param data_summary TRUE (Default) to print head of pseudonymized data.
#'
#' @return Exports following files: keytable, address file, pseudonymized data.
#' Additionally returns pseudonymized data.
#' @export
#' @examples
#' \dontrun{
#' mysalt <- "myverygoodsalt" # Beware, this is NOT a good salt!
#' oldnames <- c("NNSS","NACHNAME","VORNAME","GEBURTSDATUM")
#' newnames <-  c("ahvnr","surname","firstname","birthday")
#' address_vars <- c('pseudo_id', 'firstname', 'surname', 'strasse', 'hausnr','plz', 'wohnort')
#' keytable_vars <- c("ahvnr","firstname","surname","birthday","strasse","hausnr", "plz", "wohnort")
#' sensitive_vars <- c("ahvnr","firstname","surname","birthday","strasse","hausnr", "plz", "wohnort")
#'
#' df <- pseudonymize(data_name = "FAKE_DATA_2019",
#'                    import_filename = "data-raw/FAKE_DATA_2019.xlsx",
#'                    import_oldnames = oldnames,
#'                    import_newnames = newnames,
#'                    id_original = "ahvnr",
#'                    id_salt = mysalt,
#'                    export_path = "output",
#'                    address_vars =  address_vars,
#'                    keytable_vars = keytable_vars,
#'                    sensitive_vars = sensitive_vars)
#' }
pseudonymize <- function(
  data_name,
  import_filename,
  import_sheetname = NULL,
  import_skiprows = 0,
  import_oldnames,
  import_newnames,
  id_original,
  id_salt,
  id_expected_format = "digit",
  date_var = "birthday",
  date_new_format = "%Y",
  date_new_var = "birthyear",
  export_path,
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
                    id = id_original,
                    salt = id_salt,
                    id_expected_format = id_expected_format)

  data <- aggregate_sensitive(data = data,
                              date_var = date_var,
                              date_new_format = date_new_format,
                              date_new_var = date_new_var)

  message("1) Append keytable:")
  append_keytable(df = data,
                  path = export_path,
                  keytable_vars = keytable_vars,
                  id_original = id_original)

  message(" ")
  if(export_address == TRUE){
    message("2) Export address file:")
    export_address(data = data,
                   path = export_path,
                   data_name = data_name,
                   vars = address_vars)
  } else message("2) Export address file: no addresses exported.")

  message(" ")
  message("3) Export pseudonymized data:")
  export_pseudonymized(data = data,
                       sensitive_vars = sensitive_vars,
                       path = export_path,
                       data_name = data_name,
                       data_summary = data_summary)
}
