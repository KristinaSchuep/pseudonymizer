# Workflow step-by-step for every data set

# Antrag Versendet-------------
# DS1.1: Personendaten
# DS2.1: Fallinformation
# DS3.1: Steuerdaten
# DS4.1: Steuerdaten QS
# DS5.1: DatenEL
# DS6.1: Daten SH

# Antrag Rückfluss-------------
# DS2.2: Fallinformation
# DS3.2: Steuerdaten
# DS4.2: Steuerdaten QS


# Import newest version of package
devtools::install_github("KristinaSchuep/pseudonymizer")
library(pseudonymizer)

# Set Environment
mysalt<- as.character(read.delim("salt.txt", header = FALSE, sep = "", dec = "."))

#for testing use this simple salt
#mysalt <- "myverygoodsalt"


setwd("/Volumes/pp/projects/sva-research/data_raw/2023-06-09")

## DS1.1: ANTRAG VERSENDET - PERSONENDATEN -------
# Step 0: Define variables
id <- "ahvnr"
path <- "output"
address_vars <- c("pseudo_id", "firstname", "surname", "street", "streetnr", "zip", "city")
keytable_vars <- c("ahvnr", "firstname", "surname", "birthday", "street", "streetnr", "zip", "city")
sensitive_vars <- c("ahvnr", "firstname", "surname", "birthday", "street", "streetnr", "zip", "city", "egid", "ewid")


# ------- Start recording
#sink(paste0(path, "/log/PS_", format(Sys.time(), "%Y%m%d_%H%M%S"), ".txt"))
#sink(stdout(), type = "message")


# Step 1: Import datasets into R -----------------------
oldnames <- c("ANT_NNSS", "ANT_FIRSTNAME", "ANT_LASTNAME", "FIRSTNAME", "LASTNAME")
#possibly additional NNSS necessary

newnames <-  c("appl_ahvnr", "appl_firstname", "appl_surname", "firstname", "surname")
df <- import_raw_data(filename = "./data-raw/FAKE_DATA_AHV_2019.csv",
                      oldnames = oldnames,
                      newnames = newnames)

df <- import_raw_data(filename = "./Auswertung_AntragVersendet_2021_Personendaten.csv",
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
                path = path,
                keytable_vars = keytable_vars,
                id = id)

# Step 6: Generate address file --------------------------------
export_address(data = df,
               path = path,
               data_name = 'FAKE_DATA',
               vars = address_vars)

# Step 7: Drop sensitive data and export --------------------------------
export_pseudonymized(data = df,
                     sensitive_vars = sensitive_vars,
                     path = path,
                     data_name = "FAKE_DATA",
                     data_summary = FALSE)

# ------- End recording
#sink(NULL,type="message")
#sink()

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
keytable_vars <- c("ahvnr", "firstname", "surname", "birthday", "plz", "wohnort")
sensitive_vars <- c("ahvnr", "debtor_surname", "debtor_firstname", "debtor_street",
                    "debtor_street_nr", "debtor_plz", "debtor_wohnort",
                    "firstname", "surname", "birthday", "street", "street_nr", "plz", "wohnort")

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

## DS2.1: ANTRAG VERSENDET - FALLINFORMATION -------

## DS3.1: ANTRAG VERSENDET - STEUERDATEN -------

## DS4.1: ANTRAG VERSENDET - STEUERDATEN QS -------

## DS5.1: ANTRAG VERSENDET - DATENEL -------

## DS6.1: ANTRAG VERSENDET - DATENSH -------

## DS2.2: ANTRAG RÜCKFLUSS - FALLINFORMATION -------

## DS3.2: ANTRAG RÜCKFLUSS - STEUERDATEN -------

## DS4.2: ANTRAG RÜCKFLUSS  - STEUERDATEN QS -------




## END ---------