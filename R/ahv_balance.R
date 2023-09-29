# Testing AHV-Nummer Randomization Modul --------------------------------
rm(list=ls())
#setwd("/Users/flhug/Dropbox (Personal)/Individuelle Praemienverbilligung/Zurich/analysis/SVA-Summary")

library(dplyr)
library(stringr)
library(tidyr)
library(readr)
library(vtable)
library(lubridate)
library(readxl)
library(fastDummies)
## Import & Append --------------------
path<-"/Volumes/pp/projects/sva-research"
#library(fastDummies)
transfer <- "2023-04-05"

# import Bezirk info
bezirk <- readxl::read_excel(paste0(file.path(path,"/bezirk_plz_2.xlsx")))
# keep disting
bezirk <- bezirk %>%
  distinct(plz4, .keep_all = TRUE)



# Load Data ----------
# XLSX Files
list_of_files <- sort(list.files(file.path(path,transfer), pattern ="2023-04-05.xlsx"),decreasing = TRUE)
# remove hidden files from list_of_files
file <- grep('~$', list_of_files, fixed = TRUE, value = TRUE, invert = TRUE)
df <-  readxl::read_excel(file.path(path,transfer,file))

# For testing, create a random AHV-Number -------
#n<-nrow(df)
#a_nr <- paste0("756.", sprintf("%04d", sample(9999, n, replace = TRUE)), ".", sprintf("%04d", sample(9999, n, replace = TRUE)), ".", sprintf("%02d", sample(99, n, replace = TRUE)))

#df <- df %>%
#  mutate(ahvnr = a_nr)

# Rename columns  ---------
# For easier handling
colnames(df) <- tolower(colnames(df))
oldnames <- c("sex","tvbcaseid", "tvbcaseid_creation_ts", "tvbbeneficiaryid", "tvbbeneficaryid_creation_ts", "civilstatus", "resid_auth", "cnt_person", "relevantincome","has_el","has_sh","egid/ewid")
index <- match(oldnames, names(df))

colnames(df)[index] <- c("geschlecht","caseid","date_case_creation", "beneficiaryid", "date_beneficiary_creation", "zivilstand","aufenthaltsbewilligung","hh_size","steuerbareseinkommen","hasel","hassh","egid_ewid")

# Data wrangling -------
# To prepare for Balance Table

