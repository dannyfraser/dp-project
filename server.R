
packages <- c("shiny", "leaflet", "dplyr")
sapply(packages, function(p) {if (!do.call("require", as.list(p))) {install.packages(p)}})

if (!file.exists("data/weatherdata.csv")) {
    source("get_data.R")
}

get_palette <- function(measure) {
    temp_gradient <- colorRampPalette(c("blue", "red"))
    rain_gradient <- colorRampPalette(c("skyblue", "darkblue"))
    sun_gradient <- colorRampPalette(c("grey", "yellow"))
    frost_gradient <- colorRampPalette(c("orange", "steelblue"))

    if (measure == "tmin" || measure == "tmax") {
        temp_gradient
    } else if (measure == "rain") {
        rain_gradient
    } else if (measure == "sun") {
        sun_gradient
    } else if (measure == "airfrost") {
        frost_gradient
    }

}


shinyServer(function(input, output) {

    weather <- read.csv("data/weatherdata.csv")

    output$weathermap <- renderLeaflet({

        data <- filter(weather, year == input$year) %>%
            select(station, year, lat, lon, measure = get(input$measure))

        map <- leaflet(data = data, width = 800, height = 800) %>%
            addCircleMarkers(radius = 5, lat = ~lat, lng = ~lon,
                             popup = ~as.character(station),
                             opacity = 0.75, stroke = FALSE,
                             color = ~colorNumeric(palette = "Blues",
                                              domain = data$measure)
                             ) %>%
            addTiles() %>%
            clearBounds()

        map

    })

})
