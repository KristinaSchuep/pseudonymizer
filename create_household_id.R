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
  # Check if Familysize=1
  
  # Create groups of those with same adresse (Street + Housenumber)
  address<-paste(data[,var_street],data[,var_number])
  data$address <- gsub(" ", "",gsub("[[:punct:]]", "", address))
  
  #assign Geo_id based on address
  #data$geo_id <- cumsum(!duplicated(data[,c("address")]))
  
  # Check if Entries per Adresse=1
  
  # Count number ob "Antagsteller" per geo_id
  antragssteller_per_geo_id  <- aggregate(rep(1, length(paste0(data$geo_id, data$rolle))), by=list(data$geo_id, data$rolle), sum)
  temp <- do.call(data.frame, antragssteller_per_geo_id)
  colnames(temp) <- c("geo_id","rolle", "poss_applicants")
  temp <- temp[temp$rolle=="Antragssteller",]
  data <- (merge(data, temp[,c("geo_id","poss_applicants")], by = "geo_id"))
  
  # Check if within one address poss_applicants = 1
  
  # Check if within one address entry per address=familysize
  
  # Check if within one address and one ewid, entries=familysize
  
  # Check if within one address and one surname, entries=familysize
  # If possible account for double names 
  
  # Else NA 
  


  return(data)
}




