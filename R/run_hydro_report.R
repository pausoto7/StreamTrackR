


rmarkdown::render(
  input = system.file("rmd", "YukonWeekly2.Rmd"),
  output_file = paste0("Yukon Condition Report ", Sys.Date()),
  output_dir = "choose",
  params = list(
    stations = c("08MF005", "08NM174"),
    report_name = "Yukon Conditions Report",
  )  
)
