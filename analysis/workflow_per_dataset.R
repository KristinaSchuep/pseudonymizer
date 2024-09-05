# Workflow step-by-step for every data set

# Overview Datasets ---------------
## Antrag Versendet
# DS1.1: Personendaten
# DS2.1: Fallinformation
# DS3.1: Steuerdaten
# DS3.1Z: Steuerdaten Zusatz
# DS4.1: Steuerdaten QS
# DS4.1Z: Steuerdaten QS Zusatz
# DS5.1: DatenEL
# DS6.1: Daten SH

## Antrag Rückfluss
# DS1.2: Personendaten
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

# Define Year
year <- "2021"

setwd("/Volumes/pp/projects/sva-resestricted")

data_raw_path <- ("/Volumes/pp/projects/sva-restricted/data/")

output_path <- "output"

sep <- ";"
# Folder Structure:
# "data" folder contains:
# - "output" that contains:
# - - "panon"
# - - "address"
# - - "keytable"


# DS1.1: ANTRAG VERSENDET - PERSONENDATEN -------
file <- paste0("Auswertung_AntragVersendet_", year, "_Personendaten.csv")
data_new <- paste0("Versendet_Personendaten_", year)

#
# Pseudonymize, transform and drop
# See first row of data set

read.csv(file.path(data_raw_path, file),
        na.strings = c("", "NA"),
        sep = sep, fileEncoding = "iso-8859-1",
        nrows = 1)


## Step 0: Define variables -----------------------
oldnames <- c("ANT_NNSS", "ANT_FIRSTNAME", "ANT_LASTNAME", "ANT_BIRTHDATE",
                "NNSS", "FIRSTNAME", "LASTNAME", "BIRTHDATE")

newnames <-  c("prim_ahvnr", "prim_firstname", "prim_lastname", "prim_birthdate",
                "sec_ahvnr", "sec_firstname", "sec_lastname", "sec_birthdate")

sensitive_vars <- c("prim_ahvnr", "prim_firstname", "prim_lastname", "prim_birthdate",
                    "sec_ahvnr", "sec_firstname", "sec_lastname", "sec_birthdate",
                    "street", "streetnr", "egid", "ewid", "civilstatussince")


## Step 1: Import datasets into R -----------------------

# Prim stands for Primary i.e., Household head
# Sec stands for Secondary i.e., wife or children
df <- import_raw_data(file.path(data_raw_path, file),
                      oldnames = oldnames,
                      newnames = newnames,
                      sep = sep)

## Step 2: Generate unique ID from AHV-number -------------------------
df <- unique_id(data = df, id = "prim_ahvnr",
                pseudo_id = "prim_pseudo", salt = mysalt)

df <- unique_id(data = df, id = "sec_ahvnr",
                pseudo_id = "sec_pseudo", salt = mysalt)

## Step 3: Aggregate sensitive data -------------------------------
df <- aggregate_sensitive(data = df,
                            date_var = "prim_birthdate",
                            date_new_var = "prim_birthyear")

df <- aggregate_sensitive(data = df,
                            date_var = "sec_birthdate",
                            date_new_var = "sec_birthyear")

df <- aggregate_sensitive(data = df,
                          date_var = "civilstatussince",
                          date_new_var = "civilstatussince_year")

## Step 4: Create Unique Geo ID  -------------------------------
df <- unique_geo_id(df = df,
                    var_street = "street",
                    var_number = "streetnr",
                    var_plz = "zip",
                    var_egid = "egid",
                    var_ewid = "ewid")

## Step 5: Generate and append key table ---------------------------
append_keytable(df = df,
                path = paste0(data_raw_path, output_path),
                id = "prim_ahvnr",
                pseudo_id = "prim_pseudo",
                firstname = "prim_firstname",
                lastname = "prim_lastname",
                birthdate = "prim_birthdate",
                file = file)

