# Possible Workflow 

# Task 0: Import datasets (mostly as excel files) into R -----------------------
df_pop<- import_raw_data(filename = "./data/FAKE_DATA_2019.xlsx",
                         ahvnr="NNSS",
                         firstname="NACHNAME",
                         surname="VORNAME",
                         birthday="GEBURTSDATUM")

df_debt<- import_raw_data(filename = "./data/FAKE_Verlustscheine.xlsx",
                          sheetname = "Schlussabrechnung",
                          skiprows = 1,
                          ahvnr="ahv-nr",
                          firstname="NACHNAME",
                          surname="name versicherter",
                          birthday="GEBURTSDATUM")

df_assura <- import_raw_data("./data/FAKE_Verlustscheine.xlsx", "Assura",1)

df_nichtsedex <- import_raw_data("./data/FAKE_Verlustscheine.xlsx", "Nicht-Sedex",1)


# Task 1: Generate unique ID from AHV-number -------------------------
df_pop <- unique_id(data = df_pop, id = "ahvnr", salt = "myverygoodsalt")

# Task 2: Aggregate sensitive data -------------------------------
df_pop <- aggregate_sensitive(data = df_pop)

# Task 3: Generate and append key table ---------------------------

# Task 4: Drop sensitive data --------------------------------


# Task 5: Export data to csv ----------------------------------


# Task 6: Write wrapper function -----------------------------
