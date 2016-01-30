UK Historic Weather Data Explorer
========================================================
author: Danny Fraser
date: January 2016
autosize: true

Description
========================================================
The UK government have made available a set of monthly weather measurements for a number of weather stations. The data in some cases goes back to the 1800s and covers the whole country.

The measurements are:
* Minimum temperature
* Maximum temperature
* Days of sun
* Days of rain
* Days with air frost

This project is an explorer application that lets you see the stations on a map and view the data series for each one.

How to use the Explorer
========================================================
The main view shows a year slider and a metric selection box. Changing these parameters will change what is shown on the map. Clicking any of the weather stations on the map will bring up a time series plot of the selected metric for that station.

The time series plot includes a linear regression line so that trends in the data are made clear in the plot.


Example Data Series
========================================================
This are examples of the data series that is shown for a station:

![plot of chunk unnamed-chunk-1](docs-figure/unnamed-chunk-1-1.png) ![plot of chunk unnamed-chunk-1](docs-figure/unnamed-chunk-1-2.png) ![plot of chunk unnamed-chunk-1](docs-figure/unnamed-chunk-1-3.png) 

Example Map
========================================================
![map](docs-figure/map.png)
