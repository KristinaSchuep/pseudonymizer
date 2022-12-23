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
                          var_street = "strasse",
                          var_number = "hausnr",
                          var_plz = "plz",
                          var_egid = "egid",
                          var_ewid = "ewid"){
  # Address-ID
  df$address_id <- unique_id_simple(df = df, cols = c(var_street, var_number, var_plz))
  df$address_flag <- 0
  df[which(is.na(df[, var_street])|
             is.na(df[, var_number])|
             is.na(df[, var_plz])), 'address_flag'] <- NA

  # EGID-ID
  df$egid_pseudo <- unique_id_simple(df = df, cols = var_egid)
  df[is.na(df[, var_egid]), 'egid_pseudo'] <- NA
  # Flag for invalid egid
  df$egid_flag <- as.integer(df[, var_egid] <= 0 | df[, var_egid] >= 999999999)

  # EWID-ID
  df$ewid_pseudo <- unique_id_simple(df = df, cols = var_ewid)
  df[is.na(df[, var_ewid]), 'ewid_pseudo'] <- NA
  # Flag for invalid ewid
  df$ewid_flag <- as.integer(df[, var_ewid] <= 0 | df[, var_ewid] >= 999999999)

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



