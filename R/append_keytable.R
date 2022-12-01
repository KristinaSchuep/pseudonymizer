# Task 3: Generate and append key table ---------------------------
# - generate new key table with unique ID, AHV number, name, address, birth date
# - load last key table, append 
# - check for inconsistencies --> warning
# - keep only unique values

id<- "pseudo_id"
sensitive <- c("ahvnr","firstname","surname","birthday")
append_keytable <- function(df,id,sensitive){
  # Define which variables to extract 
  keep_columns <- c(id,sensitive)
  
  # Create temporary keytable
  keytable_temp <- df[,keep_columns]
  
  # Check if there is already a keytable in workspace otherwise function is finished
  
  
  
  # Merge existing keytable with temporary keytable
  
  # Export keytable to workspace
  now <- Sys.time()
  name<-paste0("keytable",format(now, "_%Y%m%d_%H%M%S"), ".csv")
  write.csv(keytable,paste0("\\keytable\\",name), row.names = FALSE)
  
  
  return(df)
}

