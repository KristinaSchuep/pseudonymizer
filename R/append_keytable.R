# Task 3: Generate and append key table ---------------------------
# - generate new key table with unique ID, AHV number, name, address, birth date
# - load last key table, append
# - check for inconsistencies --> warning
# - keep only unique values

#' Generate and append key table
#'
#' @param df Dataframe
#' @param path Filepath
#' @param sensitive Sensitive variables to drop
#' @param id_original ID-variable that needs to by pseudonymized
#'
#' @return Writes or appends keytable
#' @export
append_keytable <- function(df, path, sensitive, id_original){

  # Check if ./data/keytable directory already exists otherwise create
  dir.create(file.path(path, "keytable"), showWarnings = FALSE)

  # Define which variables to extract
  keep_columns <- c("pseudo_id",sensitive)

  # Create temporary keytable
  keytable_temp <- df[,keep_columns]

  # Add system time as variable
  now <- Sys.time()
  keytable_temp$created <-now

  # List of all "*keytable.csv" files in keytable subfolder
  # Load newest keytable with temporary keytable
  newest<-sort(list.files(file.path(path, "keytable"), pattern = "keytable.csv"),decreasing = TRUE)[1]

    if(is.na(newest)){
    # If there is no keytable
    # Export current keytable to ./keytable folder

    name<-paste0(format(now, "%Y%m%d_%H%M%S"), "_keytable",".csv")
    utils::write.csv(keytable_temp,file.path(path,"keytable",name), row.names = FALSE)
    message("No existing keytable, current keytable is saved")

  } else {
      # If there is already an existing keytable load the newest and append temp
      keytable <- utils::read.csv(file.path(path, "keytable", newest),colClasses = c('character','character','character','character', 'POSIXct', 'POSIXct'))
      keytable_temp <- rbind(keytable,keytable_temp)


      # Remove duplicates and keep newest value if two entries with same pseudoid
      keytable_temp <- keytable_temp[order(keytable_temp$created, keytable_temp[,id_original], decreasing = TRUE), ]
      keytable_temp <- keytable_temp[ !duplicated(keytable_temp$ahvnr), ]

      # Export new keytable to ./data/keytable folder
      name<-paste0(format(now, "%Y%m%d_%H%M%S"), "_keytable",".csv")
      utils::write.csv(keytable_temp,file.path(path,"keytable",name), row.names = FALSE)
      message("Newest keytable is appendend and duplicate AHV-Nr were removed, newer entries were kept")
  }

}
