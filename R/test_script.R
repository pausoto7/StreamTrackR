library(hydroGraphR)

test_hydro <- hydroGraphR::dl_hydro(c("09AG001", "09EA006", "09CA002"))

st_df_past <- create_hydro_stats_historical(test_hydro, date_minimum = NA, date_maximum = as.Date("2023-12-31"))
sf_df_currentYr <- create_hydro_stats_singleYr(test_hydro, params$YOI, WY = "yes")

create_hydrograph_separate(st_df_past, sf_df_currentYr, parameter = "flow", output_type = "print", WY = "yes"  )


create_hydrograph_together(st_df_past, sf_df_currentYr, WY = "yes", output_type = "print",
                           parameter = "level",  custom_ymax_input = NA, custom_ymin_input = NA)
  