append_keytable(df = df,
                path = paste0(data_raw_path, output_path),
                id = "sec_ahvnr",
                pseudo_id = "sec_pseudo",
                firstname = "sec_firstname",
                lastname = "sec_lastname",
                birthdate = "sec_birthdate",
                file = file)

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

file <- paste0("Auswertung_AntragVersendet_", year, "_Fallinformationen.csv")
data_new <- paste0("Versendet_Fallinformationen_", year)

read.csv(file.path(data_raw_path, file),
        na.strings = c("", "NA"),
        sep = sep, fileEncoding = "iso-8859-1",
        nrows = 1)

## Step 0: Define variables -----------------------
oldnames <- c()
newnames <- c()

sensitive_vars <- c()

## Step 1: Import datasets into R -----------------------

df <- import_raw_data(file.path(data_raw_path, file),
                      oldnames = oldnames,
                      newnames = newnames,
                      sep = sep)


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

file <- paste0("Auswertung_AntragVersendet_", year, "_Steuerdaten.csv")
data_new <- paste0("Versendet_Steuerdaten_", year)

read.csv(file.path(data_raw_path, file),
        na.strings = c("", "NA"),
        sep = sep, fileEncoding = "iso-8859-1",
        nrows = 1)

# Steuerdaten Zusatz
# It contains exactly the same variables
# Thus, we run it in parallel to avoid naming "oldnames" etc twice

file_Z <- paste0("Auswertung_AntragVersendet_", year, "_Steuerdaten_Zusatz.csv")
data_name_Z <- paste0("Versendet_Steuerdaten_Zusatz", year)

read.csv(file.path(data_raw_path, file_Z),
        na.strings = c("", "NA"),
        sep = sep, fileEncoding = "iso-8859-1",
        nrows = 1)

## Step 0: Define variables -----------------------
# Add prim_ahvnr
oldnames <- c("NNSS", "VORNAME", "FAMILIENNAME", "GEBURTSDATUM",
                "NNSSPERSON2", "VORNAMEPERSON2", "FAMILIENNAMEPERSON2", "GEBURTSDATUMPERSON2",
                "STRASSE", "HAUSNR", "PLZ", "ORT",
                "NNSSELTERNTEIL1", "NNSSELTERNTEIL2")

newnames <-  c("prim_ahvnr", "prim_firstname", "prim_lastname", "prim_birthdate",
                "sec_ahvnr", "sec_firstname", "sec_lastname", "sec_birthdate",
                "street", "streetnr", "zip", "city",
                "par1_ahvnr", "par2_ahvnr")

sensitive_vars <- c("prim_ahvnr", "prim_firstname", "prim_lastname", "prim_birthdate",
                    "sec_ahvnr", "sec_firstname", "sec_lastname", "sec_birthdate",
                    "street", "streetnr", "adresszusatz",
                    "par1_ahvnr", "par2_ahvnr")


## Step 1: Import datasets into R -----------------------

# Prim stands for Primary i.e., Household head
# Sec stands for Secondary i.e., wife or children
df <- import_raw_data(file.path(data_raw_path, file),
                      oldnames = oldnames,
                      newnames = newnames,
                      sep = sep)

## Step Z: Import datasets into R -----------------------

df_Z <- import_raw_data(file.path(data_raw_path, file_Z),
                      oldnames = oldnames,
                      newnames = newnames,
                      sep = sep)

## Step 2: Generate unique ID from AHV-number -------------------------
df <- unique_id(data = df, id = "prim_ahvnr",
                pseudo_id = "prim_pseudo", salt = mysalt)

df <- unique_id(data = df, id = "sec_ahvnr",
                pseudo_id = "sec_pseudo", salt = mysalt)

df <- unique_id(data = df, id = "par1_ahvnr",
                pseudo_id = "par1_pseudo", salt = mysalt)

df <- unique_id(data = df, id = "par2_ahvnr",
                pseudo_id = "par2_pseudo", salt = mysalt)

## Step 2Z: Generate unique ID from AHV-number -------------------------

