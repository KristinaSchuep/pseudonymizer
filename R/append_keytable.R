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
                            file = file) {
  message(paste0("------- Append Key Table -------"))
  # Check if keytable directory already exists otherwise create
  dir.create(file.path(path, "keytable"), showWarnings = FALSE)

  # Define which variables to extract

  ####### TEST Data START
id <- "prim_ahvnr"
pseudo_id <- "prim_pseudo"
salt <- mysalt

# DF 1
prim_ahvnr <- c("756.1234.5678.01","756.1234.5678.01", "756.1234.5678.02", "756.1234.5678.03", "756.1234.5678.04", "756.1234.5678.05")
prim_pseudo <- openssl::sha256(x = prim_ahvnr, key = salt)
prim_firstname <- c("", "Aaron", "Berta", "Claudio", "Dario", "Elsa")
prim_surname <- c("", "Ackermann", "Brunner", "Christen", "Dachs", "Eris")
prim_birthdate <- c("", "1995-08-29", "1961-11-24", "1960-12-26", "1970-02-16", "")


df <- data.table::data.table(prim_ahvnr, prim_pseudo, prim_firstname, prim_surname, prim_birthdate)


# DF 2
prim_ahvnr <- c("756.1234.5678.01", "756.9876.5432.02", "756.9876.5432.06", "756.9876.5432.07", "756.9876.5432.08")
prim_pseudo <- openssl::sha256(x = prim_ahvnr, key = salt)
prim_firstname <- c("Aaron", "Berta", "Sophia", "Liam", "Olivia")
prim_surname <- c("Ackermann", "Brunner", "Williams", "Jones", "Brown")
prim_birthdate <- c("", "1961-11-24", "1995-02-20", "1978-11-30", "1989-07-12")

df <- data.table::data.table(prim_ahvnr, prim_pseudo, prim_firstname, prim_surname, prim_birthdate)


####### TEST Data END

n <- nrow(df)

  # Create temporary keytable
  keytable_temp <- data.table::data.table(
    ahvnr = df[[id]],
    pseudo_id = df[[pseudo_id]],
    # add the source of the ahvnr
    source = rep(file, n)
  )
  # make sure hash is stored as character
  # otherwise merge wont work
  keytable_temp <- as.data.frame(
                  sapply(keytable_temp[, 1:length(keytable_temp)],
                          as.character))

  col_classes <- c(rep("character", length(keytable_temp)))


  # Add system time as variable
  now <- Sys.time()
  keytable_temp$created <- format(now, usetz = TRUE)

  # List of all "*keytable.csv" files in keytable subfolder
  # Load newest keytable with temporary keytable
  newest <- sort(list.files(file.path(path, "keytable"),
                pattern = "keytable.csv"), decreasing = TRUE)[1]


    if (is.na(newest)) {
    # If there is no keytable
    # Export current keytable to ./keytable folder

    # store row count for message
    n <- nrow(keytable_temp)

    # Remove duplicates based on ahvnr and pseudo_id
        keytable_temp <- unique(keytable_temp, by = c("ahvnr", "pseudo_id"))

        message(paste0(n - nrow(keytable_temp),
          " duplicates based on AHV-number and pseudo_id removed.
          Keytable now containts ",
          nrow(keytable_temp), " observations with ",
          length(unique(keytable_temp$ahvnr)),
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

    # store row count for message
    n <- nrow(keytable_temp)

# Remove duplicates based on ahvnr and pseudo_id
        keytable_temp <- unique(keytable_temp, by = c("ahvnr", "pseudo_id"))

    message(paste0(n - nrow(keytable_temp),
        " duplicates based on AHV-number and secondary removed.
        Keytable now containts ",
        nrow(keytable_temp), " observations with ",
        length(unique(keytable_temp$ahvnr)),
        " unique AHV-numbers."))

    # Export new keytable to ./data/keytable folder
    name <- paste0(format(now, "%Y%m%d_%H%M%S"), "_keytable", ".csv")
    utils::write.csv(
        keytable_temp, file.path(path, "keytable", name), row.names = FALSE)

    message("Newest keytable is appended and duplicate AHV-Nr were removed,
            entries from most recent complication are kept")
  }

}
