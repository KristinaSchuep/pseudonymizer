# Workflow step-by-step

salt <- "myverygoodsalt"

## Population data --------------------------------------------------------

oldnames <- c("NNSS","NACHNAME","VORNAME","GEBURTSDATUM")
newnames <-  c("ahvnr","firstname","surname","birthday")
id <- "ahvnr"
sensitive <- c("ahvnr","firstname","surname","birthday")
address_vars <- c('pseudo_id', 'firstname', 'surname', 'plz', 'wohnort')

# Import datasets into R -----------------------
df <- import_raw_data(filename = "./data-raw/FAKE_DATA_2019.xlsx",
                      oldnames = oldnames,
                      newnames = newnames)

# Generate unique ID from AHV-number -------------------------
df <- unique_id(data = df, id = id, salt = salt)

# Aggregate sensitive data -------------------------------
df <- aggregate_sensitive(data = df)

# Generate and append key table ---------------------------
append_keytable(df = df,
                path = "output",
                sensitive = sensitive,
                id_original = id)

# Generate address file --------------------------------
export_address(data = df,
               path = "output",
               data_name = 'FAKE_DATA',
               vars = address_vars)

# Drop sensitive data and export --------------------------------
export_pseudonymized(data = df,
                     sensitive = sensitive,
                     path = "output",
                     data_name = "FAKE_DATA",
                     data_summary = TRUE)


## Verlustscheine ------------------------------------------------------

source("analysis/varnames.R")
id <- "ahvnr"
sensitive <- c("ahvnr","firstname","surname","birthday")
address_vars <- c('pseudo_id', 'firstname', 'surname', 'plz', 'wohnort')

# Check whether the colnames of imported file are the same as 'oldnames'
# If not: change 'oldnames' and 'newnames' where necessary.
df <- check_colnames("data-raw/FAKE_Verlustscheine.xlsx",
                     sheet = "Schlussabrechnung",
                     skip = 1,
                     oldnames = oldnames,
                     newnames = newnames)

# Import datasets into R -----------------------
df <- import_raw_data(filename = "data-raw/FAKE_Verlustscheine.xlsx",
                      sheetname = "Schlussabrechnung",
                      skiprows = 1,
                      oldnames = oldnames,
                      newnames = newnames)

# Generate unique ID from AHV-number -------------------------
df <- unique_id(data = df, id = id, salt = salt)

# Aggregate sensitive data -------------------------------
df <- aggregate_sensitive(data = df)

# Generate and append key table ---------------------------
append_keytable(df = df,
                path = "output",
                sensitive = sensitive,
                id_original = id)

# Generate address file --------------------------------
export_address(data = df,
               path = "output",
               data_name = 'FAKE_DATA',
               vars = address_vars)

# Drop sensitive data and export --------------------------------
export_pseudonymized(data = df,
                     sensitive = sensitive,
                     path = "output",
                     data_name = "FAKE_DATA",
                     data_summary = TRUE)




# df <- import_raw_data("./data-raw/FAKE_Verlustscheine.xlsx", "Assura",1)
#
# df <- import_raw_data("./data-raw/FAKE_Verlustscheine.xlsx", "Nicht-Sedex",1)

