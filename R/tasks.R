# Main tasks 

# This script lists the main tasks for this project. The idea is that each 
# task results in one function (and probably some helper functions). 
# Each function should be written in its own R-script (together with its helper functions).


# Dependencies
# Packages: readxl, tidyverse

# Task 0: Import datasets (mostly as excel files) into R -----------------------

import_raw_data <- function(){
  
}

# (Optional/for later): Identify main person per dossier -----------------------
# - add row numbers to be able to recover order of original file
# - assign a number for each individuals per dossier
# - identify person that is the 'Schuldner' for each dossier (based on the name)


# Task 1: Generate unique ID from AHV-number -------------------------
# - the same AHV number always gives the same ID
# - no different AHV numbers lead to same ID
# - no possibility to infer AHV number from ID 

unique_id <- function(){
  # Subtasks:
  # - check format of AHV number and transform if necessary (f.ex. from character to numeric)
  # - some additional tests for AHV number (input)
}


# Task 2: Aggregate sensitive data -------------------------------
# - Birth date to year of birth
# - maybe further variables, f.ex. exact income to income bracket

aggregate_sensitive <- function(){
  
}


# Task 3: Generate and append key table ---------------------------
# - generate new key table with unique ID, AHV number, name, address, birth date
# - load last key table, append 
# - check for inconsistencies --> warning
# - keep only unique values

append_keytable <- function(){
  
}

# Task 4: Drop sensitive data --------------------------------
# - delete all rows with sensitive data (names, address, birth date, AHV number, ...)
# -> the names of the variables might be different in different datasets and might
# even change over time, so we need to think how we address that (also applies to 
# some of the previous steps)

drop_sensitive <- function(){
  
}


# Task 5: Export data to csv ----------------------------------
# - export pseudonymized data ready to submit to research team

write_pseudonymized <- function(){
  
}

# Task 6: Write wrapper function -----------------------------
# - wrap all the previous steps in one single function
# - use parameters to work with different datasets 
# -> for example a parameter 'drop' to input the names of those variables 
# that need to be dropped in task 4. With that approach, Philipp only needs to change 
# one line of code if variable names change later on

pseudonymize <- function(){
  
}
