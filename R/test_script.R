library(hydroGraphR)

test_hydro <- hydroGraphR::dl_hydro(c("09AH001", "09EB001", "09AE006"))
#test_hydro <- hydroGraphR::dl_hydro("09EA006")


st_df_past <- create_hydro_stats_historical(test_hydro, date_minimum = NA, date_maximum = as.Date("2023-12-31"))
sf_df_currentYr <- create_hydro_stats_singleYr(test_hydro, 2024, WY = "yes")

create_hydrograph_separate(st_df_past, sf_df_currentYr, parameter = "level", output_type = "print", WY = "yes"  )


create_hydrograph_together(st_df_past, sf_df_currentYr, WY = "no", output_type = "jpeg",
                           parameter = "flow",  custom_ymax_input = NA, custom_ymin_input = NA)
  




