# Testing AHV-Nummer Randomization Modul --------------------------------
library(dplyr)
library(vtable)
#library(fastDummies)


# Rename columns  ---------
# For easier handling
oldnames <- c("vermã.gen", "familiengrã.sse")
index <- match(oldnames, names(df))
colnames(df)[index] <- c("capital", "hh_size")

# For testing, create a random AHV-Number -------
#n<-nrow(df)
#a_nr <- paste0("756.", sprintf("%04d", sample(9999, n, replace = TRUE)), ".", sprintf("%04d", sample(9999, n, replace = TRUE)), ".", sprintf("%02d", sample(99, n, replace = TRUE)))

#df <- df %>%
#  mutate(ahvnr = a_nr)

# Data wrangling -------
# To prepare for Balance Table

ahv <- as.data.frame(df) %>%
  # keep relevant columns
  select("ahvnr", "geschlecht", "zivilstand", "aufenthaltsbewilligung", "plz4", "birthyear", "steuerbareseinkommen","capital","hh_size","hasel","hassh") %>%
  # Reshape variables
  mutate(
    # If PLZ4 not equal to 4 digits, make NA
    plz4 = ifelse(nchar(plz4) == 4, plz4, NA),

    # create buckets for income
    steuerbareseinkommen = as.numeric(steuerbareseinkommen),
    income_bucket = cut(steuerbareseinkommen,breaks = c(-Inf, 0, 20000, 40000, 60000, 80000, 999999999),
                        labels = c("none", "<20'000", "20'-40'000", "40-60'000","60'-80'000", ">80'000")),

    # create buckets for capital
    capital_bucket = cut(capital,breaks = c(-Inf, 0, 20000, 40000, 60000, 80000, 999999999),
                         labels = c("none", "<20'000", "20'-40'000", "40-60'000","60'-80'000", ">80'000"))) %>%

  # make categorical variables
  mutate_at(vars('geschlecht', 'zivilstand', 'aufenthaltsbewilligung','plz4','birthyear','hh_size'), factor) %>%

  # Reshape AHV-Number to be able to extract a number for randomization
  # remove the dots from the ahv nr
  mutate(
    ahvnr = gsub("\\.", "", ahvnr),

    # Shorten ahv_nr to random part by removing first three and last digit
    ahv_rand = gsub("^\\d{3}|\\d$", "", ahvnr)) %>%

  # create different sub samples of AHV-Number
  mutate(ahv_123456 = gsub("\\d{3}$", "", ahv_rand),
         ahv_12345 = gsub("\\d{4}$", "", ahv_rand),
         ahv_1234 = gsub("\\d{5}$", "", ahv_rand),
         ahv_123 = gsub("\\d{6}$", "", ahv_rand),
         ahv_234567 = gsub("^\\d{1}|\\d{2}$", "", ahv_rand),
         ahv_345678 = gsub("^\\d{2}|\\d{1}$", "", ahv_rand),
         ahv_456789 = gsub("^\\d{3}", "", ahv_rand)) %>%

  # create modulo of 7 (remainder after division) for all these variations
  mutate(mod_123456 = as.factor(as.numeric(ahv_123456) %% 7),
         mod_12345 = as.character(as.numeric(ahv_12345) %% 7),
         mod_1234 = as.character(as.numeric(ahv_1234) %% 7),
         mod_123 = as.character(as.numeric(ahv_123) %% 7),
         mod_234567 = as.character(as.numeric(ahv_234567) %% 7),
         mod_345678 = as.character(as.numeric(ahv_345678) %% 7),
         mod_456789 = as.character(as.numeric(ahv_456789) %% 7))

# Intermediate Steps for testing
# create dummy variables for each factor variable
#ahv_sum <- dummy_cols(ahv, select_columns = c('geschlecht', 'zivilstand', 'aufenthaltsbewilligung','plz4'))
#ahv_sum <- ahv_sum %>%
 #   select(-c("geschlecht", "zivilstand", "aufenthaltsbewilligung","plz4", starts_with("ahv")))
# Manipulation to see what would it look like if it weren't random
#ahv_sum$mod_123456[ahv_sum$zivilstand=="Civil stat#L"&ahv_sum$geschlecht=="Sex#M"][1:80000] <- c(rep(2,80000))


# Drop all sensitive data -----------
# Drop all versions of the AHV-Numbers
ahv_sum <- ahv %>%
   select(-c(starts_with("ahv")))


# Balance Tables: 6 Digits -------
# Check if balance directory already exists otherwise create
dir.create(file.path(path, "balance"), showWarnings = FALSE)
# mod_123456
st(ahv_sum[c("mod_123456","geschlecht","zivilstand","aufenthaltsbewilligung","hh_size","hasel","hassh","income_bucket", "capital_bucket","plz4","birthyear")],
   group = 'mod_123456', group.test = TRUE,
   digits = 3, numformat = NA, factor.numeric=TRUE, factor.counts = FALSE,
   out = 'csv',file='output/balance/balance_mod_123456.csv')

# mod_234567
st(ahv_sum[c("mod_234567","geschlecht","zivilstand","aufenthaltsbewilligung","hh_size","hasel","hassh","income_bucket", "capital_bucket","plz4","birthyear")],
   group = 'mod_234567', group.test = TRUE,
   digits = 3, numformat = NA, factor.numeric=TRUE, factor.counts = FALSE,
   out = 'csv',file='output/balance/balance_mod_234567.csv')

# mod_345678
st(ahv_sum[c("mod_345678","geschlecht","zivilstand","aufenthaltsbewilligung","hh_size","hasel","hassh","income_bucket", "capital_bucket","plz4","birthyear")],
   group = 'mod_345678', group.test = TRUE,
   digits = 3, numformat = NA, factor.numeric=TRUE, factor.counts = FALSE,
   out = 'csv',file='output/balance/balance_mod_345678.csv')

# mod_456789
st(ahv_sum[c("mod_456789","geschlecht","zivilstand","aufenthaltsbewilligung","hh_size","hasel","hassh","income_bucket", "capital_bucket","plz4","birthyear")],
   group = 'mod_456789', group.test = TRUE,
   digits = 3, numformat = NA, factor.numeric=TRUE, factor.counts = FALSE,
   out = 'csv',file='output/balance/balance_mod_456789.csv')


# Balance Tables: 5 Digits and less -------
# mod_12345
st(ahv_sum[c("mod_12345","geschlecht","zivilstand","aufenthaltsbewilligung","hh_size","hasel","hassh","income_bucket", "capital_bucket","plz4","birthyear")],
   group = 'mod_12345', group.test = TRUE,
   digits = 3, numformat = NA, factor.numeric=TRUE, factor.counts = FALSE,
   out = 'csv',file='output/balance/balance_mod_12345.csv')

# mod_1234
st(ahv_sum[c("mod_1234","geschlecht","zivilstand","aufenthaltsbewilligung","hh_size","hasel","hassh","income_bucket", "capital_bucket","plz4","birthyear")],
   group = 'mod_1234', group.test = TRUE,
   digits = 3, numformat = NA, factor.numeric=TRUE, factor.counts = FALSE,
   out = 'csv',file='output/balance/balance_mod_1234.csv')

# mod_123
st(ahv_sum[c("mod_123","geschlecht","zivilstand","aufenthaltsbewilligung","hh_size","hasel","hassh","income_bucket", "capital_bucket","plz4","birthyear")],
   group = 'mod_123', group.test = TRUE,
   digits = 3, numformat = NA, factor.numeric=TRUE, factor.counts = FALSE,
   out = 'csv',file='output/balance/balance_mod_123.csv')