df_Z <- unique_id(data = df_Z, id = "prim_ahvnr",
                pseudo_id = "prim_pseudo", salt = mysalt)

df_Z <- unique_id(data = df_Z, id = "sec_ahvnr",
                pseudo_id = "sec_pseudo", salt = mysalt)

df_Z <- unique_id(data = df_Z, id = "par1_ahvnr",
                pseudo_id = "par1_pseudo", salt = mysalt)

df_Z <- unique_id(data = df_Z, id = "par2_ahvnr",
                pseudo_id = "par2_pseudo", salt = mysalt)


## Step 3: Aggregate sensitive data -------------------------------
df <- aggregate_sensitive(data = df,
                            date_var = "prim_birthdate",
                            date_new_var = "prim_birthyear")

df <- aggregate_sensitive(data = df,
                            date_var = "sec_birthdate",
                            date_new_var = "sec_birthyear")

## Step 3Z: Aggregate sensitive data -------------------------------
df_Z <- aggregate_sensitive(data = df_Z,
                            date_var = "prim_birthdate",
                            date_new_var = "prim_birthyear")

df_Z <- aggregate_sensitive(data = df_Z,
                            date_var = "sec_birthdate",
                            date_new_var = "sec_birthyear")

## Step 4: Create Unique Geo ID  -------------------------------
df <- unique_geo_id(df = df,
                    var_street = "street",
                    var_number = "streetnr",
                    var_plz = "zip")

## Step 4Z: Create Unique Geo ID  -------------------------------
df_Z <- unique_geo_id(df = df_Z,
                    var_street = "street",
                    var_number = "streetnr",
                    var_plz = "zip")

## Step 5: Generate and append key table ---------------------------
append_keytable(df = df,
                path = file.path(data_raw_path, output_path),
                id = "prim_ahvnr",
                pseudo_id = "prim_pseudo",
                firstname = "prim_firstname",
                lastname = "prim_lastname",
                birthdate = "prim_birthdate",
                file = file)

append_keytable(df = df,
                path = paste0(data_raw_path, output_path),
                id = "sec_ahvnr",
                pseudo_id = "sec_pseudo",
                firstname = "sec_firstname",
                lastname = "sec_lastname",
                birthdate = "sec_birthdate",
                file = file)

## Step 5Z: Generate and append key table ---------------------------
append_keytable(df = df_Z,
                path = file.path(data_raw_path, output_path),
                id = "prim_ahvnr",
                pseudo_id = "prim_pseudo",
                firstname = "prim_firstname",
                lastname = "prim_lastname",
                birthdate = "prim_birthdate",
                file = file_Z)

append_keytable(df = df_Z,
                path = paste0(data_raw_path, output_path),
                id = "sec_ahvnr",
                pseudo_id = "sec_pseudo",
                firstname = "sec_firstname",
                lastname = "sec_lastname",
                birthdate = "sec_birthdate",
                file = file_Z)

## Step 6: Generate address file --------------------------------
# Skip this for now to reduce workload
# And because we have no survey


## Step 7: Drop sensitive data and export --------------------------------
export_pseudonymized(data = df,
                     sensitive_vars = sensitive_vars,
                     path = file.path(data_raw_path, output_path),
                     data_name = data_name,
                     data_summary = FALSE)

## Step 7Z: Drop sensitive data and export --------------------------------
export_pseudonymized(data = df_Z,
                     sensitive_vars = sensitive_vars,
                     path = file.path(data_raw_path, output_path),
                     data_name = data_name_Z,
                     data_summary = FALSE)



# DS4.1: ANTRAG VERSENDET - STEUERDATEN QS -------
# Sensitive data
# Pseudonymize, Transform and Drop
# See first row of data set

file <- paste0("Auswertung_AntragVersendet_", year, "_SteuerdatenQS.csv")
data_new <- paste0("Versendet_SteuerdatenQS_", year)

read.csv(file.path(data_raw_path, file),
        na.strings = c("", "NA"),
        sep = sep, fileEncoding = "iso-8859-1",
        nrows = 1)

