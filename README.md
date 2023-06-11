# txns-5200
5200 assignemnt - implement transactions to cloud MYSQL db

There are 5 csv in this repo - contributed by the members of this group

When running the script, please change the directory of the csv file in this function:

```
readAllCSVs <- function()
{
  # TODO: add your csv directory here
  files <- c("https://5200-assignments.s3.us-east-2.amazonaws.com/synthsalestxns-20230609.csv") # c("transactionsFiveEntries.csv") # TODO: change csv file
  allRestaurantsDf <- do.call(rbind,lapply(files,read.csv))
  
  # drop all NAs rows
  allRestaurantsDf <- allRestaurantsDf[complete.cases(allRestaurantsDf), ]
  
  return(allRestaurantsDf)
}
```

Also make sure that the new restaurants and its matching cuisine are added in the swith case:

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
                "Araki Sushi" = "Japanese"
                # add your restaurant name - cuisine name pair below
                )
}
```

