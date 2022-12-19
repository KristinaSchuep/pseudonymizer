# Workflow

# Load packages --------------------------------------------------------------
library(pseudonymizer)

# Define some common variables -----------------------------------------------
mysalt<- as.character(read.delim("salt.txt",header=FALSE, sep = "", dec="."))
mysalt <- "myverygoodsalt"

# Population data ------------------------------------------------------------
address_vars <- c('pseudo_id', 'firstname', 'surname', 'plz', 'wohnort')
sensitive <- c("ahvnr","firstname","surname","birthday", "plz", "wohnort")

pseudonymize(data_name = "FAKE_DATA",
             import_filename = "data-raw/FAKE_DATA_2021.xlsx",
             import_oldnames = c("NNSS","NACHNAME","VORNAME","GEBURTSDATUM"),
             import_newnames = c("ahvnr","firstname","surname","birthday"),
             id_original = "ahvnr",
             id_salt = mysalt,
             export_path = "output",
             export_address_vars =  address_vars,
             sensitive = sensitive)


# Verlustscheine -------------------------------------------------------------

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
sensitive <- c("ahvnr","firstname","surname","birthday", "plz", "wohnort")
address_vars <- c('pseudo_id', 'firstname', 'surname', 'plz', 'wohnort')

pseudonymize(data_name = "FAKE_Verlustscheine",
             import_filename = "data-raw/FAKE_Verlustscheine.xlsx",
             import_sheetname = "Schlussabrechnung",
             import_skiprows = 1,
             import_oldnames = oldnames,
             import_newnames = newnames,
             id_original = "ahvnr",
             id_salt = mysalt,
             export_path = "output",
             export_address = FALSE,
             export_address_vars =  address_vars,
             sensitive = sensitive)



# Next:


df_assura <- import_raw_data("./data-raw/FAKE_Verlustscheine.xlsx", "Assura",1)

df_nichtsedex <- import_raw_data("./data-raw/FAKE_Verlustscheine.xlsx", "Nicht-Sedex",1)




