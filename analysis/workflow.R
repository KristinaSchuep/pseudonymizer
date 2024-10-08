# Workflow
# Import newest version of package
devtools::install_github("KristinaSchuep/pseudonymizer")
library(pseudonymizer)

# Step 0: Define variables
mysalt<- as.character(read.delim("salt.txt",header=FALSE, sep = "", dec="."))

#for testing use this simple salt
#mysalt <- "myverygoodsalt"

id <- "ahvnr"
path <- "output"
address_vars <- c('pseudo_id', 'firstname', 'surname', 'strasse', 'hausnr','plz4', 'wohnort')
keytable_vars <- c("ahvnr","firstname","surname","birthday","strasse","hausnr", "plz", "wohnort")
sensitive_vars <- c("ahvnr","firstname","surname","birthday","strasse","hausnr", "plz", "wohnort","egid","ewid")
oldnames <- c("NNSS","VORNAME","NACHNAME","GEBURTSDATUM")
newnames <-  c("ahvnr","firstname","surname","birthday")

# ------- Start recording
sink(paste0(path,"/log/PS_", format(Sys.time(),"%Y%m%d_%H%M%S"),".txt"))
sink(stdout(), type = "message")

df <- pseudonymize(data_name = "FAKE_DATA_2019",
                   import_filename = "data-raw/FAKE_DATA_2019.csv",
                   import_oldnames = oldnames,
                   import_newnames = newnames,
                   id = id,
                   id_salt = mysalt,
                   path = path,
                   address_vars =  address_vars,
                   keytable_vars = keytable_vars,
                   sensitive_vars = sensitive_vars)

df <- pseudonymize(data_name = "FAKE_DATA_2020",
                   import_filename = "data-raw/FAKE_DATA_2020.xlsx",
                   import_oldnames = oldnames,
                   import_newnames = newnames,
                   id = id,
                   id_salt = mysalt,
                   path = path,
                   address_vars =  address_vars,
                   keytable_vars = keytable_vars,
                   sensitive_vars = sensitive_vars)
# View(df) to inspect exported data

df <- pseudonymize(data_name = "FAKE_DATA_2021",
                   import_filename = "data-raw/FAKE_DATA_2021.xlsx",
                   import_oldnames = oldnames,
                   import_newnames = newnames,
                   id = id,
                   id_salt = mysalt,
                   path = path,
                   address_vars =  address_vars,
                   keytable_vars = keytable_vars,
                   sensitive_vars = sensitive_vars)
# View(df) to inspect exported data

# ------- End recording
sink(NULL,type="message")


# Verlustscheine: 'Schlussabrechnung' ------------------------------------------

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

# If check is successful:
address_vars <- c('pseudo_id', 'firstname', 'surname', 'plz', 'wohnort')
keytable_vars <- c("ahvnr","firstname","surname","birthday", "plz", "wohnort")
sensitive_vars <- c("ahvnr","debtor_surname", "debtor_firstname", "debtor_street",
                    "debtor_street_nr","debtor_plz","debtor_wohnort",
                    "firstname","surname","birthday","street","street_nr","plz","wohnort")

df <- pseudonymize(data_name = "FAKE_Verlustscheine_Schlussabrechnung",
                   import_filename = "data-raw/FAKE_Verlustscheine.xlsx",
                   import_sheetname = "Schlussabrechnung",
                   import_skiprows = 1,
                   import_oldnames = oldnames,
                   import_newnames = newnames,
                   id_original = "ahvnr",
                   id_salt = mysalt,
                   export_path = "output",
                   export_address = FALSE,
                   address_vars = address_vars,
                   keytable_vars = keytable_vars,
                   sensitive_vars = sensitive_vars)
# View(df) to inspect exported data


# Verlustscheine: 'Assura' ------------------------------------------

# Load variable names
# (These are just two long vectors. They are in a separate script for convenience.)
source("analysis/varnames.R")

# Check whether the colnames of imported file are the same as 'oldnames'
# If not: change 'oldnames' and 'newnames' where necessary.
df <- check_colnames("data-raw/FAKE_Verlustscheine.xlsx",
                     sheet = "Assura",
                     skip = 1,
                     oldnames = oldnames,
                     newnames = newnames)

# If check is successful:
address_vars <- c('pseudo_id', 'firstname', 'surname', 'plz', 'wohnort')
keytable_vars <- c("ahvnr","firstname","surname","birthday", "plz", "wohnort")
sensitive_vars <- c("ahvnr","debtor_surname", "debtor_firstname", "debtor_street",
                    "debtor_street_nr","debtor_plz","debtor_wohnort",
                    "firstname","surname","birthday","street","street_nr","plz","wohnort")

df <- pseudonymize(data_name = "FAKE_Verlustscheine_Assura",
                   import_filename = "data-raw/FAKE_Verlustscheine.xlsx",
                   import_sheetname = "Assura",
                   import_skiprows = 1,
                   import_oldnames = oldnames,
                   import_newnames = newnames,
                   id_original = "ahvnr",
                   id_salt = mysalt,
                   export_path = "output",
                   export_address = FALSE,
                   address_vars = address_vars,
                   keytable_vars = keytable_vars,
                   sensitive_vars = sensitive_vars)
# View(df) to inspect exported data


# Verlustscheine: 'Nicht-Sedex' ------------------------------------------

# Load variable names
# (These are just two long vectors. They are in a separate script for convenience.)
source("analysis/varnames.R")

# Check whether the colnames of imported file are the same as 'oldnames'
# If not: change 'oldnames' and 'newnames' where necessary.
df <- check_colnames("data-raw/FAKE_Verlustscheine.xlsx",
                     sheet = "Nicht-Sedex",
                     skip = 1,
                     oldnames = oldnames,
                     newnames = newnames)

# If check is successful:
address_vars <- c('pseudo_id', 'firstname', 'surname', 'plz', 'wohnort')
keytable_vars <- c("ahvnr","firstname","surname","birthday", "plz", "wohnort")
sensitive_vars <- c("ahvnr","debtor_surname", "debtor_firstname", "debtor_street",
                    "debtor_street_nr","debtor_plz","debtor_wohnort",
                    "firstname","surname","birthday","street","street_nr","plz","wohnort")

df <- pseudonymize(data_name = "FAKE_Verlustscheine_Nicht_Sedex",
                   import_filename = "data-raw/FAKE_Verlustscheine.xlsx",
                   import_sheetname = "Nicht-Sedex",
                   import_skiprows = 1,
                   import_oldnames = oldnames,
                   import_newnames = newnames,
                   id_original = "ahvnr",
                   id_salt = mysalt,
                   export_path = "output",
                   export_address = FALSE,
                   address_vars = address_vars,
                   keytable_vars = keytable_vars,
                   sensitive_vars = sensitive_vars)
# View(df) to inspect exported data



