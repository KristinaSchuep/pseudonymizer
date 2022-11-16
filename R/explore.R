## Script to explore different packages and encryption functions

# Set-up
library(dplyr)

# Some test data
t1 <- data.frame(year = 2019,
                 id = c(7560000000001, 7560000000002,7560000000003),
                 name = c("A", "B", "C"))
t2 <- data.frame(year = 2020,
                 id = c(7560000000001, 7560000000004, 7560000000005),
                 name = c("A", "D", "E"))
t3 <- data.frame(year = 2021, 
                 id = c(7560000000001, 7560000000004,7560000000006),
                 name = c("A", "D", "F"))


# Package anonymizer -----------------------------------------------------------
# install.packages("devtools")
# devtools::install_github("paulhendricks/anonymizer")

t1$id2 <- anonymizer::anonymize(t1$id, .algo = "sha256", .seed = 1)
t2$id2 <- anonymizer::anonymize(t2$id, .algo = "sha256", .seed = 1)
t3$id2 <- anonymizer::anonymize(t3$id, .algo = "sha256", .seed = 1)


test <- rbind(t1,t2,t3)

test %>% filter(name == "A") 
test %>% filter(name == "B")
test %>% filter(name == "D")


# Add salt to prevent that hashes can be decrypted
# https://stackoverflow.com/questions/63619978/data-masking-in-relational-table-using-r/63664496#63664496
# https://en.wikipedia.org/wiki/Salt_(cryptography)

salt <- "averycleversentence"

t1$id3 <- anonymizer::anonymize(t1$id, .algo = "sha256", .seed = 1, .chars = salt)
t2$id3 <- anonymizer::anonymize(t2$id, .algo = "sha256", .seed = 1, .chars = salt)
t3$id3 <- anonymizer::anonymize(t3$id, .algo = "sha256", .seed = 1, .chars = salt)

test <- rbind(t1,t2,t3)

test %>% filter(name == "A") 
test %>% filter(name == "B")
test %>% filter(name == "D")


# Package Openssl -----------------------------------------------------------

openssl::sha256(c("john", "mary", "john"), key = "random_salt_value")
openssl::sha384(c("john", "mary", "john"), key = "random_salt_value")


