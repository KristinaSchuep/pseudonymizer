#' Generate and append key table
#'
#' @param df Dataframe
#' @param path Filepath
#' @param keytable_vars Variables to keep in keytable
#' @param id ID-variable that needs to by pseudonymized
#' @param pseudo_id Pseudonymized ID-variable

#' @return Writes or appends keytable
#' @export
append_keytable <- function(df,
                            path,
                            keytable_vars,
                            id,
                            pseudo_id) {
  message(paste0("------- Append Key Table -------"))
  # Check if keytable directory already exists otherwise create
  dir.create(file.path(path, "keytable"), showWarnings = FALSE)

  # Define which variables to extract
  keep_columns <- c(pseudo_id, keytable_vars)

  # Create temporary keytable
  keytable_temp <- df[, keep_columns]

  # Add system time as variable
  now <- Sys.time()
  keytable_temp$created <- format(now, usetz = TRUE)

  # List of all "*keytable.csv" files in keytable subfolder
  # Load newest keytable with temporary keytable
  newest <- sort(list.files(file.path(path, "keytable"), pattern = "keytable.csv"), decreasing = TRUE)[1]
  keytable_temp <- as.data.frame(sapply(keytable_temp[, 1:length(keytable_temp)], as.character))

  col_classes <- c(rep("character", length(keytable_temp)))

    if(is.na(newest)) {
    # If there is no keytable
    # Export current keytable to ./keytable folder
    keytable_temp <- keytable_temp[order(keytable_temp$created, keytable_temp[, id], decreasing = TRUE), ]
    n <- nrow(keytable_temp)

    keytable_temp <- keytable_temp[!duplicated(keytable_temp[c(id, "birthday")]), ]
    message(paste0(n - nrow(keytable_temp), " duplicates based on AHV-number and birthday removed. Keytable now containts ", nrow(keytable_temp), " observations with ",nrow(keytable_temp[!duplicated(keytable_temp[c(id)]),]), " unique AHV-numbers."))

    name <- paste0(format(now, "%Y%m%d_%H%M%S"), "_keytable",".csv")
    utils::write.csv(keytable_temp,file.path(path,"keytable",name), row.names = FALSE)
    message("No existing keytable, current keytable is saved")

  } else {
    # If there is already an existing keytable load the newest and append temp
    keytable <- utils::read.csv(file.path(path, "keytable", newest),colClasses = col_classes)
    keytable_temp <- rbind(keytable, keytable_temp)


    # Remove duplicates and keep newest value if two entries with same pseudo_id
    keytable_temp <- keytable_temp[order(keytable_temp$created, keytable_temp[,id], decreasing = TRUE), ]
    n <- nrow(keytable_temp)

    keytable_temp <- keytable_temp[!duplicated(keytable_temp[c(id,"birthday")]), ]
    message(paste0(n - nrow(keytable_temp), " duplicates based on AHV-number and birthday removed. Keytable now containts ", nrow(keytable_temp), " observations with ",nrow(keytable_temp[!duplicated(keytable_temp[c(id)]),]), " unique AHV-numbers."))

    # Export new keytable to ./data/keytable folder
    name <- paste0(format(now, "%Y%m%d_%H%M%S"), "_keytable", ".csv")
    utils::write.csv(keytable_temp,file.path(path,"keytable",name), row.names = FALSE)
    message("Newest keytable is appended and duplicate AHV-Nr were removed, entries from most recent complication are kept")
  }

}
