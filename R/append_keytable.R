#' Generate and append key table
#'
#' @param df Dataframe
#' @param path Filepath
#' @param keytable_vars Variables to keep in keytable
#' @param id ID-variable that needs to by pseudonymized
#' @param pseudo_id Pseudonymized ID-variable
#' @param firstname Firstname of Person
#' @param lastname Lastname of Person
#' @param birthdate birthdate of Person
#' @return Writes or appends keytable
#' @export
append_keytable <- function(df,
                            path,
                            id,
                            pseudo_id,
                            firstname,
                            lastname,
                            birthdate,
                            file = file) {
  message(paste0("------- Append Key Table -------"))
  # Check if keytable directory already exists otherwise create
  dir.create(file.path(path, "keytable"), showWarnings = FALSE)

  # Define which variables to extract

  ####### TEST Data START
#id <- "prim_ahvnr"
#pseudo_id <- "prim_pseudo"
#firstname <- "firstname"
#lastname <- "lastname"
#birthdate <- "birthdate"
#path = file.path(data_raw_path, output_path)

n <- nrow(df)

  # Create temporary keytable
  keytable_temp <- data.table::data.table(
    ahvnr = df[[id]],
    pseudo_id = df[[pseudo_id]],
    firstname = df[[firstname]],
    lastname = df[[lastname]],
    birthdate = df[[birthdate]],
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

    # Remove duplicates based on ahvnr and birthdate
        keytable_temp <- unique(keytable_temp, by = c("ahvnr", "birthdate"))

        message(paste0(n - nrow(keytable_temp),
          " duplicates based on AHV-number and birthdate removed.
          Keytable now containts ",
          nrow(keytable_temp), " observations with ",
          length(unique(keytable_temp$ahvnr)),
          " unique AHV-numbers."))
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

    # Remove duplicates based on ahvnr and birthday
    keytable_temp <- unique(keytable_temp, by = c("ahvnr", "birthday"))

    # Remove NAs
    keytable_temp <-
          keytable_temp[complete.cases(keytable_temp[, c("ahvnr")]), ]

    message(paste0(n - nrow(keytable_temp),
        " duplicates based on AHV-number and birthdate removed.
        Keytable now containts ",
        nrow(keytable_temp), " observations with ",
        length(unique(keytable_temp$ahvnr)),
        " unique AHV-numbers."))

    # Export new keytable to ./data/keytable folder
    name <- paste0(format(now, "%Y%m%d_%H%M%S"), "_keytable", ".csv")
    utils::write.csv(
        keytable_temp, file.path(path, "keytable", name), row.names = FALSE)

    message("Newest keytable is appended and duplicate AHV-Nr and Birthday combinations were removed,
            entries from most recent complication are kept")
  }

}
