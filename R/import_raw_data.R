# Task 0: Import datasets (mostly as excel files) into R -----------------------


import_raw_data <- function(){
  df_pop <- readxl::read_excel("./data/FAKE_DATA_2019.xlsx")
  
  df_debt <- readxl::read_excel("./data/FAKE_Verlustscheine.xlsx", sheet = "Schlussabrechnung")[-c(1:2), ]
  
  df_assura <- readxl::read_excel("./data/FAKE_Verlustscheine.xlsx", sheet = "Assura")[-c(1:2), ]
  
  df_nichtsedex <- readxl::read_excel("./data/FAKE_Verlustscheine.xlsx", sheet = "Nicht-Sedex")[-c(1:2), ]
  
  
#  read_excel_allsheets <- function(filename, tibble = TRUE) {
#    sheets <- readxl::excel_sheets(filename)
#    x <- lapply(sheets, function(X) readxl::read_excel(filename, sheet = X))
#    if(!tibble) x <- lapply(x, as.data.frame)
#    names(x) <- sheets
#    x
#  }
  
#  df_debt <- read_excel_allsheets("./data/FAKE_Verlustscheine.xlsx")
    
  


}

# (Optional/for later): Identify main person per dossier -----------------------
# - add row numbers to be able to recover order of original file
# - assign a number for each individuals per dossier
# - identify person that is the 'Schuldner' for each dossier (based on the name)
