# Task 3.2: Generate address file --------------------------------

export_address <- function(data, filename, vars){

  data <- data[data$rolle=="Antragssteller",]
  data <- data[, vars]
  write.csv(x = data, file = filename)
  print(paste0('File written to ', filename, '.'))
}

