##################################################
# title: "Implement Transactions"
# author: "Joshi, Arnav"
# group: "TxnGroup 3"
# date: "Summer 1 2023"
##################################################


if("RMySQL" %in% rownames(installed.packages()) == FALSE) {
  install.packages("RMySQL")
}
library("RMySQL")


#' Connect to MySQL DB
#' 
#' @returns Database connection
connectMySQL <- function()
{
  db_name_fh <- "sql9617943"
  db_user_fh <- "sql9617943"
  db_host_fh <- "sql9.freemysqlhosting.net"
  db_pwd_fh <- "h5xlU6cLN8"
  db_port_fh <- 3306
  
  mydb.fh <- dbConnect(RMySQL::MySQL(), user = db_user_fh, password = db_pwd_fh,
                       dbname = db_name_fh, host = db_host_fh, port = db_port_fh)
  mydb <- mydb.fh
  return(mydb)
}


#' Reads all supplied CSVs into a single large CSV
#' 
#' @returns Large single CSV with all data
readAllCSVs <- function(filename)
{
  # files <- c(filename)
  # allRestaurantsDf <- do.call(rbind,lapply(files,read.csv))
  allRestaurantsDf <- read.csv(filename)
  # drop all NAs rows
  allRestaurantsDf <- allRestaurantsDf[complete.cases(allRestaurantsDf), ]
  
  return(allRestaurantsDf)
}


#' Given all filenames, do all transactions, one per file
#' 
#' @param dbcon Database connection
#' @param filenames Names of all CSV files
#' @returns List of success values of all transactions as booleans
doAllTransactions <- function(dbcon, filenames)
{
  allSuccesses <- c()
  for (filename in filenames)
  {
    transactionDf <- readAllCSVs(filename)
    print(transactionDf)
    success <- doTransaction(dbcon, transactionDf)
    allSuccesses <- c(allSuccesses, success)
  }
  return(allSuccesses)
}


#' Runs the entire transaction
#' 
#' @param dbcon Database connection
#' @param transactionDfs Dataframe of all transactions
doTransaction <- function(dbcon, transactionDfs)
{
  txnFailed = FALSE
  
  dbExecute(dbcon, "START TRANSACTION")
  
  
  for (i in 1:nrow(transactionDfs))
  {
    row <- transactionDfs[i,]
    restaurantName <- transactionDfs[i,]$restaurant
    cname <- transactionDfs[i,]$name
    cphone <- transactionDfs[i,]$phone
    
    txnFailed <- addRestaurantAndCuisine(dbcon, txnFailed, restaurantName)
    txnFailed <- addCustomer(dbcon, txnFailed, cname, cphone)
    txnFailed <- addVisit(dbcon, txnFailed, row)
  }
  
  # commit transaction if no failure, otherwise rollback
  if (txnFailed == TRUE)
    dbExecute(dbcon, "ROLLBACK")
  else
    dbExecute(dbcon, "COMMIT")
  
  # print status
  if (!txnFailed) print("TRANSACTION COMMITTED.") 
  else print("TRANSACTION FAILED. ROLLING BACK.")
  
  # return status; TRUE if successful; FALSE if failed
  return (!txnFailed)
}


