# Workflow step-by-step for every data set

# Overview Datasets ---------------
## Antrag Versendet
# DS1.1: Personendaten
# DS2.1: Fallinformation
# DS3.1: Steuerdaten
# DS4.1: Steuerdaten QS
# DS5.1: DatenEL
# DS6.1: Daten SH

## Antrag Rückfluss
# DS2.2: Fallinformation
# DS3.2: Steuerdaten
# DS4.2: Steuerdaten QS


# Import newest version of package
devtools::install_github("KristinaSchuep/pseudonymizer")
library(pseudonymizer)

# Set Environment
mysalt <- as.character(read.delim("salt.txt", header = FALSE, sep = "", dec = "."))

#for testing use this simple salt
#mysalt <- "myverygoodsalt"

#setwd("/Users/flhug/Dropbox (PP)/PhD/Courses/H4Sci_Project/Git/pseudonymizer")
setwd("/Volumes/pp/projects/sva-research")

data_raw_path <- ("/Volumes/pp/projects/sva-research/data/original data/test data")
output_path <- "output"


# DS1.1: ANTRAG VERSENDET - PERSONENDATEN -------
file <- "Auswertung_AntragVersendet_20XX_Personendaten.csv"
data_name <- "Versendet_Personendaten_2021"

# No sensitive data
# Nothing to pseudonymize
# Only transformation and drops necessary
# See first row of data set

read.csv(file.path(data_raw_path, file),
        na.strings = c("", "NA"),
        sep = ';', fileEncoding = "iso-8859-1",
        nrows = 1)
        

## Step 0: Define variables -----------------------
# id <- c("prim_ahvnr", "sec_ahvnr")
oldnames <- c("ANT_FIRSTNAME", "ANT_LASTNAME",
                "FIRSTNAME", "LASTNAME", "BIRTHDATE")

newnames <-  c("prim_firstname", "prim_surname",
                "sec_firstname", "sec_surname", "sec_birthdate")

keytable_vars <- c("prim_firstname", "prim_surname",
                    "sec_firstname", "sec_surname", "sec_birthdate",
                    "street", "streetnr", "zip", "city")

sensitive_vars <- c("prim_firstname", "prim_surname",
                    "sec_firstname", "sec_surname", "sec_birthdate",
                    "street", "streetnr", "egid", "ewid")


## Step 1: Import datasets into R -----------------------

# Prim stands for Primary i.e., Household head
# Sec stands for Secondary i.e., wife or children
df <- import_raw_data(file.path(data_raw_path, file),
                      oldnames = oldnames,
                      newnames = newnames)

## Step 2: Generate unique ID from AHV-number -------------------------
# df <- unique_id(data = df, id = id, salt = mysalt)

## Step 3: Aggregate sensitive data -------------------------------
df <- aggregate_sensitive(data = df,
                            date_var = "sec_birthdate",
                            date_new_var = "sec_birthyear")

## Step 4: Create Unique Geo ID  -------------------------------
df <- unique_geo_id(df = df,
                    var_street = "street",
                    var_number = "streetnr",
                    var_plz = "zip",
                    var_egid = "egid",
                    var_ewid = "ewid")

## Step 5: Generate and append key table ---------------------------
# Skip for now
# Because there is no ID atm

## Step 6: Generate address file --------------------------------
# Skip this for now to reduce workload
# And because we have no survey


## Step 7: Drop sensitive data and export --------------------------------
export_pseudonymized(data = df,
                     sensitive_vars = sensitive_vars,
                     path = file.path(data_raw_path, output_path),
                     data_name = data_name,
                     data_summary = FALSE)


# DS2.1: ANTRAG VERSENDET - FALLINFORMATION -------

# No sensitive data
# Nothing to pseudonymize, transform or drop
# See first row of data set

file <- "Auswertung_AntragVersendet_20XX_Fallinformationen.csv"
data_name <- "Versendet_Fallinformation_2021"

read.csv(file.path(data_raw_path, file),
        na.strings = c("", "NA"),
        sep = ';', fileEncoding = "iso-8859-1",
        nrows = 1)

## Step 0: Define variables -----------------------
oldnames <- c()
newnames <- c()

sensitive_vars <- c()

## Step 1: Import datasets into R -----------------------

df <- import_raw_data(file.path(data_raw_path, file),
                      oldnames = oldnames,
                      newnames = newnames)


## Step 2: Generate unique ID from AHV-number -------------------------
# skip

## Step 3: Aggregate sensitive data -------------------------------
# skip

## Step 4: Create Unique Geo ID  -------------------------------
# skip

## Step 5: Generate and append key table ---------------------------
# skip

## Step 6: Generate address file --------------------------------
# skip

## Step 7: Drop sensitive data and export --------------------------------
export_pseudonymized(data = df,
                     sensitive_vars = sensitive_vars,
                     path = file.path(data_raw_path, output_path),
                     data_name = data_name,
                     data_summary = FALSE)

# DS3.1: ANTRAG VERSENDET - STEUERDATEN -------
# Sensitive data
# Pseudonymize, Transform and Drop
# See first row of data set

