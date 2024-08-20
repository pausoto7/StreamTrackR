


# Load necessary libraries
library(rmarkdown)
library(blastula)

isolated_env <- new.env()


rmarkdown::render(
  "weekly_hydrometric_report.Rmd",
  output_file = paste0("Yukon Condition Report ", Sys.Date(), ".html"),
  params = list(stations =  c("09AG001", "09EA006", "09CA002", "09AE006", "09BC001", "09FD003", "09DD003",
                              "09AC001",  "09CD001", "09AH001", "09EB001", "09AB001")  , 
                YOI = 2024, 
                location = "Yukon"), # To be used for title of report
  envir = isolated_env)



# Create an email object
email <- compose_email(
  body = md("Hello,\n\nPlease find the weekly report attached.\n\nBest regards,\nPaula")
)

# Specify the path to the rendered report
report_path <- "weekly_hydrometric_report.html"

# Attach the report and send the email
smtp_send(
  email,
  from = "paula.soto@dfo-mpo.gc.ca",
  to = "paula.soto@dfo-mpo.gc.ca",
  subject = sprintf("Weekly Hydrometric Report for %s", Sys.Date()),
  body = "Please find attached the latest weekly hydrometric report.",
  attachments = report_path,
  credentials = creds(
    user = "paula.soto@dfo-mpo.gc.ca",
    provider = "outlook", # or another email provider
    use_ssl = TRUE
  )
)
