
####### TEST Data START
id <- "prim_ahvnr"
pseudo_id <- "prim_pseudo"
salt <- mysalt

# DF 1
prim_ahvnr <- c("756.1234.5678.01","756.1234.5678.01", "756.1234.5678.02", "756.1234.5678.03", "756.1234.5678.04", "756.1234.5678.05")
prim_pseudo <- openssl::sha256(x = prim_ahvnr, key = salt)
prim_firstname <- c("", "Aaron", "Berta", "Claudio", "Dario", "Elsa")
prim_surname <- c("", "Ackermann", "Brunner", "Christen", "Dachs", "Eris")
prim_birthdate <- c("", "1995-08-29", "1961-11-24", "1960-12-26", "1970-02-16", "")


df <- data.table::data.table(prim_ahvnr, prim_pseudo, prim_firstname, prim_surname, prim_birthdate)


# DF 2
prim_ahvnr <- c("756.1234.5678.01", "756.9876.5432.02", "756.9876.5432.06", "756.9876.5432.07", "756.9876.5432.08")
prim_pseudo <- openssl::sha256(x = prim_ahvnr, key = salt)
prim_firstname <- c("Aaron", "Berta", "Sophia", "Liam", "Olivia")
prim_surname <- c("Ackermann", "Brunner", "Williams", "Jones", "Brown")
prim_birthdate <- c("", "1961-11-24", "1995-02-20", "1978-11-30", "1989-07-12")

df <- data.table::data.table(prim_ahvnr, prim_pseudo, prim_firstname, prim_surname, prim_birthdate)


####### TEST Data END