ahv <- as.data.frame(df) %>%
  # Merge Bezirk information
  left_join(bezirk, by = "plz4") %>%
  select(-matches("wohnort.y")) %>%
  # keep relevant columns
  select("caseid","tranche_alt","tranche_basis_egid","date_case_creation", "beneficiaryid","date_beneficiary_creation","geschlecht", "zivilstand", "aufenthaltsbewilligung", "bezirk", "land", "steuerbareseinkommen","hh_size","hasel","hassh","plz4", "egid_ewid") %>%
  # Reshape variables
  mutate(
    # If PLZ4 not equal to 4 digits, make NA
    #plz4 = ifelse(nchar(plz4) == 4, plz4, NA),
    #plz4 = gsub("^[^8].*", NA, plz4),


    # create buckets for income
    steuerbareseinkommen = as.numeric(steuerbareseinkommen),
    hh_member_income = steuerbareseinkommen/hh_size, # income per household member
    income_hh_member_bucket = cut( hh_member_income,breaks = c(-Inf, 0, 10000, 20000, 30000, 40000, 999999999),
                        labels = c("none", "<10'000", "10'-20'000", "20-30'000","30'-40'000", ">40'000")),
    # clean up marital status
    zivilstand = tolower(zivilstand),
    zivilstand = if_else(str_detect(zivilstand, "getrennt"), "getrennt", zivilstand),
    zivilstand = if_else(str_detect(zivilstand, "aufgelöst"), "getrennt", zivilstand),
    zivilstand = if_else(str_detect(zivilstand, "eingetragen"), "eingetragene Partnerschaft", zivilstand),
    zivilstand = if_else(str_detect(zivilstand, "unbekannt"), NA, zivilstand),
    zivilstand = if_else(str_detect(zivilstand, "unverheiratet"), "ledig", zivilstand),

    # aggregate case creationg
    month_case_creation = paste0(month(date_case_creation), "/",year(date_case_creation)),
    month_beneficiary_creation = paste0(month(date_beneficiary_creation), "/",year(date_beneficiary_creation)),
    year_beneficiary_creation = year(date_beneficiary_creation)

        #zivilstand = case_when(str_detect(zivilstand, "getrennte partnerschaft")~ "getrennte partnerschaft"),

   ) %>%

  # Split Ewid and Egid

  mutate(egid_ewid = as.character(egid_ewid)) %>%
  separate(egid_ewid, into = c("egid", "ewid"), sep = "/",
           convert = TRUE, remove = TRUE, extra = "drop") %>%
  mutate(egid = as.numeric(gsub("EGID: ", "", as.character(egid))),
         ewid = as.numeric(gsub("EWID: ", "", as.character(ewid)))) %>%



  # make categorical variables
  mutate_at(vars('tranche_alt','tranche_basis_egid','geschlecht', 'zivilstand', 'aufenthaltsbewilligung','hh_size','month_case_creation','month_beneficiary_creation','year_beneficiary_creation','plz4','bezirk','egid','ewid'), factor) %>%


  # create different sub samples of caseid
  mutate(case_123456 = gsub("\\d{3}$", "", caseid),
         case_12345 = gsub("\\d{4}$", "", caseid),
         case_1234 = gsub("\\d{5}$", "", caseid),
         case_123 = gsub("\\d{6}$", "", caseid),
         case_234567 = gsub("^\\d{1}|\\d{2}$", "", caseid),
         case_345678 = gsub("^\\d{2}|\\d{1}$", "", caseid),
         case_456789 = gsub("^\\d{3}", "", caseid)) %>%

  # create modulo of 7 (remainder after division) for all these variations
  mutate(
         #mod_123456 = as.factor(as.numeric(case_123456) %% 8),
         #mod_12345 = as.character(as.numeric(case_12345) %% 8),
         #mod_1234 = as.character(as.numeric(case_1234) %% 8),
         #mod_123 = as.character(as.numeric(case_123) %% 8),
         #mod_234567 = as.character(as.numeric(case_234567) %% 8),
         #mod_345678 = as.character(as.numeric(case_345678) %% 8),
         #mod_456789 = as.character(as.numeric(case_456789) %% 8)
    mod = as.factor(((as.numeric(caseid) %%8+ as.numeric(beneficiaryid)) %%8)%%8),
    mod_benef = as.factor(as.numeric(beneficiaryid)  %%8),
    mod_benef6 = as.factor(as.numeric(beneficiaryid)  %%6),
    mod_benef7 = as.factor(as.numeric(beneficiaryid)  %%7),
    mod_case = as.factor(as.numeric(caseid)  %%8),
    mod_benef10 = as.factor(as.numeric(floor(beneficiaryid / 10) %% 8 )),
    mod_date_case = as.factor(as.numeric(date_case_creation)%%8),
    mod_egid = as.factor(as.numeric(egid) %%8),
    #use mod_benef where mod_egid is na
    mod_egid = if_else(is.na(mod_egid)
                       | egid=="999999999"
                       | is.na(ewid)
                       | ewid == "999",mod_benef,mod_egid)
         )

# Intermediate Steps for testing
# create dummy variables for each factor variable
#case_sum <- dummy_cols(ahv, select_columns = c('geschlecht', 'zivilstand', 'aufenthaltsbewilligung','plz4'))
#case_sum <- case_sum %>%
 #   select(-c("geschlecht", "zivilstand", "aufenthaltsbewilligung","plz4", starts_with("ahv")))
# Manipulation to see what would it look like if it weren't random
#case_sum$mod_123456[case_sum$zivilstand=="Civil stat#L"&case_sum$geschlecht=="Sex#M"][1:80000] <- c(rep(2,80000))


# Drop all sensitive data -----------
# Drop all versions of the AHV-Numbers

