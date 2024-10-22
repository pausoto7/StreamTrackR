


# Load necessary libraries
library(shiny)
library(rmarkdown)
library(blastula)

#set up------------------------------------------------

# Sys.setenv(RSTUDIO_PANDOC = "C:/Program Files/RStudio/resources/app/bin/quarto/bin/tools")
# 
# access_token <- ms_graph$new()
# outlook_token <- my_graph$login()
# outlook_token$save()


#New environment for rmarkdown:render()
isolated_env <- new.env()


#file name
file_name <- paste0("Yukon Condition Report ", Sys.Date(), ".html")

#render rmarkdown -----------------------------------------------------
rmarkdown::render("C:/Users/sotop/Documents/Technical Projects/2024/StreamTrackR/hydrometric_report.Rmd",
  output_file = file_name,
  params = list(stations =  c("09AG001", "09EA006", "09CA002", "09AE006", "09BC001", "09FD003", "09DD003",
                              "09DD004", "09AC001",  "09CD001", "09AH001", "09EB001", "09AB001")  , 
                YOI = 2024, 
                location = "Yukon"), # To be used for title of report
  envir = isolated_env)

# 
# # Email content ----------------------------
# email_title <- sprintf("%s - Hydrometric Report", format(Sys.Date(), '%B %d, %Y'))
# 
# bl_body_raw <- paste("##", email_title,  "\n\n
# Hello, \n\n
# Please find the weekly hydrometric report attached.\n\n
# Cheers,\n\n
# RCOE")
# 
# 
# # set up email and send ----------------------------------------------
# 
# outlb <- get_business_outlook()
# 
# bl_em <- compose_email(
#   body=md(bl_body_raw),
#   footer=md("Created by the DFO Restoration Centre of Expertise")
# )
# 
# 
# em <- outlb$create_email(bl_em, subject=email_title, to=c("paula.sooto@gmail.com", "paula.soto@dfo-mpo.gc.ca"))
# 
# # add an attachment and send it
# em$add_attachment(file_name)
# em$send()







