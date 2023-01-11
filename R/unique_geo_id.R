# Create unique IDs for address and house -------------------------------

#' Create unique IDs for address and house
#'
#' These IDs are only unique within a dataset, they are not consistent
#' throughout different datasets or years.
#'
#' @param df Dataframe
#' @param var_street Street
#' @param var_number Street number
#' @param var_plz PLZ
#' @param var_egid EGID
#' @param var_ewid EWID
#'
#' @return Dataframe with additional IDs
#' @export
unique_geo_id <- function(df,
                          var_street = "street",
                          var_number = "street_nr",
                          var_plz = "plz",
                          #var_egid = "egid",
                          #var_ewid = "ewid",
                          list_rename = c("egid","ewid"),
                          list_distinct = c(999999999,999)){
  # Address-ID
  df$address_id <- unique_id_simple(df = df, cols = c(var_street, var_number, var_plz))
  df$address_flag <- 0
  df[which(is.na(df[, var_street])|
             is.na(df[, var_number])|
             is.na(df[, var_plz])), 'address_flag'] <- 1

  # Rename the values of multiple variables
  # Create temp file to store new pseudo variables
  temp <- data.frame(matrix(nrow = nrow(df), ncol = length(list_rename)))
  colnames(temp) <- paste0(list_rename,"_pseudo")

  # Loop thorugh the different elements that require new values
for (i in length(list_rename)) {
  # create temporary variable that assigns a unique random id
  pseudo <- unique_id_simple(df = df, cols = list_rename[i])
  # keep NAs from original variable
  index <- is.na(df[, list_rename[i]])
  pseudo[index] <- NA
  # store in temp file
  temp[i] <- pseudo

}
  #add new pseudos to original data frame
  df <- cbind(df,temp)

  # Create temp file to store new flag variables
  temp <- data.frame(matrix(nrow = nrow(df), ncol = length(list_rename)))
  colnames(temp) <- paste0(list_rename,"_flag")

  # Loop thorugh the different elements that require new values
  for (i in length(list_rename)) {
    # create temporary variable that assigns a unique random id
    flag <- unique_id_simple(df = df, cols = list_rename[i])
    # keep NAs from original variable
    index <- is.na(df[, list_rename[i]])
    flag[index] <- NA
    # store in temp file
    temp[i] <- flag

  }
  #add new pseudos to original data frame
  df <- cbind(df,temp)
  # Create a flag for invalid values
  flag <- as.integer(df[, list_rename[i]] <= 0 | df[, list_rename[i]] > 999999999)
  flag[which(is.na(flag))] <- 1
  flag <-as.integer(df[, list_rename[i]] == list_distinct[i])
  flag <-as.integer(df[, list_rename[i]] == list_distinct[i])


  # EGID-ID
  df$egid_pseudo <- unique_id_simple(df = df, cols = var_egid)
  df[is.na(df[, var_egid]), 'egid_pseudo'] <- NA
  # Flag for invalid egid
  df$egid_flag <- as.integer(df[, var_egid] <= 0 | df[, var_egid] >= 999999999)
  df[which(is.na(df[, 'egid_flag'])), 'egid_flag'] <- 1

  # EWID-ID
  df$ewid_pseudo <- unique_id_simple(df = df, cols = var_ewid)
  df[is.na(df[, var_ewid]), 'ewid_pseudo'] <- NA
  # Flag for invalid ewid
  df$ewid_flag <- as.integer(df[, var_ewid] <= 0 | df[, var_ewid] >= 999999999)
  df[which(is.na(df[, 'ewid_flag'])), 'ewid_flag'] <- 1


  return(df)
}



#' Create a simple, numeric id
#'
#' @param df Dataframe
#' @param cols Variables to use for unique id
#'
#' @return Vector with the new id
#'
unique_id_simple <- function(df, cols) {
  comb <- do.call(paste, c(as.list(df[cols]), sep = "."))
  id <- match(comb, unique(comb))
  return(id)
}