case_sum <- dummy_cols(ahv, select_columns = c('mod_benef'))

model0<-lm(mod_benef_0 ~ tranche +geschlecht+zivilstand+aufenthaltsbewilligung +hh_size +hasel +hassh +income_hh_member_bucket +bezirk + year_beneficiary_creation +plz4 , data=case_sum)
summary(model0)

model1<-lm(mod_benef_1 ~ tranche +geschlecht+zivilstand+aufenthaltsbewilligung +hh_size +hasel +hassh +income_hh_member_bucket +bezirk + year_beneficiary_creation +plz4 , data=case_sum)
summary(model1)

model2<-lm(mod_benef_2 ~ tranche +geschlecht+zivilstand+aufenthaltsbewilligung +hh_size +hasel +hassh +income_hh_member_bucket +bezirk + year_beneficiary_creation +plz4, data=case_sum)
summary(model2)

model3<-lm(mod_benef_3 ~ tranche +geschlecht+zivilstand+aufenthaltsbewilligung +hh_size +hasel +hassh +income_hh_member_bucket +bezirk + year_beneficiary_creation +plz4, data=case_sum)
summary(model3)

model4<-lm(mod_benef_4 ~ tranche +geschlecht+zivilstand+aufenthaltsbewilligung +hh_size +hasel +hassh +income_hh_member_bucket +bezirk + year_beneficiary_creation +plz4, data=case_sum)
summary(model4)

model5<-lm(mod_benef_5 ~ tranche +geschlecht+zivilstand+aufenthaltsbewilligung +hh_size +hasel +hassh +income_hh_member_bucket +bezirk + year_beneficiary_creation +plz4, data=case_sum)
summary(model5)

model6<-lm(mod_benef_6 ~ tranche +geschlecht+zivilstand+aufenthaltsbewilligung +hh_size +hasel +hassh +income_hh_member_bucket +bezirk + year_beneficiary_creation +plz4, data=case_sum)
summary(model6)

model7<-lm(mod_benef_7 ~ tranche +geschlecht+zivilstand+aufenthaltsbewilligung +hh_size +hasel +hassh +income_hh_member_bucket +bezirk + year_beneficiary_creation +plz4, data=case_sum)
summary(model7)

d<-data.frame(modulo=c(summary(model0)$coefficients[,4],
     summary(model1)$coefficients[,4],
     summary(model2)$coefficients[,4],
     summary(model3)$coefficients[,4],
     summary(model4)$coefficients[,4],
     summary(model5)$coefficients[,4],
     summary(model6)$coefficients[,4],
     summary(model7)$coefficients[,4]))


egid_ewid_counts<-as.data.frame(sort(table(df$egid_ewid,useNA='ifany'),decreasing=T))

ggplot(data=d,aes(x=modulo)) + geom_histogram() +theme_classic()+xlab("P-Value") + ylab("Frequency")+ theme(text = element_text(size = 18))

case_sum <- case_sum %>%
   select(-c(starts_with("case_")))

# Randomization Check Tranche Benefi from IT -----------

case_sum <- dummy_cols(ahv, select_columns = c('tranche_alt'))

model0<-lm(tranche_alt_0 ~ geschlecht+zivilstand+aufenthaltsbewilligung +hh_size +hasel +hassh +income_hh_member_bucket +bezirk + year_beneficiary_creation, data=case_sum)
summary(model0)

model1<-lm(tranche_alt_1 ~ geschlecht+zivilstand+aufenthaltsbewilligung +hh_size +hasel +hassh +income_hh_member_bucket +bezirk + year_beneficiary_creation , data=case_sum)
summary(model1)

model2<-lm(tranche_alt_2 ~ geschlecht+zivilstand+aufenthaltsbewilligung +hh_size +hasel +hassh +income_hh_member_bucket +bezirk + year_beneficiary_creation , data=case_sum)
summary(model2)

model3<-lm(tranche_alt_3 ~ geschlecht+zivilstand+aufenthaltsbewilligung +hh_size +hasel +hassh +income_hh_member_bucket +bezirk + year_beneficiary_creation, data=case_sum)
summary(model3)

