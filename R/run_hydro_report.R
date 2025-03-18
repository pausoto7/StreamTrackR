


#set up-------------------------------------------------------------------------


library(tidyhydat)
library(tidyverse)

#New environment for rmarkdown:render()
isolated_env <- new.env()

if (!dir.exists("Reports")){
  dir.create("Reports")
}


# Choose parameters ------------------------------------------------------------

# LOCATION NAME
# location name to be used in title of report file name and file title
location_name <- "Yukon"

# FILE NAME
# choose a descriptive file name with information such as:
# - what area it covers
# - Date run (can use todays date using Sys.Date())
# - Whether outputs will be in calendar year or WY
#
# Ensure file is being output into Reports/ folder (or folder of your choosing)
# sprintf works by replacing %s with the objects at the end of the arguments list in the same order.

file_name <- sprintf("Reports/%s Condition Report %s.html", location_name, Sys.Date())


# STATION NAMES
# List of WSC station names to be run in report

station_IDs <- c("09AG001", "09EA006", "09CA002", "09AE006", "09BC001", "09FD003", "09DD003",
"09DD004", "09AC001",  "09CD001", "09AH001", "09EB001", "09AB001")


# YOI
# Year you are interested in looking at in detail

YOI <- 2025


# WATER YEAR
# Type TRUE for water year format, type FALSE for calendar year. 
# For more information on WY vs calendar years see here: https://www.ausableriver.org/blog/what-water-year#:~:text=Hydrologists%20measure%20time%20differently%20than,known%20as%20a%20water%20year.

WY_type <- TRUE


# render rmarkdown -----------------------------------------------------

rmarkdown::render(here::here("hydrometric_report.Rmd"),
  output_file = file_name,
  params = list(stations =  station_IDs , 
                YOI = YOI, 
                location = location_name,  # To be used for title of report
                WY = WY_type),
  envir = isolated_env)





