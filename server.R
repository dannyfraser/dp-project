
# This is the server logic for a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

packages <- c("shiny", "leaflet", "dplyr")
sapply(packages, function(p) {if (!do.call("require", as.list(p))) {install.packages(p)}})

if (!file.exists("data/weatherdata.csv")) {
    source("get_data.R")
}


shinyServer(function(input, output) {

    weather <- read.csv("data/weatherdata.csv")

    output$weathermap <- renderLeaflet({

        data <- filter(weather, year == input$year) %>%
            select(station, year, lat, lon, measure = get(input$measure))

        map <- leaflet(data = data, width = 800, height = 800) %>%
            addCircleMarkers(radius = 5, lat = ~lat, lng = ~lon,
                             popup = ~as.character(station),
                             opacity = 0.25, stroke = FALSE,
                             color = ~colorNumeric(palette = "Blues",
                                              domain = data$measure)
                             ) %>%
            addTiles() %>%
            clearBounds()

        map

    })

})
