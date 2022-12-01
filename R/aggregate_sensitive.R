# Task 2: Aggregate sensitive data -------------------------------

# Usage: aggregate_sensitive(data = df_pop)

aggregate_sensitive <- function(data,
                                date_var = "birthday",
                                date_new_var = "birthyear"){
  date_var_ <- data[, date_var]
  date_var_ <- as.Date(date_var_)
  date_var_ <- as.numeric(format(date_var_, format = "%Y"))
  data[, date_new_var] <- date_var_
  return(data)
}

