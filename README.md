
<!-- README.md is generated from README.Rmd. Please edit that file -->

# pseudonymizer

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![CRAN
status](https://www.r-pkg.org/badges/version/pseudonymizer)](https://CRAN.R-project.org/package=pseudonymizer)
<!-- badges: end -->

The goal of `pseudonymizer` is to pseudonymize sensitive data. The
package can be used in cases where a research team receives or collects
sensitive data that has to be pseudonymized before it can be analyzed.
The package was built for a specific use case, but it can be used as a
template to pseudonymize other data sets.

The idea is to designate a data security manager, who is not part of the
research team and who has the task to securely store the original data
and to pseudonymize the data. `pseudonymizer` is the tool through which
the research team and the data security manager can collaborate. For
example, if the researchers need month and year of birth for their
analysis, they can adapt the package to extract this information from
the date of birth. The data security manager can then apply the package
and provide the research team the pseudonymized data.

The package involves six steps:

1.  Import a data set
2.  Generate a unique, stable, pseudonymized identifier from a sensitive
    identifier for each observation unit  
3.  Aggregate some sensitive data (like aggregate date of birth to year
    of birth)
4.  Optional: Generate a keytable which holds the sensitive and the
    pseudonymized identifier
5.  Optional: Generate an address file
6.  Drop sensitive data and export

Some points are noteworthy:

1.  Which (combination of) variables are considered sensitive depends on
    different factors and should be defined in accordance with any
    existing data protection contract.
2.  This package generates a pseudonymized ID using SHA-256, a
    vectorized hash function which is widely used, particularly by [U.S.
    government agencies to secure their sensitive
    data](https://csrc.nist.gov/publications/detail/fips/180/4/final). A
    hash is a one-way mathematical function (i.e., it can’t be reverse
    engineered). However, it is in principle possible to generate large
    data bases of possible inputs and compute the corresponding hash
    (especially if the structure of the input is known). With such a key
    table, re-identification would be possible. Adding a constant value
    (the ‘salt’) to all inputs increases security substantially.
3.  Choose a salt that is long and completely unrelated to the data or
    the project, ideally generated randomly.
4.  The key table with the identifying data and the salt must only be
    accessible by the data security manager and must be stored as
    securely as the original data.
5.  Through the combination of several variables, pseudonymized data
    might still allow the identification of certain individuals.
    Therefore, this data should also be stored securely and should only
    be accessible to a restricted and authorized group of persons.

## Installation

You can install the development version of pseudonymizer from
[GitHub](https://github.com/) with:

``` r
devtools::install_github("KristinaSchuep/pseudonymizer")
```

## Example

This is a basic example with some fake data. The function `pseudonymize()`
performs all of the six steps described above and exports a keytable, an
address file and the final, pseudonymized data set ready for
distribution to the research team.

``` r
library(pseudonymizer)

# Load your salt
# Beware, this is NOT a good salt, this is for illustrative purposes only!
mysalt <- "myverybadsalt" 
# Use this code to import your own, safe salt:
# mysalt <- as.character(read.delim("salt.txt",header=FALSE, sep = "", dec="."))

# Define variables to rename
oldnames <- c("NNSS","NACHNAME","VORNAME","GEBURTSDATUM")
newnames <-  c("ahvnr","surname","firstname","birthday")

# Define variables to export for address table
address_vars <- c('pseudo_id', 'firstname', 'surname', 'strasse', 'hausnr','plz', 'wohnort')

# Define variables to export for keytable
keytable_vars <- c("ahvnr","firstname","surname","birthday","strasse","hausnr", "plz", "wohnort")

# Define sensitive variables that should not be exported for the final data set
sensitive_vars <- c("ahvnr","firstname","surname","birthday","strasse","hausnr", "plz", "wohnort")

# Perform all steps in one
df <- pseudonymize(data_name = "FAKE_DATA_2019",
                   import_filename = "data-raw/FAKE_DATA_2019.xlsx", 
                   import_oldnames = oldnames,
                   import_newnames = newnames,
                   id_original = "ahvnr",
                   id_salt = mysalt,
                   export_path = "output",
                   address_vars =  address_vars,
                   keytable_vars = keytable_vars,
                   sensitive_vars = sensitive_vars)
#> 1) Append keytable:
#> Newest keytable is appendend and duplicate AHV-Nr were removed, newer entries were kept
#> 
#> 2) Export address file:
#> Address file written to address/20230113_181451_FAKE_DATA_2019_address.csv.
#> 
#> 3) Export pseudonymized data:
#> Pseudonymized file with 6 rows written to 'panon/20230113_181451_FAKE_DATA_2019_panon.csv'.
#> The file contains the following variables: pseudo_id, geschlecht, zivilstand, rolle, familiengrösse, aufenthaltsbewilligung, vermögen, steuerbareseinkommen, hasel, hassh, amount, birthyear
#> 
#> # A tibble: 6 x 12
#>   pseudo_id    gesch~1 zivil~2 rolle famil~3 aufen~4 vermö~5 steue~6 hasel hassh
#>   <chr>        <chr>   <chr>   <chr>   <dbl> <chr>     <dbl>   <dbl> <dbl> <dbl>
#> 1 6703a61b294~ Sex#M   Civil ~ Kind        3 CHResi~       0  0          0     0
#> 2 785e14d0c82~ Sex#W   Civil ~ Gatte       2 CHResi~   10000  2   e7     1     0
#> 3 d4cf8afd53c~ Sex#M   Civil ~ Antr~       1 <NA>      20000  1.20e5    NA    NA
#> 4 95daffcadf1~ <NA>    <NA>    <NA>       NA <NA>         NA  2.5 e4    NA    NA
#> 5 94f0246dba5~ <NA>    <NA>    <NA>       NA <NA>         NA  5   e5    NA    NA
#> 6 bb87fd06255~ <NA>    <NA>    <NA>       NA <NA>         NA  5   e4    NA    NA
#> # ... with 2 more variables: amount <dbl>, birthyear <dbl>, and abbreviated
#> #   variable names 1: geschlecht, 2: zivilstand, 3: familiengrösse,
#> #   4: aufenthaltsbewilligung, 5: vermögen, 6: steuerbareseinkommen
```

Instead of using this wrapper function, you can also perform each step
separately:

``` r
# Step 1: Import dataset into R
df <- import_raw_data(filename = "./data-raw/FAKE_DATA_2019.xlsx",
                      oldnames = oldnames,
                      newnames = newnames)

# Step 2: Generate unique ID from AHV-number 
df <- unique_id(data = df, id = "ahvnr", salt = mysalt)

# Step 3: Aggregate sensitive data 
df <- aggregate_sensitive(data = df)

# Step 4: Generate and append key table 
append_keytable(df = df,
                path = "output",
                keytable_vars = keytable_vars,
                id_original = "ahvnr")
#> Newest keytable is appendend and duplicate AHV-Nr were removed, newer entries were kept

# Step 5: Generate address file 
export_address(data = df,
               path = "output",
               data_name = 'FAKE_DATA',
               vars = address_vars)
#> Address file written to address/20230113_181451_FAKE_DATA_address.csv.

# Step 6: Drop sensitive data and export 
df <- export_pseudonymized(data = df,
                           sensitive_vars = sensitive_vars,
                           path = "output",
                           data_name = "FAKE_DATA",
                           data_summary = TRUE)
#> Pseudonymized file with 6 rows written to 'panon/20230113_181451_FAKE_DATA_panon.csv'.
#> The file contains the following variables: pseudo_id, geschlecht, zivilstand, rolle, familiengrösse, aufenthaltsbewilligung, vermögen, steuerbareseinkommen, hasel, hassh, amount, birthyear
#> 
#> # A tibble: 6 x 12
#>   pseudo_id    gesch~1 zivil~2 rolle famil~3 aufen~4 vermö~5 steue~6 hasel hassh
#>   <chr>        <chr>   <chr>   <chr>   <dbl> <chr>     <dbl>   <dbl> <dbl> <dbl>
#> 1 6703a61b294~ Sex#M   Civil ~ Kind        3 CHResi~       0  0          0     0
#> 2 785e14d0c82~ Sex#W   Civil ~ Gatte       2 CHResi~   10000  2   e7     1     0
#> 3 d4cf8afd53c~ Sex#M   Civil ~ Antr~       1 <NA>      20000  1.20e5    NA    NA
#> 4 95daffcadf1~ <NA>    <NA>    <NA>       NA <NA>         NA  2.5 e4    NA    NA
#> 5 94f0246dba5~ <NA>    <NA>    <NA>       NA <NA>         NA  5   e5    NA    NA
#> 6 bb87fd06255~ <NA>    <NA>    <NA>       NA <NA>         NA  5   e4    NA    NA
#> # ... with 2 more variables: amount <dbl>, birthyear <dbl>, and abbreviated
#> #   variable names 1: geschlecht, 2: zivilstand, 3: familiengrösse,
#> #   4: aufenthaltsbewilligung, 5: vermögen, 6: steuerbareseinkommen
```
