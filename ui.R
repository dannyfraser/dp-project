
# This is the user-interface definition of a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

packages <- c("shiny", "leaflet")
sapply(packages, function(p) {if (!do.call("require", as.list(p))) {install.packages(p)}})


shinyUI(
    ui <- pageWithSidebar(
            headerPanel("UK Weather Data"),
            sidebarPanel(
                sliderInput("year", "Year", min = 1900, max = 2015, value = 1, sep = "",
                            animate = animationOptions(interval = 150, loop = TRUE)),
                selectInput("measure", "Measurement",
                            choices = c("Max T" = "tmax",
                                        "Min T" = "tmin",
                                        "Avg Rain" = "rain",
                                        "Avg Sun" = "sun",
                                        "Avg Airfrost" = "airfrost")
                )
            ),
            mainPanel(
                leafletOutput("weathermap")
            )
    )
)
