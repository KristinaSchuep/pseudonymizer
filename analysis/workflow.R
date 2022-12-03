# Workflow

# All functions individually ----

id <- "ahvnr"
# pseudo_id <- "pseudo_id"
sensitive <- c("ahvnr","firstname","surname","birthday")
salt <- "myverygoodsalt"

# Task 0: Import datasets (mostly as excel files) into R -----------------------
df_pop<- import_raw_data(filename = "./data-raw/FAKE_DATA_2019.xlsx",
                         oldnames = c("NNSS","NACHNAME","VORNAME","GEBURTSDATUM"),
                         newnames = c("ahvnr","firstname","surname","birthday"))


df_debt<- import_raw_data(filename = "./data-raw/FAKE_Verlustscheine.xlsx",
                          sheetname = "Schlussabrechnung",
                          skiprows = 1,
                          oldnames = c("ahv-nr","name versicherter","VORNAME","GEBURTSDATUM"),
                          newnames = c("ahvnr","firstname","surname","birthday"))

df_assura <- import_raw_data("./data-raw/FAKE_Verlustscheine.xlsx", "Assura",1)

df_nichtsedex <- import_raw_data("./data-raw/FAKE_Verlustscheine.xlsx", "Nicht-Sedex",1)


# Task 1: Generate unique ID from AHV-number -------------------------
df_pop <- unique_id(data = df_pop, id = id, salt = salt)

# Task 2: Aggregate sensitive data -------------------------------
df_pop <- aggregate_sensitive(data = df_pop)

# Task 3: Generate and append key table ---------------------------
append_keytable(df = df_pop,
                path = "output",
                sensitive = sensitive,
                id_original = id)

# Task 3.2: Generate address file --------------------------------
export_address(data = df_pop,
               path = "output",
               data_name = 'FAKE_DATA',
               vars = c('pseudo_id', 'firstname', 'surname', 'plz', 'wohnort'))

# Task 4: Drop sensitive data and export --------------------------------
# df_pop <- drop_sensitive(data = df_pop, sensitive = sensitive)

export_pseudonymized(data = df_pop,
                     sensitive = sensitive,
                     path = "output",
                     data_name = "FAKE_DATA",
                     data_summary = TRUE)

# Task 6: Write wrapper function -----------------------------

mysalt <- "myverygoodsalt"
address_vars <- c('pseudo_id', 'firstname', 'surname', 'plz', 'wohnort')
sensitive <- c("ahvnr","firstname","surname","birthday")

pseudonymize(data_name = "FAKE_DATA",
             import_filename = "data-raw/FAKE_DATA_2019.xlsx",
             import_oldnames = c("NNSS","NACHNAME","VORNAME","GEBURTSDATUM"),
             import_newnames = c("ahvnr","firstname","surname","birthday"),
             id_original = "ahvnr",
             id_salt = mysalt,
             export_path = "output",
             export_address_vars =  address_vars,
             sensitive = sensitive)


pseudonymize(data_name = "FAKE_Verlustscheine",
             import_filename = "data-raw/FAKE_Verlustscheine.xlsx",
             import_sheetname = "Schlussabrechnung",
             import_skiprows = 1,
             import_oldnames = c("ahv-nr","name versicherter","VORNAME","GEBURTSDATUM"),
             import_newnames = c("ahvnr","firstname","surname","birthday"),
             id_original = "ahvnr",
             id_salt = mysalt,
             export_path = "output",
             export_address_vars =  address_vars,
             sensitive = sensitive)


df_assura <- import_raw_data("./data-raw/FAKE_Verlustscheine.xlsx", "Assura",1)

df_nichtsedex <- import_raw_data("./data-raw/FAKE_Verlustscheine.xlsx", "Nicht-Sedex",1)


