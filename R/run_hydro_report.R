


rmarkdown::render(
  input = system.file("rmd", "YukonWeekly2.Rmd"),
  output_file = paste0("Yukon Condition Report ", Sys.Date()),
  output_dir = "choose",
  params = list(
    stations = stations,
    report_name = "Yukon Conditions Report",
  )  
)