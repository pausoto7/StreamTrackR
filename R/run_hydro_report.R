


#set up------------------------------------------------


#New environment for rmarkdown:render()
isolated_env <- new.env()


#file name
file_name <- paste0("Reports/Yukon Condition Report ", Sys.Date(), ".html")

if (!dir.exists("Reports")){
  dir.create("Reports")
}

#render rmarkdown -----------------------------------------------------
rmarkdown::render(here::here("hydrometric_report.Rmd"),
  output_file = file_name,
  params = list(stations =  c("09AG001", "09EA006", "09CA002", "09AE006", "09BC001", "09FD003", "09DD003",
                              "09DD004", "09AC001",  "09CD001", "09AH001", "09EB001", "09AB001")  , 
                YOI = 2024, 
                location = "Yukon"), # To be used for title of report
  envir = isolated_env)


#---------------------------------------------------

file_name <- paste0("Reports/Atmospheric River Conditions Report ", Sys.Date(), ".html")


rmarkdown::render(here::here("hydrometric_report.Rmd"),
                  output_file = file_name,
                  params = list(stations =  c("08GA030", "O8GA061", "08MH002", "08MH126")  ,
                                YOI = 2024,
                                location = "Lower Mainland - Atmospheric River"), # To be used for title of report
                  envir = isolated_env)


#---------------------------------------------------

file_name <- paste0("Reports/Tranquil ", Sys.Date(), ".html")


rmarkdown::render(here::here("hydrometric_report.Rmd"),
                  output_file = file_name,
                  params = list(stations =  c("08HB086", "08HC004")  ,
                                YOI = 2024,
                                location = "Tranquil"), # To be used for title of report
                  envir = isolated_env)




#---------------------------------------------------

file_name <- paste0("Reports/Theodosia Conditions Report ", Sys.Date(), ".html")


rmarkdown::render(here::here("hydrometric_report.Rmd"),
                  output_file = file_name,
                  params = list(stations =  c("08GC008", "08GC007", "08GC005", "08GC006")  ,
                                YOI = 2024,
                                location = "Theodosia"), # To be used for title of report
                  envir = isolated_env)





