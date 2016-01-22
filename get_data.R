library(jsonlite)
library(readr)

# TODO
# some data is still being coerced to NA - see airfrost for Aberporth for instance.
# find out why, and fix.

# after the data is clean enough, add a new data column (lubridate?) and output to csv
# the csv will be the input to the Shiny app


# helper functions
get_coord <- function(match, p) {
    # match Lat ##.### or Lon ##.###
    matches <- regexpr(paste("(?<=", match, " )(\\-*[0-9]*\\.[0-9]*)", sep = ""), p,
                       perl = TRUE, ignore.case = TRUE)
    regmatches(p, matches)
}

get_latitude <- function(p) {
    get_coord("Lat", p)
}
get_longitude <- function(p) {
    get_coord("Lon", p)
}
get_data_start_row <- function(p) {
    grep("yyyy", p) + 2
}



if (!dir.exists("data")) {
    url <- "https://data.gov.uk/dataset/historic-monthly-meteorological-station-data/datapackage.zip"
    dir.create("data")
    download.file(url, "data.zip")
    unzip("data.zip", exdir = "data")
}

# get the relative paths of all data .txt files
catalog <- fromJSON("data/datapackage.json")$resources$path
catalog <- catalog[grep("*.txt",x = catalog)]
catalog <- sapply(catalog, function(c){paste("data", c, sep = "/")})

# create empty data frame
data <- data.frame(station = character(0), lat = numeric(0), lon = numeric(0),
                      year = numeric(0), month = numeric(0), tmax = numeric(0), tmin = numeric(0),
                      airfrost = numeric(0), rain = numeric(0), sun = numeric(0))
columns <- names(data)

extract_data <- function(path) {

    p <- read_lines(path)
    station_name <- p[1]
    station_lat <- get_latitude(p)
    station_lon <- get_longitude(p)

    start_row <- get_data_start_row(p)

    station_data <- read_table(path, skip = start_row - 1, col_names = columns[4:10])[,1:7]
    station_data[station_data == "---"] <- NA
    station_data <- lapply(X = station_data,
       FUN = function(c){as.numeric(gsub("[^-|0-9|\\.]","", c))})
    station_data$station <- station_name
    station_data$lat <- station_lat
    station_data$lon <- station_lon

    print(station_name)
    data <<- rbind(as.data.frame(station_data), data)





}

lapply(X = catalog, FUN = extract_data)

