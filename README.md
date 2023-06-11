# txns-5200

5200 assignment - Implement Transactions to cloud MYSQL DB

There are 5 CSVs in [this repo](https://github.com/buithuytien/txns-5200) - contributed by the members of this group

Make sure to use the LINK for a hosted version of the CSV (for example from [the GitHub repo](https://github.com/buithuytien/txns-5200)) as the filename unless running an R project. For example, the URL for "JoshiATransactions.csv" can be found by selecting "JoshiATransactions.csv" in the repo and clicking the "Raw" button on the right side.
When running the script, please change the directory of the CSV file in the main function at the bottom of the code where it says CHANGE CSV NAME HERE, only if different CSVs are desired:

```
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
