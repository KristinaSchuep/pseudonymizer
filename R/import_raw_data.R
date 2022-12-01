# Task 0: Import datasets (mostly as excel files) into R -----------------------


import_raw_data <- function(filename,
                            sheetname =NULL,
                            skiprows = 0,
                            ahvnr,
                            firstname,
                            surname,
                            birthday,
                            head){
  
  df <- readxl::read_excel(filename,sheet=sheetname,skip=skiprows)
  colnames(df)[colnames(df) == ahvnr] <- "ahvnr"
  colnames(df)[colnames(df) == firstname] <- "firstname"
  colnames(df)[colnames(df) == surname] <- "surname"
  colnames(df)[colnames(df) == birthday] <- "birthday"
  names(df) <- tolower(names(df))
  df
  
}


# (Optional/for later): Identify main person per dossier -----------------------
# - add row numbers to be able to recover order of original file
# - assign a number for each individuals per dossier
# - identify person that is the 'Schuldner' for each dossier (based on the name)