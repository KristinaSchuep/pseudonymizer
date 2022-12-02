# Task 4: Drop sensitive data --------------------------------

#' Drop sensitive data
#'
#' @param data Dataframe
#' @param sensitive Sensitive variables to drop. Default: c("ahvnr", "firstname", "surname", "birthday")
#'
#' @return Dataset from which indicated variables have been dropped.
#' @export
drop_sensitive <- function(data,
                           path,
                           sensitive = c("ahvnr", "firstname", "surname", "birthday")){
  # Check if panon directory already exists otherwise create
  dir.create(file.path(path, "panon"), showWarnings = FALSE)
  
  data <- data[, setdiff(colnames(data), sensitive)]
  return(data)
}
