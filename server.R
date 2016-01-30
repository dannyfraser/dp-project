
packages <- c("shiny", "leaflet", "dplyr", "ggplot2")
sapply(packages, function(p) {if (!do.call("require", as.list(p))) {install.packages(p)}})

if (!file.exists("data/weatherdata.csv")) {
    source("get_data.R")
}

get_palette <- function(measure) {
    if (measure == "tmin" || measure == "tmax") {
        gradient <- c("blue", "red")
    } else if (measure == "rain") {
        gradient <- c("skyblue", "darkblue")
    } else if (measure == "sun") {
        gradient <- c("grey", "yellow")
    } else if (measure == "airfrost") {
        gradient <- c("orange", "steelblue")
    }
    return(gradient)
}


shinyServer(function(input, output) {

    weather <- read.csv("data/weatherdata.csv")

    output$weathermap <- renderLeaflet({

        data <- filter(weather, year == input$year) %>%
            select(station, year, lat, lon, measure = get(input$measure))

        pal <- colorNumeric(
            palette = get_palette(input$measure),
            domain = data$measure
        )

        map <- leaflet(data = data, width = 800, height = 800) %>%
            addCircleMarkers(radius = 5, lat = ~lat, lng = ~lon,
                             popup = ~popup_text(station, measure),
                             fillOpacity = 1, stroke = FALSE,
                             color = ~pal(measure),
                             layerId = ~station
                             ) %>%
            addTiles(options = providerTileOptions(noWrap = TRUE)) %>%
            clearBounds()

        map

    })

    popup_text <- function(station, measure) {
        paste(station, round(measure, 2), sep = " : ")
    }

    selected_station <- reactiveValues()
    get_station <- reactive({selected_station$name <- input$weathermap_marker_click$id})

    output$weatherplot <- renderPlot({
        get_station()
        print(selected_station$name)
        filter(weather, station == selected_station$name, year >= 1900, year <= 2015) %>%
            select(year, measure = get(input$measure)) %>%
            ggplot(aes(x = year, y = measure)) +
                geom_line() +
                theme_minimal() +
                stat_smooth(method = "lm") +
                xlab("Year") + ylab(input$measure)
    })

})