# Steuerdaten Zusatz
# It contains exactly the same variables
# Thus, we run it in parallel to avoid naming "oldnames" etc twice

file_Z <- paste0("Auswertung_AntragVersendet_", year, "_SteuerdatenQS_Zusatz.csv")
data_name_Z <- paste0("Versendet_SteuerdatenQS_Zusatz_", year)

read.csv(file.path(data_raw_path, file_Z),
        na.strings = c("", "NA"),
        sep = sep, fileEncoding = "iso-8859-1",
        nrows = 1)

## Step 0: Define variables -----------------------
oldnames <- c("NNSS", "VORNAME", "FAMILIENNAME", "GEBURTSDATUM",
                "STRASSE", "HAUSNR", "PLZ", "ORT",
                "NNSSELTERNTEIL1", "NNSSELTERNTEIL2")

newnames <-  c("prim_ahvnr", "prim_firstname", "prim_lastname", "prim_birthdate",
                "street", "streetnr", "zip", "city",
                "par1_ahvnr", "par2_ahvnr")

sensitive_vars <- c("prim_ahvnr", "prim_firstname", "prim_lastname", "prim_birthdate",
                    "street", "streetnr", "adresszusatz",
                    "par1_ahvnr", "par2_ahvnr")


## Step 1: Import datasets into R -----------------------
df <- import_raw_data(file.path(data_raw_path, file),
                      oldnames = oldnames,
                      newnames = newnames,
                      sep = sep)

## Step 1Z: Import datasets into R -----------------------
df_Z <- import_raw_data(file.path(data_raw_path, file_Z),
                      oldnames = oldnames,
                      newnames = newnames,
                      sep = sep)

## Step 2: Generate unique ID from AHV-number -------------------------
df <- unique_id(data = df, id = "prim_ahvnr",
                pseudo_id = "prim_pseudo", salt = mysalt)

df <- unique_id(data = df, id = "par1_ahvnr",
                pseudo_id = "par1_pseudo", salt = mysalt)

df <- unique_id(data = df, id = "par2_ahvnr",
                pseudo_id = "par2_pseudo", salt = mysalt)

## Step 2Z: Generate unique ID from AHV-number -------------------------
df_Z <- unique_id(data = df_Z, id = "prim_ahvnr",
                pseudo_id = "prim_pseudo", salt = mysalt)

df_Z <- unique_id(data = df_Z, id = "par1_ahvnr",
                pseudo_id = "par1_pseudo", salt = mysalt)

df_Z <- unique_id(data = df_Z, id = "par2_ahvnr",
                pseudo_id = "par2_pseudo", salt = mysalt)


## Step 3: Aggregate sensitive data -------------------------------
df <- aggregate_sensitive(data = df,
                            date_var = "prim_birthdate",
                            date_new_var = "prim_birthyear")

## Step 3Z: Aggregate sensitive data -------------------------------
df_Z <- aggregate_sensitive(data = df_Z,
                            date_var = "prim_birthdate",
                            date_new_var = "prim_birthyear")

## Step 4: Create Unique Geo ID  -------------------------------
df <- unique_geo_id(df = df,
                    var_street = "street",
                    var_number = "streetnr",
                    var_plz = "zip")

## Step 4Z: Create Unique Geo ID  -------------------------------
df_Z <- unique_geo_id(df = df_Z,
                    var_street = "street",
                    var_number = "streetnr",
                    var_plz = "zip")

## Step 5: Generate and append key table ---------------------------
append_keytable(df = df,
                path = file.path(data_raw_path, output_path),
                id = "prim_ahvnr",
                pseudo_id = "prim_pseudo",
                firstname = "prim_firstname",
                lastname = "prim_lastname",
                birthdate = "prim_birthdate",
                file = file)

