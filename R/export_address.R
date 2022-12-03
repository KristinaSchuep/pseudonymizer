# Task 3.2: Generate address file --------------------------------

#' Generate address file
#'
#' @param data Dataframe
#' @param path Filepath
#' @param data_name Name or source of data
#' @param vars Variables to export
#'
#' @return Exported csv-file.
#' @export
export_address <- function(data,
                           path,
                           data_name,
                           vars){
  # Check if address directory already exists otherwise create
  dir.create(file.path(path, "address"), showWarnings = FALSE)

  data <- data[data$rolle=="Antragssteller",]
  data <- data[, vars]

  # Create filename
  now <- Sys.time()
  name <- paste0(format(now, "%Y%m%d_%H%M%S"), "_", data_name, "_address",".csv")

  utils::write.csv(x = data, file = file.path(path, "address", name), row.names = FALSE)
  message(paste0('Address file written to ', file.path("address", name), '.'))
}

