# Workflow step-by-step
# Import newest version of package
devtools::install_github("KristinaSchuep/pseudonymizer")
library(pseudonymizer)

# Step 0: Define variables
mysalt<- as.character(read.delim("salt.txt",header=FALSE, sep = "", dec="."))

#for testing use this simple salt
#mysalt <- "myverygoodsalt"

id <- "ahvnr"
address_vars <- c('pseudo_id', 'firstname', 'surname', 'strasse', 'hausnr','plz4', 'wohnort')
keytable_vars <- c("ahvnr","firstname","surname","birthday","strasse","hausnr", "plz", "wohnort")
sensitive_vars <- c("ahvnr","firstname","surname","birthday","strasse","hausnr", "plz", "wohnort","egid","ewid")
oldnames <- c("NNSS","VORNAME","NACHNAME","GEBURTSDATUM")
newnames <-  c("ahvnr","firstname","surname","birthday")

# Step 1: Import datasets into R -----------------------
df <- import_raw_data(filename = "./data-raw/FAKE_DATA_2019.csv",
                      oldnames = oldnames,
                      newnames = newnames)

# Step 2: Generate unique ID from AHV-number -------------------------
df <- unique_id(data = df, id = id, salt = mysalt)

# Step 3: Aggregate sensitive data -------------------------------
df <- aggregate_sensitive(data = df)

# Step 4: Create Unique Geo ID  -------------------------------
df <- unique_geo_id(df = df)

# Step 5: Generate and append key table ---------------------------
append_keytable(df = df,
                path = "output",
                keytable_vars = keytable_vars,
                id_original = id)

# Step 6: Generate address file --------------------------------
export_address(data = df,
               path = "output",
               data_name = 'FAKE_DATA',
               vars = address_vars)

# Step 7: Drop sensitive data and export --------------------------------
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

