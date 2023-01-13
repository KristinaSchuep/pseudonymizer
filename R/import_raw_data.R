#' Import dataset into R
#'
#' @param filename Filename (and path) of dataset to import
#' @param sheetname Sheetname (Default = NULL)
#' @param skiprows Number of rows to skip (Default = 0)
#' @param oldnames Vector with the variable names to be renamed
#' @param newnames Vector with the new variable names
#'
#' @return Imported dataset, with renamed variables.
#' @export
#' @examples
#' \dontrun{
#' df <- import_raw_data(filename = "./data-raw/FAKE_DATA_2019.xlsx",
#'                       oldnames = c("NNSS","NACHNAME","VORNAME","GEBURTSDATUM"),
#'                       newnames = c("ahvnr","surname","firstname","birthday"))
#' }
import_raw_data <- function(filename,
                            sheetname = NULL,
                            skiprows = 0,
                            oldnames,
                            newnames){

  df <- suppressMessages(readxl::read_excel(filename,sheet=sheetname,skip=skiprows))

  #remove rows with all NAs
  df <- df[!apply(is.na(df), 1, all),]

  # Check that oldnames are df column names
  assertthat::assert_that(all(oldnames %in% names(df)), msg = "One or more column name cannot be replaced, because it does not exist. Verify that all names in 'oldnames' are actually in dataframe")

  #Check that oldnames and newnames are same length
  assertthat::assert_that(length(oldnames)==length(newnames), msg = "The number of column names in 'oldnames' does not match the number of replacing column names in 'newnames'")

  index <- match(oldnames, names(df))
  colnames(df)[index] <- newnames
  names(df) <- tolower(names(df))
  return(as.data.frame(df))
}


# (Optional/for later): Identify main person per dossier -----------------------
# - add row numbers to be able to recover order of original file
# - assign a number for each individuals per dossier
# - identify person that is the 'Schuldner' for each dossier (based on the name)
