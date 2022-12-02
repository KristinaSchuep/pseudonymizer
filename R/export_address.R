# Task 3.2: Generate address file --------------------------------

#' Generate address file
#'
#' @param data Dataframe
#' @param filename Filename (and path) for exported address file
#' @param vars Variables to export
#'
#' @return Exported csv-file.
#' @export
export_address <- function(data, path, filename, vars){
  # Check if address directory already exists otherwise create
  dir.create(file.path(path, "address"), showWarnings = FALSE)
  
  data <- data[data$rolle=="Antragssteller",]
  data <- data[, vars]
  utils::write.csv(x = data, file = file.path(path,filename))
  message(paste0('Address file written to ', filename, '.'))
}

