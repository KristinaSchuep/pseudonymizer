# Task 3: Generate and append key table ---------------------------
# - generate new key table with unique ID, AHV number, name, address, birth date
# - load last key table, append 
# - check for inconsistencies --> warning
# - keep only unique values
main_dir <- getwd()
sub_dir <- file.path("data","keytable")

pseudo_id<- "pseudo_id"
sensitive <- c("ahvnr","firstname","surname","birthday")

append_keytable <- function(df){
  # Check if ./data/keytable directory already exists otherwise create
  dir.create(file.path(main_dir, sub_dir), showWarnings = FALSE)
  
  # Define which variables to extract 
  keep_columns <- c(pseudo_id,sensitive)
  
  # Create temporary keytable
  keytable_temp <- df_pop[,keep_columns]
  
  # Check if there is already a keytable in workspace otherwise function is finished
  list.files(file.path(main_dir, sub_dir), pattern = "keytable")
  
  # Merge existing keytable with temporary keytable
  
  # Export keytable to ./data/keytable folder 
  now <- Sys.time()
  path <- getwd()
  name<-paste0("keytable",format(now, "_%Y%m%d_%H%M%S"), ".csv")

  write.csv(keytable,file.path(path,"data","keytable",name), row.names = FALSE)
  

  return(df)
}