## Step 5: Generate and append key table ---------------------------
append_keytable(df = df_Z,
                path = file.path(data_raw_path, output_path),
                id = "prim_ahvnr",
                pseudo_id = "prim_pseudo",
                firstname = "prim_firstname",
                lastname = "prim_lastname",
                birthdate = "prim_birthdate",
                file = file_Z)


## Step 6: Generate address file --------------------------------
# Skip this for now to reduce workload
# And because we have no survey


## Step 7: Drop sensitive data and export --------------------------------
export_pseudonymized(data = df,
                     sensitive_vars = sensitive_vars,
                     path = file.path(data_raw_path, output_path),
                     data_name = data_name,
                     data_summary = FALSE)

## Step 7Z: Drop sensitive data and export --------------------------------
export_pseudonymized(data = df_Z,
                     sensitive_vars = sensitive_vars,
                     path = file.path(data_raw_path, output_path),
                     data_name = data_name_Z,
                     data_summary = FALSE)

# DS5.1: ANTRAG VERSENDET - DATENEL -------
# Sensitive data
# Pseudonymize, Transform
# See first row of data set

file <- paste0("Auswertung_AntragVersendet_", year, "_DatenEL.csv")
data_new <- paste0("Versendet_DatenEL_", year)

read.csv(file.path(data_raw_path, file),
        na.strings = c("", "NA"),
        sep = sep, fileEncoding = "iso-8859-1",
        nrows = 1)

## Step 0: Define variables -----------------------
oldnames <- c("NNSS", "BIRTHDATE",
                "NNSSELHR", "BIRTHDATEELHR")

newnames <-  c("prim_ahvnr", "prim_birthdate",
                "el_ahvnr", "el_birthdate")

sensitive_vars <- c("prim_ahvnr", "prim_birthdate",
                    "el_ahvnr", "el_birthdate")


## Step 1: Import datasets into R -----------------------

# Prim stands for Primary i.e., Household head
# Sec stands for Secondary i.e., wife or children
df <- import_raw_data(file.path(data_raw_path, file),
                      oldnames = oldnames,
                      newnames = newnames,
                      sep = sep)

## Step 2: Generate unique ID from AHV-number -------------------------

df <- unique_id(data = df, id = "prim_ahvnr",
                pseudo_id = "prim_pseudo", salt = mysalt)

df <- unique_id(data = df, id = "el_ahvnr",
                pseudo_id = "el_pseudo", salt = mysalt)

## Step 3: Aggregate sensitive data -------------------------------
df <- aggregate_sensitive(data = df,
                            date_var = "prim_birthdate",
                            date_new_var = "prim_birthyear")

df <- aggregate_sensitive(data = df,
                            date_var = "el_birthdate",
                            date_new_var = "el_birthyear")

## Step 4: Create Unique Geo ID  -------------------------------
# No Geo Data

## Step 5: Generate and append key table ---------------------------
# Skip: No name available


## Step 6: Generate address file --------------------------------
# Skip this for now to reduce workload
# And because we have no survey


## Step 7: Drop sensitive data and export --------------------------------
export_pseudonymized(data = df,
                     sensitive_vars = sensitive_vars,
                     path = file.path(data_raw_path, output_path),
                     data_name = data_new,
                     data_summary = FALSE)

# DS6.1: ANTRAG VERSENDET - DATENSH -------
# Sensitive data
# Pseudonymize, Transform, Drop
# See first row of data set

file <- paste0("Auswertung_AntragVersendet_", year, "_DatenSH.csv")
data_new <- paste0("Versendet_DatenSH_", year)

read.csv(file.path(data_raw_path, file),
        na.strings = c("", "NA"),
        sep = sep, fileEncoding = "iso-8859-1",
        nrows = 1)

## Step 0: Define variables -----------------------
oldnames <- c("NNSS", "BIRTHDATE",
                        "FIRSTNAME", "NAME")

newnames <-  c("prim_ahvnr", "prim_birthdate",
                        "prim_firstname", "prim_lastname")

sensitive_vars <- c("prim_ahvnr", "prim_birthdate",
                        "prim_firstname", "prim_lastname")