model4<-lm(tranche_alt_4 ~ geschlecht+zivilstand+aufenthaltsbewilligung +hh_size +hasel +hassh +income_hh_member_bucket +bezirk + year_beneficiary_creation , data=case_sum)
summary(model4)

model5<-lm(tranche_alt_5 ~ geschlecht+zivilstand+aufenthaltsbewilligung +hh_size +hasel +hassh +income_hh_member_bucket +bezirk + year_beneficiary_creation, data=case_sum)
summary(model5)

model6<-lm(tranche_alt_6 ~ geschlecht+zivilstand+aufenthaltsbewilligung +hh_size +hasel +hassh +income_hh_member_bucket +bezirk + year_beneficiary_creation , data=case_sum)
summary(model6)

#model7<-lm(tranche ~ geschlecht+zivilstand+aufenthaltsbewilligung +hh_size +hasel +hassh +income_hh_member_bucket +bezirk + year_beneficiary_creation +plz4, data=case_sum)
#summary(model7)

d_alt<-data.frame(modulo=c(summary(model0)$coefficients[,4],
                       summary(model1)$coefficients[,4],
                       summary(model2)$coefficients[,4],
                       summary(model3)$coefficients[,4],
                       summary(model4)$coefficients[,4],
                       summary(model5)$coefficients[,4],
                       summary(model6)$coefficients[,4]
                       #,
                       #summary(model7)$coefficients[,4]
                       ))



#egid_counts<-as.data.frame(sort(table(df$egid_pseudo),decreasing=T))

ggplot(data=d_alt,aes(x=modulo)) + geom_histogram() +theme_classic()+xlab("P-Value") + ylab("Frequency")+ theme(text = element_text(size = 18))
table(d_alt<0.05)

# Randomization Check Tranche EGID EWID from IT -----------
egid_counts<-as.data.frame(sort(table(ahv$egid,useNA='ifany'),decreasing=T))
ewid_counts<-as.data.frame(sort(table(ahv$ewid,useNA='ifany'),decreasing=T))

case_sum <- dummy_cols(ahv, select_columns = c('tranche_basis_egid'))

model0<-lm(tranche_basis_egid_0 ~ geschlecht+zivilstand+aufenthaltsbewilligung +hh_size +hasel +hassh +income_hh_member_bucket +bezirk + year_beneficiary_creation, data=case_sum)
summary(model0)

model1<-lm(tranche_basis_egid_1 ~ geschlecht+zivilstand+aufenthaltsbewilligung +hh_size +hasel +hassh +income_hh_member_bucket +bezirk + year_beneficiary_creation , data=case_sum)
summary(model1)

model2<-lm(tranche_basis_egid_2 ~ geschlecht+zivilstand+aufenthaltsbewilligung +hh_size +hasel +hassh +income_hh_member_bucket +bezirk + year_beneficiary_creation , data=case_sum)
summary(model2)

model3<-lm(tranche_basis_egid_3 ~ geschlecht+zivilstand+aufenthaltsbewilligung +hh_size +hasel +hassh +income_hh_member_bucket +bezirk + year_beneficiary_creation, data=case_sum)
summary(model3)

model4<-lm(tranche_basis_egid_4 ~ geschlecht+zivilstand+aufenthaltsbewilligung +hh_size +hasel +hassh +income_hh_member_bucket +bezirk + year_beneficiary_creation , data=case_sum)
summary(model4)

model5<-lm(tranche_basis_egid_5 ~ geschlecht+zivilstand+aufenthaltsbewilligung +hh_size +hasel +hassh +income_hh_member_bucket +bezirk + year_beneficiary_creation, data=case_sum)
summary(model5)

model6<-lm(tranche_basis_egid_6 ~ geschlecht+zivilstand+aufenthaltsbewilligung +hh_size +hasel +hassh +income_hh_member_bucket +bezirk + year_beneficiary_creation , data=case_sum)
summary(model6)

