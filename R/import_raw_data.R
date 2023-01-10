# Task 0: Import datasets (mostly as excel files) into R -----------------------

#' Import datasets into R
#'
#' @param filename Filename (and path) of dataset to import
#' @param sheetname Sheetname
#' @param skiprows Number of rows to skip
#' @param oldnames Variable names to change
#' @param newnames New variable names
#'
#' @return Imported dataset, with renamed variables.
#' @export
import_raw_data <- function(filename,
                            sheetname = NULL,
                            skiprows = 0,
                            oldnames,
                            newnames){
  
  if (grepl(".csv", filename, fixed = TRUE)){
    #import csv and recognize empty strings as NA
    df <- suppressMessages(read.csv(filename, na.strings=c("","NA")))
  } else if (grepl(".xls", filename, fixed = TRUE)){
    #import excel
    df <- suppressMessages(readxl::read_excel(filename,sheet=sheetname,skip=skiprows))
  } else 
    stop("Unclear file format. The filename does neither contain '.csv' nor '.xls' (e.g., '.xlsx', .'xls', '.xlsm'.)")
  
  n<-nrow(df)
  #remove rows with all NAs
  df <- df[!apply(is.na(df), 1, all),]
  message(paste0("Imported file had ", n, " rows. After removing NAs ", nrow(df),
                 " observations remain."))
  
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