## Step 1: Import datasets into R -----------------------

# Prim stands for Primary i.e., Household head
# Sec stands for Secondary i.e., wife or children
df <- import_raw_data(file.path(data_raw_path, file),
                      oldnames = oldnames,
                      newnames = newnames,
                      sep = sep)

## Step 2: Generate unique ID from AHV-number -------------------------

df <- unique_id(data = df, id = "prim_ahvnr",
                pseudo_id = "prim_pseudo", salt = mysalt)


## Step 3: Aggregate sensitive data -------------------------------
df <- aggregate_sensitive(data = df,
                            date_var = "prim_birthdate",
                            date_new_var = "prim_birthyear")

## Step 4: Create Unique Geo ID  -------------------------------
# No Geo Data

## Step 5: Generate and append key table ---------------------------
append_keytable(df = df,
                path = file.path(data_raw_path, output_path),
                id = "prim_ahvnr",
                pseudo_id = "prim_pseudo",
                firstname = "prim_firstname",
                lastname = "prim_lastname",
                birthdate = "prim_birthdate",
                file = file)

## Step 6: Generate address file --------------------------------
# Skip this for now to reduce workload
# And because we have no survey


## Step 7: Drop sensitive data and export --------------------------------
export_pseudonymized(data = df,
                     sensitive_vars = sensitive_vars,
                     path = file.path(data_raw_path, output_path),
                     data_name = data_new,
                     data_summary = FALSE)

# DS1.2: ANTRAG RÜCKFLUSS - PERSONENDATEN -------
file <- paste0("Auswertung_AntragRueckfluss_", year, "_Personendaten.csv")
new_name <- paste0("Rueckfluss_Personendaten_", year)

# Pseudonymize, transform and drop
# See first row of data set

read.csv(file.path(data_raw_path, file),
        na.strings = c("", "NA"),
        sep = sep, fileEncoding = "iso-8859-1",
        nrows = 1)


## Step 0: Define variables -----------------------
oldnames <- c("ANT_NNSS", "ANT_FIRSTNAME", "ANT_LASTNAME", "ANT_BIRTHDATE",
                "FAM_NNSS", "FAM_FIRSTNAME", "FAM_LASTNAME", "FAM_BIRTHDATE")

newnames <-  c("prim_ahvnr", "prim_firstname", "prim_lastname", "prim_birthdate",
                "sec_ahvnr", "sec_firstname", "sec_lastname", "sec_birthdate")

sensitive_vars <- c("prim_ahvnr", "prim_firstname", "prim_lastname", "prim_birthdate",
                    "sec_ahvnr", "sec_firstname", "sec_lastname", "sec_birthdate")


## Step 1: Import datasets into R -----------------------
df <- import_raw_data(file.path(data_raw_path, file),
                      oldnames = oldnames,
                      newnames = newnames,
                      sep = sep)

## Step 2: Generate unique ID from AHV-number -------------------------
df <- unique_id(data = df, id = "prim_ahvnr",
                pseudo_id = "prim_pseudo", salt = mysalt)

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
# no geo info

## Step 5: Generate and append key table ---------------------------
append_keytable(df = df,
                path = paste0(data_raw_path, output_path),
                id = "prim_ahvnr",
                pseudo_id = "prim_pseudo",
                firstname = "prim_firstname",
                lastname = "prim_lastname",
                birthdate = "prim_birthdate",
                file = file)

append_keytable(df = df,
                path = paste0(data_raw_path, output_path),
                id = "sec_ahvnr",
                pseudo_id = "sec_pseudo",
                firstname = "sec_firstname",
                lastname = "sec_lastname",
                birthdate = "sec_birthdate",
                file = file)

## Step 6: Generate address file --------------------------------
# Skip this for now to reduce workload
# And because we have no survey


## Step 7: Drop sensitive data and export --------------------------------
export_pseudonymized(data = df,
                     sensitive_vars = sensitive_vars,
                     path = file.path(data_raw_path, output_path),
                     data_name = data_name,
                     data_summary = FALSE)

