#' Generate address file
#'
#' @param data Dataframe
#' @param path File path to directory where adress table will be stored. The function
#' will create a subfolder folder called 'address' and store the table there (i.e.
#' in 'path/address').
#' @param data_name Name or source of data
#' @param vars Variables to export
#'
#' @return Exported csv-file.
#' @export
#' @examples
#' \dontrun{
#' df <- unique_id(data = testdata, id = "ahvnr", salt = "myverygoodsalt")
#' export_address(data = df,
#'                path = "output",
#'                data_name = "FAKE_DATA",
#'                vars = c("pseudo_id", "firstname", "surname", 'plz', 'wohnort'))
#' }
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

