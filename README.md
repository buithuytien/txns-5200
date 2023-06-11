# txns-5200

5200 assignment - Implement Transactions to cloud MYSQL DB

There are 5 CSVs in this repo - contributed by the members of this group

Make sure to use the LINK for a hosted version of the CSV (for example from [the GitHub repo](https://github.com/buithuytien/txns-5200)) as the filename unless running an R project. For example, the URL for "JoshiATransactions.csv" can be found by selecting "JoshiATransactions.csv" in the repo and clicking the "Raw" button on the right side.
When running the script, please change the directory of the CSV file in the main function at the bottom of the code where it says CHANGE CSV NAME HERE:

```
main <- function()
{
  mydb <- connectMySQL()

  sql <- "SELECT * FROM visits"
  res <- dbGetQuery(mydb, sql)
  print(paste0("Rows before transaction: ", nrow(res)))

  # CHANGE CSV NAME HERE
  csvFilename <- "https://raw.githubusercontent.com/buithuytien/txns-5200/main/JoshiATransactions.csv"

  transactionDfs <- readAllCSVs(csvFilename)
  print(transactionDfs)

  txns_status <- doTransaction(mydb, transactionDfs)
  if (txns_status) print("TRANSACTION COMMITTED.")
  else print("TRANSACTION FAILED. ROLLING BACK.")

  # check number of visits after transaction
  res2 <- dbGetQuery(mydb, sql)
  print(paste0("Rows after transaction: ", nrow(res2)))

  status <- dbDisconnect(mydb)
}
```

Restaurant cuisines are hardcoded, please add cuisines if new restaurants are present in the visits:

```
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
```
