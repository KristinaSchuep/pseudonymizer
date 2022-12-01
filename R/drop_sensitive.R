# Task 4: Drop sensitive data --------------------------------

drop_sensitive <- function(data,
                           drop = c("ahvnr", "firstname", "surname", "birthday"),
                           drop_add = NA){
  data <- data[, setdiff(colnames(data), c(drop, drop_add))]
  return(data)
}