#model7<-lm(tranche_basis_egid_7 ~ geschlecht+zivilstand+aufenthaltsbewilligung +hh_size +hasel +hassh +income_hh_member_bucket +bezirk + year_beneficiary_creation +plz4, data=case_sum)
#summary(model7)

d_tranche_egid<-data.frame(modulo=c(summary(model0)$coefficients[,4],
                       summary(model1)$coefficients[,4],
                       summary(model2)$coefficients[,4],
                       summary(model3)$coefficients[,4],
                       summary(model4)$coefficients[,4],
                       summary(model5)$coefficients[,4],
                       summary(model6)$coefficients[,4]
                       #,
                       #summary(model7)$coefficients[,4]
))



#egid_counts<-as.data.frame(sort(table(df$egid_pseudo),decreasing=T))

ggplot(data=d_tranche_egid,aes(x=modulo)) + geom_histogram() +theme_classic()+xlab("P-Value") + ylab("Frequency")+ theme(text = element_text(size = 18))


table(d_tranche_egid<0.05)

# Randomization Check Modulo EGID  -----------
egid_counts<-as.data.frame(sort(table(ahv$egid),decreasing=T))
ewid_counts<-as.data.frame(sort(table(ahv$ewid),decreasing=T))

case_sum <- dummy_cols(ahv, select_columns = c('mod_egid'))

model0<-lm(mod_egid_0 ~ geschlecht+zivilstand+aufenthaltsbewilligung +hh_size +hasel +hassh +income_hh_member_bucket +bezirk + year_beneficiary_creation , data=case_sum)
summary(model0)

model1<-lm(mod_egid_1 ~ geschlecht+zivilstand+aufenthaltsbewilligung +hh_size +hasel +hassh +income_hh_member_bucket +bezirk + year_beneficiary_creation , data=case_sum)
summary(model1)

model2<-lm(mod_egid_2 ~ geschlecht+zivilstand+aufenthaltsbewilligung +hh_size +hasel +hassh +income_hh_member_bucket +bezirk + year_beneficiary_creation , data=case_sum)
summary(model2)

model3<-lm(mod_egid_3 ~ geschlecht+zivilstand+aufenthaltsbewilligung +hh_size +hasel +hassh +income_hh_member_bucket +bezirk + year_beneficiary_creation, data=case_sum)
summary(model3)

model4<-lm(mod_egid_4 ~ geschlecht+zivilstand+aufenthaltsbewilligung +hh_size +hasel +hassh +income_hh_member_bucket +bezirk + year_beneficiary_creation , data=case_sum)
summary(model4)

model5<-lm(mod_egid_5 ~ geschlecht+zivilstand+aufenthaltsbewilligung +hh_size +hasel +hassh +income_hh_member_bucket +bezirk + year_beneficiary_creation, data=case_sum)
summary(model5)

model6<-lm(mod_egid_6 ~ geschlecht+zivilstand+aufenthaltsbewilligung +hh_size +hasel +hassh +income_hh_member_bucket +bezirk + year_beneficiary_creation , data=case_sum)
summary(model6)

model7<-lm(mod_egid_7 ~ geschlecht+zivilstand+aufenthaltsbewilligung +hh_size +hasel +hassh +income_hh_member_bucket +bezirk + year_beneficiary_creation, data=case_sum)
summary(model7)


d<-data.frame(modulo=c(summary(model0)$coefficients[,4],
                       summary(model1)$coefficients[,4],
                       summary(model2)$coefficients[,4],
                       summary(model3)$coefficients[,4],
                       summary(model4)$coefficients[,4],
                       summary(model5)$coefficients[,4],
                       summary(model6)$coefficients[,4],
                       summary(model7)$coefficients[,4]
))

table(d<0.05)

ggplot(data=d,aes(x=modulo)) + geom_histogram() +theme_classic()+xlab("P-Value") + ylab("Frequency")+ theme(text = element_text(size = 18))

case_sum <- case_sum %>%
  select(-c(starts_with("case_")))


