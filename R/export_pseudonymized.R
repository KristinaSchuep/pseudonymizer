# Task 4: Export pseudonymized data to csv ----------------------------------

#' Export pseudonymized data to csv
#'
#' @param data Dataframe
#' @param sensitive_vars Sensitive variables to drop. These are not exported.
#' @param path Filepath
#' @param data_name Name or source of data
#' @param data_summary TRUE (Default) to print head of exported data.
#'
#' @return Exported csv-file from which indicated variables have been dropped.
#' @export
export_pseudonymized <- function(data,
                                 sensitive_vars,
                                 path,
                                 data_name,
                                 data_summary){
  message(paste0("------- Export Pseudonymized Data -------"))
  # Drop sensitive data
  data <- data[, setdiff(colnames(data), sensitive_vars)]

  # Check if address directory already exists otherwise create
  dir.create(file.path(path, "panon"), showWarnings = FALSE)

  # Create filename
  now <- Sys.time()
  name <- paste0(format(now, "%Y%m%d_%H%M%S"), "_", data_name, "_panon",".csv")

  utils::write.csv(x = data, file = file.path(path, "panon", name), row.names = FALSE)

  # Message:
  message(paste0("Pseudonymized file with ", nrow(data), " rows written to '",
                 file.path("panon", name), "'."))
  message(paste0("The file contains the following variables: ",
                 paste(colnames(data), collapse = ", ")))
  if(data_summary == TRUE){
    message(" ")
    print(utils::head(tidyr::as_tibble(data)))
    return(data)
    }

}

