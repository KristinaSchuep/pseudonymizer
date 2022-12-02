# Possible Workflow

id <- "ahvnr"
pseudo_id <- "pseudo_id"
sensitive <- c("ahvnr","firstname","surname","birthday")
salt <- "myverygoodsalt"

# Task 0: Import datasets (mostly as excel files) into R -----------------------
oldnames <-c("NNSS","NACHNAME","VORNAME","GEBURTSDATUM")
newnames <-c("ahvnr","firstname","surname","birthday")

df_pop<- import_raw_data(filename = "./data-raw/FAKE_DATA_2019.xlsx",
                         oldnames = oldnames,
                         newnames = newnames)


oldnames <-c("ahv-nr","name versicherter","VORNAME","GEBURTSDATUM")
newnames <-c("ahvnr","firstname","surname","birthday")
df_debt<- import_raw_data(filename = "./data-raw/FAKE_Verlustscheine.xlsx",
                          sheetname = "Schlussabrechnung",
                          skiprows = 1,
                          ahvnr="ahv-nr",
                          firstname="vorname...10",
                          surname="name versicherter",
                          birthday="geburtsdatum")

df_assura <- import_raw_data("./data-raw/FAKE_Verlustscheine.xlsx", "Assura",1)

df_nichtsedex <- import_raw_data("./data-raw/FAKE_Verlustscheine.xlsx", "Nicht-Sedex",1)


# Task 1: Generate unique ID from AHV-number -------------------------
df_pop <- unique_id(data = df_pop, id = id, salt = salt)

# Task 2: Aggregate sensitive data -------------------------------
df_pop <- aggregate_sensitive(data = df_pop)

# Task 3: Generate and append key table ---------------------------


# Task 3.2: Generate address file --------------------------------
export_address(data = df_pop,
               filename = './output/address/FAKE_DATA_2019_address.csv',
               vars = c('pseudo_id', 'firstname', 'surname', 'plz', 'wohnort'))

# Task 4: Drop sensitive data --------------------------------
df_pop <- drop_sensitive(data = df_pop, drop_add = c("plz"))

# Task 5: Export data to csv ----------------------------------
write.csv(x = df_pop, file = "./output/panon/FAKE_DATA_2019_panon.csv")

# Task 6: Write wrapper function -----------------------------

# Simplified workflow:

sensitive <- c("ahvnr","firstname","surname","birthday")
address_vars <- c('pseudo_id', 'firstname', 'surname', 'plz', 'wohnort')
mysalt <- "myverygoodsalt"

pseudonymize(import_filename = "./data-raw/FAKE_DATA_2019.xlsx",
             import_sheetname = NULL,
             import_skiprows = 0,
             import_oldnames = c("NNSS","NACHNAME","VORNAME","GEBURTSDATUM"),
             import_newnames = c("ahvnr","firstname","surname","birthday"),
             id_original = "ahvnr",
             id_salt = mysalt,
             export_path = "./output",
             export_address_filename = "./FAKE_DATA_2019_address.csv",
             export_address_vars =  address_vars,
             export_pseudonymized_filename = "./FAKE_DATA_2019_panon.csv",
             sensitive = sensitive)




