# Workflow step-by-step

mysalt <- "myverygoodsalt"
id <- "ahvnr"
address_vars <- c('pseudo_id', 'firstname', 'surname', 'plz', 'wohnort')
keytable_vars <- c("ahvnr","firstname","surname","birthday", "plz", "wohnort")
sensitive_vars <- c("ahvnr","firstname","surname","birthday", "plz", "wohnort")

## Population data --------------------------------------------------------

oldnames <- c("NNSS","NACHNAME","VORNAME","GEBURTSDATUM")
newnames <-  c("ahvnr","firstname","surname","birthday")

# Import datasets into R -----------------------
df <- import_raw_data(filename = "./data-raw/FAKE_DATA_2020.xlsx",
                      oldnames = oldnames,
                      newnames = newnames)

# Generate unique ID from AHV-number -------------------------
df <- unique_id(data = df, id = id, salt = mysalt)

# Aggregate sensitive data -------------------------------
df <- aggregate_sensitive(data = df)

# Generate and append key table ---------------------------
append_keytable(df = df,
                path = "output",
                keytable_vars = keytable_vars,
                id_original = id)

# Generate address file --------------------------------
export_address(data = df,
               path = "output",
               data_name = 'FAKE_DATA',
               vars = address_vars)

# Drop sensitive data and export --------------------------------
export_pseudonymized(data = df,
                     sensitive_vars = sensitive_vars,
                     path = "output",
                     data_name = "FAKE_DATA",
                     data_summary = TRUE)


## Verlustscheine ------------------------------------------------------

# Load variable names
# (These are just two long vectors. They are in a separate script for convenience.)
source("analysis/varnames.R")

# Check whether the colnames of imported file are the same as 'oldnames'
# If not: change 'oldnames' and 'newnames' where necessary.
df <- check_colnames("data-raw/FAKE_Verlustscheine.xlsx",
                     sheet = "Schlussabrechnung",
                     skip = 1,
                     oldnames = oldnames,
                     newnames = newnames)

address_vars <- c('pseudo_id', 'firstname', 'surname', 'plz', 'wohnort')
keytable_vars <- c("ahvnr","firstname","surname","birthday", "plz", "wohnort")
sensitive_vars <- c("ahvnr","debtor_surname", "debtor_firstname", "debtor_street",
                    "debtor_street_nr","debtor_plz","debtor_wohnort",
                    "firstname","surname","birthday","street","street_nr","plz","wohnort")

# Import datasets into R -----------------------
df <- import_raw_data(filename = "data-raw/FAKE_Verlustscheine.xlsx",
                      sheetname = "Schlussabrechnung",
                      skiprows = 1,
                      oldnames = oldnames,
                      newnames = newnames)

# Generate unique ID from AHV-number -------------------------
df <- unique_id(data = df, id = "ahvnr", salt = mysalt)

# Aggregate sensitive data -------------------------------
df <- aggregate_sensitive(data = df)

# Generate and append key table ---------------------------
append_keytable(df = df,
                path = "output",
                keytable_vars = keytable_vars,
                id_original = "ahvnr")

# Generate address file --------------------------------
# no adress export for 'Verlustscheine'

# Drop sensitive data and export --------------------------------
result <- export_pseudonymized(data = df,
                     sensitive_vars = sensitive_vars,
                     path = "output",
                     data_name = "Verlustscheine",
                     data_summary = TRUE)




# df <- import_raw_data("./data-raw/FAKE_Verlustscheine.xlsx", "Assura",1)
#
# df <- import_raw_data("./data-raw/FAKE_Verlustscheine.xlsx", "Nicht-Sedex",1)

