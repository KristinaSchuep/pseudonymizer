#' Generate and append key table
#'
#' @param df Dataframe
#' @param path Filepath
#' @param keytable_vars Variables to keep in keytable
#' @param id ID-variable that needs to by pseudonymized
#' @param pseudo_id Pseudonymized ID-variable
#' @param firstname Firstname Variable
#' @param surname Surname Variable
#' @param birthday Second variable to identify duplicates
#' @return Writes or appends keytable
#' @export
append_keytable <- function(df,
                            path,
                            id,
                            pseudo_id,
                            firstname = NA,
                            surname = NA,
                            birthday = NA
                            prefix = "") {
  message(paste0("------- Append Key Table -------"))
  # Check if keytable directory already exists otherwise create
  dir.create(file.path(path, "keytable"), showWarnings = FALSE)

  # Define which variables to extract
  # id <- "prim_ahvnr"
  # pseudo_id <- "prim_pseudo"
  # firstname <- "prim_firstname"
  # surname <- "prim_surname"
  # birthday <- "prim_birthdate"
  # prefix <- "prim_"


  # story all variables from function input
  keep_columns <- c(pseudo_id, id, firstname, surname, birthday)

  # remove those that were not given
  keep_columns <- keep_columns[!sapply(keep_columns, is.na)]

  # Create temporary keytable
  keytable_temp <- df[, keep_columns]


  remove_prefix <- function(variable,
                            prefix = prefix) {
  sub(prefix, "", variable)
}

  # Remove prefix from colnames, such that all ids are stored in same column
  colnames(keytable_temp) <- remove_prefix(colnames(keytable_temp), prefix)

  # store prefix in different column
  keytable_temp$prefix <- rep(sub("_$", "", prefix), nrow(keytable_temp))



####### TEST START

prim_ahvnr <- c("756.1234.5678.01", "756.1234.5678.02", "756.1234.5678.03", "756.1234.5678.04", "756.1234.5678.05")
prim_pseudo <- openssl::sha256(x = prim_ahvnr, key = salt)
prim_firstname <- c("Aaron", "Berta", "Claudio", "Dario", "Elsa")
prim_surname <- c("Ackermann", "Brunner", "Christen", "Dachs", "Eris")
prim_birthdate <- c("1995-08-29", "1961-11-24", "1960-12-26", "1970-02-16", "")


keytable <- data.table::data.table(prim_ahvnr, prim_pseudo, prim_firstname, prim_surname, prim_birthdate)



new_prim_ahvnr <- c("756.9876.5432.01", "756.9876.5432.02", "756.9876.5432.06", "756.9876.5432.07", "756.9876.5432.08")
new_prim_pseudo <- openssl::sha256(x = new_prim_ahvnr, key = salt)
new_prim_firstname <- c("Aaron", "Berta", "Sophia", "Liam", "Olivia")
new_prim_surname <- c("Ackermann", "Brunner", "Williams", "Jones", "Brown")
new_prim_birthdate <- c("", "1961-11-24", "1995-02-20", "1978-11-30", "1989-07-12")

# Creating the second data.table
keytable_temp <- data.table::data.table(
  prim_ahvnr = new_prim_ahvnr,
  prim_pseudo = new_prim_pseudo,
  prim_firstname = new_prim_firstname,
  prim_surname = new_prim_surname,
  prim_birthdate = new_prim_birthdate
)

# Combining the fixed entry with the second data.table
keytable <- data.table::rbindlist(list(keytable, keytable_temp), use.names = TRUE, fill = TRUE)


    keytable_temp <- data.table::rbindlist(
                        list(keytable, keytable_temp), fill = TRUE)
####### TEST END

  # Add system time as variable
  now <- Sys.time()
  keytable_temp$created <- format(now, usetz = TRUE)

  # List of all "*keytable.csv" files in keytable subfolder
  # Load newest keytable with temporary keytable
  newest <- sort(list.files(file.path(path, "keytable"),
                pattern = "keytable.csv"), decreasing = TRUE)[1]

  # make sure hash is stored as character
  # otherwise merge wont work
  keytable_temp <- as.data.frame(
                  sapply(keytable_temp[, 1:length(keytable_temp)],
                          as.character))

  col_classes <- c(rep("character", length(keytable_temp)))

    if (is.na(newest)) {
    # If there is no keytable
    # Export current keytable to ./keytable folder
    keytable_temp <- keytable_temp[order(keytable_temp$created, decreasing = TRUE), ]
    n <- nrow(keytable_temp)

    # Check if there is a birthday variable to remove duplicates
      if (!is.na(birthday)) {
        keytable_temp <-
          keytable_temp[!duplicated(keytable_temp[c("ahvnr", "birthdate"), prefix)]), ]

        message(paste0(n - nrow(keytable_temp),
          " duplicates based on AHV-number and birthday variable removed.
          Keytable now containts ",
          nrow(keytable_temp), " observations with ",
          nrow(keytable_temp[!duplicated(keytable_temp[c(id)]), ]),
          " unique AHV-numbers."))
      }
    else {
        keytable_temp <-
          keytable_temp[!duplicated(keytable_temp[,"ahvnr"]), ]

        message(paste0(n - nrow(keytable_temp),
          " duplicates based on AHV-number removed.
          Keytable now containts ",
          nrow(keytable_temp), " observations with ",
          nrow(keytable_temp[!duplicated(keytable_temp[c(id)]), ]),
          " unique AHV-numbers."))
    }
    name <- paste0(format(now, "%Y%m%d_%H%M%S"), "_keytable", ".csv")

    utils::write.csv(keytable_temp,
      file.path(path, "keytable", name), row.names = FALSE)

    message("No existing keytable, current keytable is saved")

  } else {
    # If there is already an existing keytable load the newest and append temp
    keytable <-
        utils::read.csv(file.path(path, "keytable", newest),
          colClasses = col_classes)

    keytable_temp <- data.table::rbindlist(
                        list(keytable, keytable_temp),
                        use.names = TRUE, fill = TRUE)

    # Remove duplicates
    # Sort by newest
    keytable_temp <-
          keytable_temp[order(keytable_temp$created, decreasing = TRUE), ]

    n <- nrow(keytable_temp)
    
    # if there are two entries with same pseudo_id
    # keep value with prefix = "prim"

    keytable_temp <-
          keytable_temp[!duplicated(keytable_temp[c(id, birthday)]), ]
    message(paste0(n - nrow(keytable_temp),
        " duplicates based on AHV-number and secondary removed.
        Keytable now containts ",
        nrow(keytable_temp), " observations with ",
        nrow(keytable_temp[!duplicated(keytable_temp[c(id)]), ]),
        " unique AHV-numbers."))

    # Export new keytable to ./data/keytable folder
    name <- paste0(format(now, "%Y%m%d_%H%M%S"), "_keytable", ".csv")
    utils::write.csv(
        keytable_temp, file.path(path, "keytable", name), row.names = FALSE)

    message("Newest keytable is appended and duplicate AHV-Nr were removed,
            entries from most recent complication are kept")
  }

}
