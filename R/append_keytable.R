# Task 3: Generate and append key table ---------------------------
# - generate new key table with unique ID, AHV number, name, address, birth date
# - load last key table, append 
# - check for inconsistencies --> warning
# - keep only unique values
main_dir <- getwd()
sub_dir <- file.path("data","keytable")

append_keytable <- function(df){
  # Check if ./data/keytable directory already exists otherwise create
  dir.create(file.path(main_dir, sub_dir), showWarnings = FALSE)
  
  # Define which variables to extract 
  keep_columns <- c(pseudo_id,sensitive)
  
  # Create temporary keytable
  keytable_temp <- df_pop[,keep_columns]
  
  # Add system time as variable
  now <- Sys.time()
  path <- getwd()
  keytable_temp$created <-now
  
  # List of all "*keytable.csv" files in keytable subfolder
  sort(list.files(file.path(main_dir, sub_dir), pattern = "keytable.csv"),decreasing = TRUE)
  
  # Load newest keytable with temporary keytable
  newest<-sort(list.files(file.path(main_dir, sub_dir), pattern = "keytable.csv"),decreasing = TRUE)[1]

    if(is.na(newest)){
    # If there is no keytable 
    # Export current keytable to ./data/keytable folder 

    name<-paste0(format(now, "%Y%m%d_%H%M%S"), "_keytable",".csv")
    write.csv(keytable_temp,file.path(path,"data","keytable",name), row.names = FALSE)
    paste("No existing keytable, current keytable is saved")
    
  } else {
      # If there is already an existing keytable load the newest and append temp
      keytable <- read.csv(file.path(main_dir, sub_dir,newest),colClasses = c('character','character','character','character', 'POSIXct', 'POSIXct'))
      keytable_temp <- rbind(keytable,keytable_temp)
      
      
      # Remove duplicates and keep newest value if two entries with same pseudoid
      keytable_temp <- keytable_temp[order(keytable_temp$created, keytable_temp[,id], decreasing = TRUE), ] 
      keytable_temp <- keytable_temp[ !duplicated(keytable_temp$ahvnr), ]
      
      # Export new keytable to ./data/keytable folder 
      name<-paste0(format(now, "%Y%m%d_%H%M%S"), "_keytable",".csv")
      write.csv(keytable_temp,file.path(path,"data","keytable",name), row.names = FALSE)
      paste("Newest keytable is appendend and duplicate AHV-Nr were removed, newer entries were kept")
  }

}