# DS2.2: ANTRAG RÜCKFLUSS - FALLINFORMATION -------

# No sensitive data
# Nothing to pseudonymize, transform or drop
# Import (to transform colnames) and Export
# See first row of data set

file <- paste0("Auswertung_AntragRueckfluss_", year, "_Fallinformationen.csv")
data_new <- paste0("Rueckfluss_Fallinformationen_", year)

read.csv(file.path(data_raw_path, file),
        na.strings = c("", "NA"),
        sep = sep, fileEncoding = "iso-8859-1",
        nrows = 1)

## Step 0: Define variables -----------------------
oldnames <- c()
newnames <- c()

sensitive_vars <- c()

## Step 1: Import datasets into R -----------------------

df <- import_raw_data(file.path(data_raw_path, file),
                      oldnames = oldnames,
                      newnames = newnames,
                      sep = sep)


## Step 2: Generate unique ID from AHV-number -------------------------


## Step 3: Aggregate sensitive data -------------------------------

## Step 4: Create Unique Geo ID  -------------------------------
# skip

## Step 5: Generate and append key table ---------------------------
# add prim_ahvnr and sec_ahvnr

## Step 6: Generate address file --------------------------------
# skip

## Step 7: Drop sensitive data and export --------------------------------
export_pseudonymized(data = df,
                     sensitive_vars = sensitive_vars,
                     path = file.path(data_raw_path, output_path),
                     data_name = data_name,
                     data_summary = FALSE)


# DS3.2: ANTRAG RÜCKFLUSS - STEUERDATEN -------
# Sensitive data
# Pseudonymize, Transform and Drop
# See first row of data set

file <- paste0("Auswertung_AntragRueckfluss_", year, "_Steuerdaten.csv")
data_new <- paste0("Rueckfluss_Steuerdaten_", year)

read.csv(file.path(data_raw_path, file),
        na.strings = c("", "NA"),
        sep = sep, fileEncoding = "iso-8859-1",
        nrows = 1)

## Step 0: Define variables -----------------------
# Add prim_ahvnr
oldnames <- c("NNSS", "VORNAME", "FAMILIENNAME", "GEBURTSDATUM",
                "NNSSPERSON2", "VORNAMEPERSON2", "FAMILIENNAMEPERSON2", "GEBURTSDATUMPERSON2",
                "STRASSE", "HAUSNR", "PLZ", "ORT",
                "NNSSELTERNTEIL1", "NNSSELTERNTEIL2")

newnames <-  c("prim_ahvnr", "prim_firstname", "prim_lastname", "prim_birthdate",
                "sec_ahvnr", "sec_firstname", "sec_lastname", "sec_birthdate",
                "street", "streetnr", "zip", "city",
                "par1_ahvnr", "par2_ahvnr")

sensitive_vars <- c("prim_ahvnr", "prim_firstname", "prim_lastname", "prim_birthdate",
                    "sec_ahvnr", "sec_firstname", "sec_lastname", "sec_birthdate",
                    "street", "streetnr", "adresszusatz",
                    "par1_ahvnr", "par2_ahvnr")

## Step 1: Import datasets into R -----------------------

df <- import_raw_data(file.path(data_raw_path, file),
                      oldnames = oldnames,
                      newnames = newnames,
                      sep = sep)

## Step 2: Generate unique ID from AHV-number -------------------------
df <- unique_id(data = df, id = "prim_ahvnr",
                pseudo_id = "prim_pseudo", salt = mysalt)

df <- unique_id(data = df, id = "sec_ahvnr",
                pseudo_id = "sec_pseudo", salt = mysalt)

df <- unique_id(data = df, id = "par1_ahvnr",
                pseudo_id = "par1_pseudo", salt = mysalt)

