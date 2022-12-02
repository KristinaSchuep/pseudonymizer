# Task 3.2: Generate address file --------------------------------

#' Generate address file
#'
#' @param data Dataframe
#' @param filename Filename (and path) for exported address file
#' @param vars Variables to export
#'
#' @return Exported csv-file.
#' @export
export_address <- function(data, filename, vars){

  data <- data[data$rolle=="Antragssteller",]
  data <- data[, vars]
  write.csv(x = data, file = filename)
  print(paste0('Address file written to ', filename, '.'))
}

