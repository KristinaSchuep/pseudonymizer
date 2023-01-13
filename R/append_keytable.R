#' Generate and append key table
#'
#' Generate a new keytable or append an existing keytable which holds the
#' sensitive and the pseudonymized identifier.
#'
#' @param df Dataframe
#' @param path File path to directory where keytables will be stored. The function
#' will create a subfolder folder called 'keytable' and store the table there (i.e.
#' in 'path/keytable').
#' @param keytable_vars Variables to keep in keytable
#' @param id_original Original ID, this is used to delete duplicated entries
#'
#' @return Writes or appends keytable
#' @export
#' @examples
#' \dontrun{
#' df <- unique_id(data = testdata, id = "ahvnr", salt = "myverygoodsalt")
#' append_keytable(df = df,
#'                 path = "output",
#'                 keytable_vars = c("ahvnr","firstname","surname"),
#'                 id_original = "ahvnr")
#' }
append_keytable <- function(df,
                            path,
                            keytable_vars,
                            id_original){

  # Check if keytable directory already exists otherwise create
  dir.create(file.path(path, "keytable"), showWarnings = FALSE)

  # Define which variables to extract
  keep_columns <- c("pseudo_id",keytable_vars)

  # Create temporary keytable
  keytable_temp <- df[,keep_columns]

  # Add system time as variable
  now <- Sys.time()
  keytable_temp$created <-format(now, usetz = TRUE)

  # List of all "*keytable.csv" files in keytable subfolder
  # Load newest keytable with temporary keytable
  newest <- sort(list.files(file.path(path, "keytable"), pattern = "keytable.csv"),decreasing = TRUE)[1]
  keytable_temp <- as.data.frame(sapply(keytable_temp[,1:length(keytable_temp)],as.character))

  col_classes <- c(rep("character",length(keytable_temp)))

    if(is.na(newest)){
    # If there is no keytable
    # Export current keytable to ./keytable folder

    name<-paste0(format(now, "%Y%m%d_%H%M%S"), "_keytable",".csv")
    utils::write.csv(keytable_temp,file.path(path,"keytable",name), row.names = FALSE)
    message("No existing keytable, current keytable is saved")

  } else {
      # If there is already an existing keytable load the newest and append temp
      keytable <- utils::read.csv(file.path(path, "keytable", newest),colClasses = col_classes)
      keytable_temp <- rbind(keytable,keytable_temp)

      # Remove duplicates and keep newest value if two entries with same id
      keytable_temp <- keytable_temp[order(keytable_temp$created, keytable_temp[,id_original], decreasing = TRUE), ]
      keytable_temp <- keytable_temp[ !duplicated(keytable_temp[,id_original]), ]

      # Export new keytable to ./data/keytable folder
      name<-paste0(format(now, "%Y%m%d_%H%M%S"), "_keytable",".csv")
      utils::write.csv(keytable_temp,file.path(path,"keytable",name), row.names = FALSE)
      message("Newest keytable is appendend and duplicate AHV-Nr were removed, newer entries were kept")
  }

}