file <- "Auswertung_AntragVersendet_20XX_Steuerdaten.csv"
data_name <- "Rueckfluss_Steuerdaten_2021"

read.csv(file.path(data_raw_path, file),
        na.strings = c("", "NA"),
        sep = ';', fileEncoding = "iso-8859-1",
        nrows = 1)
## Step 0: Define variables -----------------------
# id <- c("prim_ahvnr", "sec_ahvnr")
oldnames <- c("VORNAME", "FAMILIENNAME", "GEBURTSDATUM",
                "NNSSPERSON2", "VORNAMEPERSON2", "FAMILIENNAMEPERSON2", "GEBURTSDATUMPERSON2",
                "STRASSE", "HAUSNR", "PLZ")

newnames <-  c("prim_firstname", "prim_surname", "prim_birthdate",
                "sec_ahvnr", "sec_firstname", "sec_surname", "sec_birthdate",
                "street", "streetnr", "zip")

#keytable_vars_prim <- c("prim_firstname", "prim_surname",
#                    "street", "streetnr", "zip", "city")

keytable_vars_sec <- c("sec_pseudo", "sec_ahvnr", "sec_firstname", "sec_surname", "sec_birthdate",
                    "street", "streetnr", "zip", "city")                    

sensitive_vars <- c("prim_firstname", "prim_surname", "prim_birthdate",
                    "sec_ahvnr", "sec_firstname", "sec_surname", "sec_birthdate",
                    "street", "streetnr", "egid", "ewid")


## Step 1: Import datasets into R -----------------------

# Prim stands for Primary i.e., Household head
# Sec stands for Secondary i.e., wife or children
df <- import_raw_data(file.path(data_raw_path, file),
                      oldnames = oldnames,
                      newnames = newnames)

## Step 2: Generate unique ID from AHV-number -------------------------
#df[1:5, "sec_ahvnr"] <- c("756.1234.5678.01", "756.1234.5678.02", "756.1234.5678.03", "756.1234.5678.04", "756.1234.5678.05")
df <- unique_id(data = df, id = "sec_ahvnr",
                pseudo_id = "sec_pseudo", salt = mysalt)


## Step 3: Aggregate sensitive data -------------------------------
df <- aggregate_sensitive(data = df,
                            date_var = "prim_birthdate",
                            date_new_var = "prim_birthyear")

df <- aggregate_sensitive(data = df,
                            date_var = "sec_birthdate",
                            date_new_var = "sec_birthyear")

## Step 4: Create Unique Geo ID  -------------------------------
df <- unique_geo_id(df = df,
                    var_street = "street",
                    var_number = "streetnr",
                    var_plz = "zip")

## Step 5: Generate and append key table ---------------------------
append_keytable(df = df,
                path = file.path(data_raw_path, output_path),
                keytable_vars = keytable_vars_sec,
                id = "sec_ahvnr",
                pseudo_id = "sec_pseudo")

## Step 6: Generate address file --------------------------------
# Skip this for now to reduce workload
# And because we have no survey


## Step 7: Drop sensitive data and export --------------------------------
export_pseudonymized(data = df,
                     sensitive_vars = sensitive_vars,
                     path = file.path(data_raw_path, output_path),
                     data_name = data_name,
                     data_summary = FALSE)



# DS4.1: ANTRAG VERSENDET - STEUERDATEN QS -------

# DS5.1: ANTRAG VERSENDET - DATENEL -------

# DS6.1: ANTRAG VERSENDET - DATENSH -------

# DS2.2: ANTRAG RÜCKFLUSS - FALLINFORMATION -------

# No sensitive data
# Nothing to pseudonymize, transform or drop
# Import (to transform colnames) and Export
# See first row of data set

file <- "Auswertung_AntragRueckfluss_20XX_Fallinformationen.csv"
data_name <- "Rueckfluss_Fallinformation_2021"

read.csv(file.path(data_raw_path, file),
        na.strings = c("", "NA"),
        sep = ';', fileEncoding = "iso-8859-1",
        nrows = 1)

## Step 0: Define variables -----------------------
oldnames <- c()
newnames <- c()

sensitive_vars <- c()

## Step 1: Import datasets into R -----------------------

df <- import_raw_data(file.path(data_raw_path, file),
                      oldnames = oldnames,
                      newnames = newnames)


## Step 2: Generate unique ID from AHV-number -------------------------
# skip

## Step 3: Aggregate sensitive data -------------------------------
# skip

## Step 4: Create Unique Geo ID  -------------------------------
# skip

## Step 5: Generate and append key table ---------------------------
# skip

## Step 6: Generate address file --------------------------------
# skip

## Step 7: Drop sensitive data and export --------------------------------
export_pseudonymized(data = df,
                     sensitive_vars = sensitive_vars,
                     path = file.path(data_raw_path, output_path),
                     data_name = data_name,
                     data_summary = FALSE)


# DS3.2: ANTRAG RÜCKFLUSS - STEUERDATEN -------

# DS4.2: ANTRAG RÜCKFLUSS  - STEUERDATEN QS -------




## END ---------