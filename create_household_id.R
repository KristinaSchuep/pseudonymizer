# Create House and Household ID -------------------------------
#' Title
#'
#' @param data 
#' @param var_street 
#' @param var_number 
#' @param var_surname 
#'
#' @return
#' @export
#'
#' @examples
create_household_id <- function(data,
                                var_street = "strasse",
                                var_number = "hausnr",
                                var_surname = "surname"){
  # Create groups of those with same adresse (Street + Housenumber)
  address<-paste(data[,var_street],data[,var_number])
  data$address <- gsub(" ", "",gsub("[[:punct:]]", "", address))
  data$dossier <- with(data, match(address, sort(unique(address))))
  
  # Check whether someone has the same last name
  # If so put them into the same group
  # If possible account for some using double names and some not. see example FAKE_2019 Family Ackermann

  return(data)
}
}