# Balance Tables: EGID -------
# Check if balance directory already exists otherwise create
dir.create(file.path(paste0("output/","balance")), showWarnings = FALSE)
# mod
st(case_sum[c("tranche_basis_egid","month_case_creation", "year_beneficiary_creation","geschlecht","zivilstand","aufenthaltsbewilligung","hh_size","hasel","hassh","income_hh_member_bucket","bezirk","plz4")],
   group = 'tranche_basis_egid', group.test = TRUE,
   digits = 3, numformat = NA, factor.numeric=TRUE, factor.counts = FALSE,
   out = 'csv',file='output/balance/balance_egidewid.csv')

st(case_sum[c("mod_egid","month_case_creation", "year_beneficiary_creation","geschlecht","zivilstand","aufenthaltsbewilligung","hh_size","hasel","hassh","income_hh_member_bucket","bezirk")],
   group = 'mod_egid', group.test = TRUE,
   digits = 3, numformat = NA, factor.numeric=TRUE, factor.counts = FALSE,
   out = 'csv',file='output/balance/balance_egid.csv')


# Balance Tables: 6 Digits -------
# Check if balance directory already exists otherwise create
# mod
st(case_sum[c("mod","tranche","month_case_creation", "year_beneficiary_creation","geschlecht","zivilstand","aufenthaltsbewilligung","hh_size","hasel","hassh","income_hh_member_bucket","bezirk","plz4")],
   group = 'mod', group.test = TRUE,
   digits = 3, numformat = NA, factor.numeric=TRUE, factor.counts = FALSE,
   out = 'csv',file='output/balance/balance_mod.csv')



# mod case
st(case_sum[c("mod_case","tranche","month_case_creation", "year_beneficiary_creation","geschlecht","zivilstand","aufenthaltsbewilligung","hh_size","hasel","hassh","income_hh_member_bucket","bezirk","plz4")],
   group = 'mod_case', group.test = TRUE,
   digits = 3, numformat = NA, factor.numeric=TRUE, factor.counts = FALSE,
   out = 'csv',file='output/balance/balance_mod_case.csv')
model2<-lm(as.numeric(mod_case) ~ tranche +month_case_creation +month_beneficiary_creation+geschlecht+zivilstand+aufenthaltsbewilligung +hh_size +hasel +hassh +income_hh_member_bucket +bezirk + year_beneficiary_creation , data=case_sum)
summary(model2)

# mod beneficiary
st(case_sum[c("mod_benef","tranche","month_case_creation", "year_beneficiary_creation","geschlecht","zivilstand","aufenthaltsbewilligung","hh_size","hasel","hassh","income_hh_member_bucket","bezirk","plz4")],
   group = 'mod_benef', group.test = TRUE,
   digits = 3, numformat = NA, factor.numeric=TRUE, factor.counts = FALSE,
   out = 'csv',file='output/balance/balance_mod_benef.csv')

# mod beneficiary 6
st(case_sum[c("mod_benef6","tranche","month_case_creation", "year_beneficiary_creation","geschlecht","zivilstand","aufenthaltsbewilligung","hh_size","hasel","hassh","income_hh_member_bucket","bezirk","plz4")],
   group = 'mod_benef6', group.test = TRUE,
   digits = 3, numformat = NA, factor.numeric=TRUE, factor.counts = FALSE,
   out = 'csv',file='output/balance/balance_mod_benef6.csv')

# mod beneficiary 7
st(case_sum[c("mod_benef7","tranche","month_case_creation", "year_beneficiary_creation","geschlecht","zivilstand","aufenthaltsbewilligung","hh_size","hasel","hassh","income_hh_member_bucket","bezirk","plz4")],
   group = 'mod_benef7', group.test = TRUE,
   digits = 3, numformat = NA, factor.numeric=TRUE, factor.counts = FALSE,
   out = 'csv',file='output/balance/balance_mod_benef7.csv')

# mod beneficiary_10
st(case_sum[c("mod_benef10","tranche","month_case_creation", "year_beneficiary_creation","geschlecht","zivilstand","aufenthaltsbewilligung","hh_size","hasel","hassh","income_hh_member_bucket","bezirk","plz4")],
   group = 'mod_benef10', group.test = TRUE,
   digits = 3, numformat = NA, factor.numeric=TRUE, factor.counts = FALSE,
   out = 'csv',file='output/balance/balance_mod_benef10.csv')

