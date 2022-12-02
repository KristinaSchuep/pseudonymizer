# Import some fake test data for package

testdata <- readxl::read_excel("data-raw/FAKE_DATA_2019.xlsx")

index <- match(c("NNSS","NACHNAME","VORNAME","GEBURTSDATUM"), names(testdata))
colnames(testdata)[index] <- c("ahvnr","firstname","surname","birthday")
names(testdata) <- tolower(names(testdata))
testdata <- as.data.frame(testdata)

usethis::use_data(testdata, overwrite = TRUE)