df <- unique_id(data = df, id = "par2_ahvnr",
                pseudo_id = "par2_pseudo", salt = mysalt)


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
                id = "prim_ahvnr",
                pseudo_id = "prim_pseudo",
                firstname = "prim_firstname",
                lastname = "prim_lastname",
                birthdate = "prim_birthdate",
                file = file)

append_keytable(df = df,
                path = file.path(data_raw_path, output_path),
                id = "sec_ahvnr",
                pseudo_id = "sec_pseudo",
                firstname = "sec_firstname",
                lastname = "sec_lastname",
                birthdate = "sec_birthdate",
                file = file)


## Step 6: Generate address file --------------------------------
# Skip this for now to reduce workload
# And because we have no survey


## Step 7: Drop sensitive data and export --------------------------------
export_pseudonymized(data = df,
                     sensitive_vars = sensitive_vars,
                     path = file.path(data_raw_path, output_path),
                     data_name = data_name,
                     data_summary = FALSE)


# DS4.2: ANTRAG RÜCKFLUSS  - STEUERDATEN QS -------
# Sensitive data
# Pseudonymize, Transform and Drop
# See first row of data set

file <- paste0("Auswertung_AntragRueckfluss_", year, "_SteuerdatenQS.csv")
data_new <- paste0("Rueckfluss_SteuerdatenQS_", year)

read.csv(file.path(data_raw_path, file),
        na.strings = c("", "NA"),
        sep = sep, fileEncoding = "iso-8859-1",
        nrows = 1)

## Step 0: Define variables -----------------------
oldnames <- c("NNSS", "VORNAME", "FAMILIENNAME", "GEBURTSDATUM",
                "STRASSE", "HAUSNR", "PLZ", "ORT",
                "NNSSELTERNTEIL1", "NNSSELTERNTEIL2")

newnames <-  c("prim_ahvnr", "prim_firstname", "prim_lastname", "prim_birthdate",
                "street", "streetnr", "zip", "city",
                "par1_ahvnr", "par2_ahvnr")

sensitive_vars <- c("prim_ahvnr", "prim_firstname", "prim_lastname", "prim_birthdate",
                    "street", "streetnr", "adresszusatz",
                    "par1_ahvnr", "par2_ahvnr")


## Step 1: Import datasets into R -----------------------

# Prim stands for Primary i.e., Household head
# Sec stands for Secondary i.e., wife or children
df <- import_raw_data(file.path(data_raw_path, file),
                      oldnames = oldnames,
                      newnames = newnames,
                      sep = sep)

## Step 2: Generate unique ID from AHV-number -------------------------
df <- unique_id(data = df, id = "prim_ahvnr",
                pseudo_id = "prim_pseudo", salt = mysalt)

df <- unique_id(data = df, id = "par1_ahvnr",
                pseudo_id = "par1_pseudo", salt = mysalt)

df <- unique_id(data = df, id = "par2_ahvnr",
                pseudo_id = "par2_pseudo", salt = mysalt)


## Step 3: Aggregate sensitive data -------------------------------
df <- aggregate_sensitive(data = df,
                            date_var = "prim_birthdate",
                            date_new_var = "prim_birthyear")

## Step 4: Create Unique Geo ID  -------------------------------
df <- unique_geo_id(df = df,
                    var_street = "street",
                    var_number = "streetnr",
                    var_plz = "zip")

## Step 5: Generate and append key table ---------------------------
append_keytable(df = df,
                path = file.path(data_raw_path, output_path),
                id = "prim_ahvnr",
                pseudo_id = "prim_pseudo",
                firstname = "prim_firstname",
                lastname = "prim_lastname",
                birthdate = "prim_birthdate",
                file = file)



## Step 6: Generate address file --------------------------------
# Skip this for now to reduce workload
# And because we have no survey


## Step 7: Drop sensitive data and export --------------------------------
export_pseudonymized(data = df,
                     sensitive_vars = sensitive_vars,
                     path = file.path(data_raw_path, output_path),
                     data_name = data_new,
                     data_summary = FALSE)




## END ---------
