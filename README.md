# txns-5200

5200 assignment - Implement Transactions to cloud MYSQL DB

There are 5 CSVs in this repo - contributed by the members of this group

When running the script, please change the directory of the CSV file in the main function at the bottom of the code where it says CHANGE CSV NAME HERE:

```
main <- function()
{
  mydb <- connectMySQL()

  sql <- "SELECT * FROM visits"
  res <- dbGetQuery(mydb, sql)
  print(paste0("Rows before transaction: ", nrow(res)))

  # CHANGE CSV NAME HERE
  csvFilename <- "https://5200-assignments.s3.us-east-2.amazonaws.com/synthsalestxns-20230609.csv"

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
