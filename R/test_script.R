library(hydroGraphR)

#test_hydro <- hydroGraphR::dl_hydro(c("09AG001", "09EA006", "09CA002", "09AE006", "09BC001"))
test_hydro <- hydroGraphR::dl_hydro("09EA006")


#test_hydro <- hydroGraphR::dl_hydro(c("09DD003"))

st_df_past <- create_hydro_stats_historical(test_hydro, date_minimum = NA, date_maximum = as.Date("2023-12-31"))
sf_df_currentYr <- create_hydro_stats_singleYr(test_hydro, 2024, WY = "yes")

create_hydrograph_separate(st_df_past, sf_df_currentYr, parameter = "flow", output_type = "jpeg", WY = "yes"  )



create_hydrograph_faceted(st_df_past,
                          sf_df_currentYr,
                          fixed_y_scales = "fixed",
                          output_type = "jpeg",
                          WY = "yes",  
                          parameter = "flow", 
                          custom_ymax_input = NA,
                          custom_ymin_input = NA, 
                          jpeg_width = 5, 
                          jpeg_height = 7)

