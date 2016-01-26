# this script extracts and cleans the data from the source files,
# then saves the tidy output to data/weatherdata.csv


library(jsonlite)
library(readr)
library(dplyr)
library(lubridate)

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

get_station_name <- function(d) {
    prefix <- "Historical monthly data for meteorological station "
    substr(d, nchar(prefix) + 1, nchar(d))
}



if (!dir.exists("data")) {
    url <- "https://data.gov.uk/dataset/historic-monthly-meteorological-station-data/datapackage.zip"
    dir.create("data")
    download.file(url, "data.zip")
    unzip("data.zip", exdir = "data")
}

# get the relative paths of all data .txt files
catalog <- fromJSON("data/datapackage.json")$resources %>%
    filter(format == "txt") %>%
    mutate(station = get_station_name(description)) %>%
    select(station, path)

# create empty data frame
data <- data.frame(station = character(0), lat = numeric(0), lon = numeric(0),
                      year = integer(0), month = integer(0), tmax = numeric(0), tmin = numeric(0),
                      airfrost = integer(0), rain = numeric(0), sun = numeric(0))
columns <- names(data)

extract_data <- function(path, station) {

    print(paste("Starting", station, sep = " "))

    data_file <- paste("data", path, sep = "/")

    p <- read_lines(data_file)
    station_lat <- get_latitude(p)
    station_lon <- get_longitude(p)

    start_row <- get_data_start_row(p)

    station_data <- read.table(data_file,
                               skip = start_row - 1, col.names = columns[4:10],
                               na.strings = c("","---"), fill = TRUE)[,1:7]
    # station_data[station_data == "---"] <- NA
    station_data <- lapply(X = station_data,
       FUN = function(c){as.numeric(gsub("[^-|0-9|\\.]","", c))})
    station_data$station <- station
    station_data$lat <- station_lat
    station_data$lon <- station_lon


    data <<- rbind(as.data.frame(station_data), data)
    print(paste("Fnished", station, sep = " "))

}

mapply(extract_data, catalog$path, catalog$station)
data %>%
    filter(!is.na(year)) %>%
    group_by(station, lat, lon, year) %>%
    summarise(
        tmax = max(tmax, na.rm = TRUE),
        tmin = min(tmin, na.rm = TRUE),
        airfrost = mean(airfrost, na.rm = TRUE),
        rain = mean(rain, na.rm = TRUE),
        sun = mean(sun, na.rm = TRUE)
    ) %>%
    select(station, lat, lon, year, tmax, tmin, airfrost, rain, sun) %>%
    write_csv("data/weatherdata.csv")