# mod date case
st(case_sum[c("mod_date_case","tranche","month_case_creation", "year_beneficiary_creation","geschlecht","zivilstand","aufenthaltsbewilligung","hh_size","hasel","hassh","income_hh_member_bucket","bezirk","plz4")],
   group = 'mod_date_case', group.test = TRUE,
   digits = 3, numformat = NA, factor.numeric=TRUE, factor.counts = FALSE,
   out = 'csv',file='output/balance/balance_mod_date_case.csv')


# mod_123456
st(case_sum[c("mod_123456","tranche","date_case_creation", "date_beneficiary_creation","geschlecht","zivilstand","aufenthaltsbewilligung","hh_size","hasel","hassh","income_hh_member_bucket","bezirk")],
   group = 'mod_123456', group.test = TRUE,
   digits = 3, numformat = NA, factor.numeric=TRUE, factor.counts = FALSE,
   out = 'csv',file='output/balance/balance_mod_123456.csv')

# mod_234567
st(case_sum[c("mod_234567","tranche","date_case_creation", "date_beneficiary_creation","geschlecht","zivilstand","aufenthaltsbewilligung","hh_size","hasel","hassh","income_hh_member_bucket","bezirk")],
   group = 'mod_234567', group.test = TRUE,
   digits = 3, numformat = NA, factor.numeric=TRUE, factor.counts = FALSE,
   out = 'csv',file='output/balance/balance_mod_234567.csv')

# mod_345678
st(case_sum[c("mod_345678","tranche","date_case_creation", "date_beneficiary_creation","geschlecht","zivilstand","aufenthaltsbewilligung","hh_size","hasel","hassh","income_hh_member_bucket","bezirk")],
   group = 'mod_345678', group.test = TRUE,
   digits = 3, numformat = NA, factor.numeric=TRUE, factor.counts = FALSE,
   out = 'csv',file='output/balance/balance_mod_345678.csv')

# mod_456789
st(case_sum[c("mod_456789","tranche","date_case_creation", "date_beneficiary_creation","geschlecht","zivilstand","aufenthaltsbewilligung","hh_size","hasel","hassh","income_hh_member_bucket","bezirk")],
   group = 'mod_456789', group.test = TRUE,
   digits = 3, numformat = NA, factor.numeric=TRUE, factor.counts = FALSE,
   out = 'csv',file='output/balance/balance_mod_456789.csv')


# Balance Tables: 5 Digits and less -------
# mod_12345
st(case_sum[c("mod_12345","tranche","date_case_creation", "date_beneficiary_creation","geschlecht","zivilstand","aufenthaltsbewilligung","hh_size","hasel","hassh","income_hh_member_bucket","bezirk")],
   group = 'mod_12345', group.test = TRUE,
   digits = 3, numformat = NA, factor.numeric=TRUE, factor.counts = FALSE,
   out = 'csv',file='output/balance/balance_mod_12345.csv')

# mod_1234
st(case_sum[c("mod_1234","tranche","date_case_creation", "date_beneficiary_creation","geschlecht","zivilstand","aufenthaltsbewilligung","hh_size","hasel","hassh","income_hh_member_bucket","bezirk")],
   group = 'mod_1234', group.test = TRUE,
   digits = 3, numformat = NA, factor.numeric=TRUE, factor.counts = FALSE,
   out = 'csv',file='output/balance/balance_mod_1234.csv')

# mod_123
st(case_sum[c("mod_123","tranche","date_case_creation", "date_beneficiary_creation","geschlecht","zivilstand","aufenthaltsbewilligung","hh_size","hasel","hassh","income_hh_member_bucket","bezirk")],
   group = 'mod_123', group.test = TRUE,
   digits = 3, numformat = NA, factor.numeric=TRUE, factor.counts = FALSE,
   out = 'csv',file='output/balance/balance_mod_123.csv')

