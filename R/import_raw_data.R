# Task 0: Import datasets (mostly as excel files) into R -----------------------

import_raw_data <- function(filename,
                            sheetname =NULL,
                            skiprows = 0){
  
  df <- readxl::read_excel(filename,sheet=sheetname,skip=skiprows)
  
  index <- match(oldnames, names(df))
  colnames(df)[index] <- newnames
  names(df) <- tolower(names(df))
  return(as.data.frame(df))
  
  # Check that oldnames are df column names
  assertthat::assert_that(all(oldnames %in% names(df)), msg = "One or more column name cannot be replaced, because it does not exist. Verify that all names in 'oldnames' are actually in dataframe")
  
  #Check that oldnames and newnames are same length
  assertthat::assert_that(length(oldnames)==length(newnames), msg = "The number of column names in 'oldnames' does not match the number of replacing column names in 'newnames'")
}


# (Optional/for later): Identify main person per dossier -----------------------
# - add row numbers to be able to recover order of original file
# - assign a number for each individuals per dossier
# - identify person that is the 'Schuldner' for each dossier (based on the name)