#' Adds restaurant and its cuisine to the DB
#' 
#' @param dbcon Database connection
#' @param txnFailed Whether the entire transactions has failed yet
#' @param restaurantName Name of restaurant to add
addRestaurantAndCuisine <- function(dbcon, txnFailed, restaurantName)
{
  sql <- paste0("SELECT COUNT(*) FROM restaurants WHERE name = ?restaurantName")
  sql <- sqlInterpolate(dbcon, sql, restaurantName = restaurantName)
  res <- dbGetQuery(dbcon, sql)
  res <- res$`COUNT(*)`
  
  if (res == 0)
  {
    # Code to insert restaurant
    cuisineName <- getCuisineFromRestaurant(restaurantName)
    
    sql <- paste0("SELECT COUNT(*) FROM cuisine WHERE type = ?cuisineName")
    sql <- sqlInterpolate(dbcon, sql, cuisineName = cuisineName)
    res <- dbGetQuery(dbcon, sql)
    res <- res$`COUNT(*)`
    
    if (res == 0)
    {
      sql <- paste0("INSERT INTO cuisine (type)
              VALUES
              (?cuisineName)")
      sql <- sqlInterpolate(dbcon, sql, cuisineName = cuisineName)
      rowNum <- dbExecute(dbcon, sql)
      if (rowNum < 1)
        txnFailed = TRUE
    }
    
    sql <- paste0("SELECT zid FROM cuisine WHERE type = ?cuisineName")
    sql <- sqlInterpolate(dbcon, sql, cuisineName = cuisineName)
    res <- dbGetQuery(dbcon, sql)
    zid <- res$zid
    
    sql <- paste0("INSERT INTO restaurants
             (name,zid) 
             VALUES (?restaurantName, ?zid)")
    sql <- sqlInterpolate(dbcon, sql, restaurantName = restaurantName, zid = zid)
    rowNum <- dbExecute(dbcon, sql)
    if (rowNum < 1)
      txnFailed = TRUE
  }
  
  return(txnFailed)
}


#' Gets the cuisine for a new restaurant
#' 
#' @param restaurantName
getCuisineFromRestaurant <- function(restaurantName)
{
  # Determine cuisine based on restaurant name
  res <- switch(restaurantName,
                # added by Arnav
                "El Jefe's" = "Mexican",
                "McDonald's" = "American",
                # added by Thuytieh
                "Chinese123" = "Chinese",
                "American456" = "American",
                # added by Thai Pham,
                "Fogo Dechao" = "Brazillian",
                "Araki Sushi" = "Japanese",
                # Added by Tom
                "KBBQ" = "Korean",
                "Chipotle" = "Mexican",
                # Added by Andy
                "Changs" = "Chinese",
                "Olive Garden" = "Italian"
  )
}


#' Adds customer to the DB
#' 
#' @param dbcon Database connection
#' @param txnFailed Whether the entire transactions has failed yet
#' @param cname Name of customer
#' @param cphone Phone number of customer
addCustomer <- function(dbcon, txnFailed, cname, cphone)
{
  sql <- paste0("SELECT COUNT(*) FROM customers WHERE cname = ?cname AND cphone = ?cphone")
  sql <- sqlInterpolate(dbcon, sql, cname = cname, cphone = cphone)
  res <- dbGetQuery(dbcon, sql)
  res <- res$`COUNT(*)`
  
  if (res == 0)
  {
    sql <- "INSERT INTO customers (cname, cphone) VALUES (?cname, ?cphone)"
    sql <- sqlInterpolate(dbcon, sql, cname = cname, cphone = cphone)
    rowNum <- dbExecute(dbcon, sql)
    if (rowNum < 1)
      txnFailed = TRUE
  }
  return(txnFailed)
}


#' Adds visits to the DB
#' 
#' @param dbcon Database connection
#' @param txnFailed Whether the entire transactions has failed yet
#' @param row Full visit row from large dataframe
addVisit <- function(dbcon, txnFailed, row)
{
  sql <- paste0("SELECT cid FROM customers WHERE cname = ?cname AND cphone = ?cphone")
  sql <- sqlInterpolate(dbcon, sql, cname = row$name, cphone = row$phone)
  res <- dbGetQuery(dbcon, sql)
  cid <- res$cid
  
  sql <- paste0("SELECT rid FROM restaurants WHERE name = ?restaurantName")
  sql <- sqlInterpolate(dbcon, sql, restaurantName = row$restaurant)
  res <- dbGetQuery(dbcon, sql)
  rid <- res$rid
  
  sql <- paste0("INSERT INTO visits (cid, rid, cc, vdate, amount, `num.guests`)
              VALUES
              (?cid, ?rid, ?cc, ?date, ?amount, ?guests)")
  sql <- sqlInterpolate(dbcon, sql, cid = cid, rid = rid, cc = row$cc, date = row$date, amount = row$amount, guests = row$guests)
  rowNum <- dbExecute(dbcon, sql)
  if (rowNum < 1)
    txnFailed = TRUE
  return(txnFailed)
}


###########################################################################


main <- function()
{
  mydb <- connectMySQL()
  
  sql <- "SELECT * FROM visits"
  res <- dbGetQuery(mydb, sql)
  print(paste0("Rows before transactions: ", nrow(res)))
  
  # CHANGE CSV FILENAMES HERE IF DESIRED
  csvFilenames <- c("https://raw.githubusercontent.com/buithuytien/txns-5200/main/JoshiATransactions.csv",
                    "https://raw.githubusercontent.com/buithuytien/txns-5200/main/synthsalestxns-20230609.csv",
                    "https://raw.githubusercontent.com/buithuytien/txns-5200/main/AndyTransactions.csv",
                    "https://raw.githubusercontent.com/buithuytien/txns-5200/main/newfile.csv",
                    "https://raw.githubusercontent.com/buithuytien/txns-5200/main/tom_visits.csv")
  
  allSuccesses <- doAllTransactions(mydb, csvFilenames)
  if (all(allSuccesses))
  {
    print("ALL TRANSACTIONS COMMITTED.")
  }
  else
  {
    print("SOME OR ALL TRANSACTIONS ROLLED BACK.")
    print(paste0("TRANSACTIONS: ", which(allSuccesses == F)))
  }
   
  # check number of visits after transaction
  res2 <- dbGetQuery(mydb, sql)
  print(paste0("Rows after transactions: ", nrow(res2)))
  
  status <- dbDisconnect(mydb)
}


###########################################################################


main()




# Q4: Test this all at the same time -- how would you back out inserted data? How do you deal with concurrency? How do you assign synthetic keys in a concurrent environment?
# 
# Answer:
# 1. how would you back out inserted data?
#   Rollback: If one or more executions within a transaction fails, all the changes made by that transaction must be rollbacked.
#   We implemented a check for transaction status, and commit transaction if no failure, otherwise rollback
#   
# 2. How do you deal with concurrency?
#   MySQL DB obeys rules and regulations of the ACID property (atomicity, consistency, isolation, and durability). MySQL implements the following concurrency control methods:
#   - Table lock: In this type of locking, the entire table is locked. This locking is considered as the lowest level of handling concurrency. 
#       Whenever a database user tends to write to a table, it will get a write lock that stops all of the read and write operation for a while. 
#       This process continues to read the table as far as it does not conflict with other read operations. MySQL is quite popular for keeping locks to a table to a certain level.
#   - Rowlock: This is one of the most popular and greatest concurrency methods defined in MySQL. This locking mechanism tends to be carried out in the 
#       storage level rather than on the server. This lock tends to work more with a storage engine than with a server such that the server will be unaware 
#       of this type of locking activity being conducted in the storage engine.
#   - Isolation level: MySQL has also defined isolation level depending upon which concurrency is controlled. Altogether, there are four types of isolation level. 
#       They are serializable, read uncommitted, read committed, and repeatable read. All of these isolation levels are offered with a certain level of access and 
#       tasks that can be conducted by each of them with the MySQL database.
# 3. How do you assign synthetic keys in a concurrent environment
#   - We implemented auto-increment for the synthetic key (surrogate key) as part of table creation. This mechanism, provided by the database system, ensures that 
#       each transaction receives a unique key by incrementing the previous value.

# Refs:
# https://dev.mysql.com/doc/refman/8.0/en/concurrent-inserts.html
# https://www.linkedin.com/pulse/oracle-mysql-its-challenges-concurrency-seema-bhandari/





