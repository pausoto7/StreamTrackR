library(hydroGraphR)

test_hydro <- hydroGraphR::dl_hydro(c("09AG001", "09EA006", "09CA002"))
#test_hydro <- hydroGraphR::dl_hydro("09EA006")


st_df_past <- create_hydro_stats_historical(test_hydro, date_minimum = NA, date_maximum = as.Date("2023-12-31"))
sf_df_currentYr <- create_hydro_stats_singleYr(test_hydro, 2024, WY = "yes")

create_hydrograph_separate(st_df_past, sf_df_currentYr, parameter = "level", output_type = "print", WY = "yes"  )


create_hydrograph_together(st_df_past, sf_df_currentYr, WY = "no", output_type = "print",
                           parameter = "level",  custom_ymax_input = NA, custom_ymin_input = NA)
  

# get rid of the "Null" statements on report
# decrease space between plots
# make plotly maps?



# filter df's for parameter wanted
param_info <- select_hydro_parameter(st_df_past, sf_df_currentYr, parameter)

all_hydro_sites_historical <- param_info[[1]]
all_hydro_sites_1yr <- param_info[[2]]
y_lab <- param_info[[3]]

locations <- unique(all_hydro_sites_historical$STATION_NUMBER)

plot_list <- list()

for (location_num in length(locations):1){
  
  # run choose_hydro_timeline function. Suppress empty df warning because sometimes that may happen. 
  timeline_metadata <- withCallingHandlers(
    choose_hydro_timeline(all_hydro_sites_historical, all_hydro_sites_1yr, WY, locations, location_num),
    warning = function(w) {
      if (grepl("all_hydro_sites_1yr is empty. Historical values cannot be compared with this year", w$message)) {
        invokeRestart("muffleWarning")  # This suppresses only this specific warning
      }
    }
  )
  
  all_hydro_sites_historical_filtered <- timeline_metadata[[1]]
  all_hydro_sites_1yr_filtered <- timeline_metadata[[2]]
  year_label <- timeline_metadata[[3]]
  
  
  
  
  # there is no previously decided upon max y value
  custom_ymax <- set_custom_limit(custom_ymax_input, all_hydro_sites_historical_filtered$q95, 
                                  all_hydro_sites_1yr_filtered$Value, multiplier = 1.04, direction = "max")
  
  # there is no previously decided upon min y value
  custom_ymin <- set_custom_limit(custom_ymin_input, all_hydro_sites_historical_filtered$q5, 
                                  all_hydro_sites_1yr_filtered$Value, multiplier = 0.96, direction = "min")
  
  
  # get plot breaks sequence
  break_seq <- get_custom_plot_seq(custom_ymax, custom_ymin)
  
  #margin on bottom plot needs to be changed depending on if it's discharge or level
  marg_value <- ifelse(parameter == "flow", 0, 8)
  
  
  if (location_num != 1){
    hydrograph <- ggplot() + 
      #geom_ribbon(all_hydro_sites_historical, mapping = aes(ymin = min, ymax = max, x = arbitrary_date, fill = "Minimum-Maximum")) +
      geom_ribbon(all_hydro_sites_historical_filtered, mapping = aes(ymin = q5, ymax = q95, x = arbitrary_date, fill = "q5-95"), 
                  alpha = 0.75) +
      geom_ribbon(all_hydro_sites_historical_filtered, mapping = aes(ymin = q25, ymax = q75, x = arbitrary_date, fill = "q25-75"), 
                  alpha = 0.8) +
      geom_line(all_hydro_sites_historical_filtered, mapping = aes(x = arbitrary_date, y = median, color = "Median"), linewidth = 0.6) +
      geom_line(all_hydro_sites_historical_filtered, mapping = aes(x = arbitrary_date, y = mean, color = "Mean"), linewidth = 0.6) +
      geom_line(all_hydro_sites_1yr_filtered, mapping = aes(x =arbitrary_date, y = Value, color = as.character(year_label)), linewidth = 0.7) + 
      geom_hline(aes(yintercept = mean(all_hydro_sites_historical_filtered$mean),linetype = "MAD"))+
      theme_bw() +
      scale_linetype_manual(values = c(2), name = element_blank()) +
      
      scale_x_date(date_labels = "%b", breaks = "1 month",  name = "Date") +
      scale_y_continuous(breaks = break_seq,
                         limits = c(custom_ymin, custom_ymax),
                         name = y_lab) +
      scale_fill_manual(values = c(#"lightblue2", 
        "lightblue4", 
        "lightblue3"), name = element_blank()) +
      scale_color_manual(values = c("deeppink4","beige", "black"), name = "Daily Statistics") +
      theme(panel.grid.minor.x =  element_blank(), 
            axis.title.x = element_blank(), 
            axis.text.x = element_blank(), 
            axis.ticks.x = element_blank(),
            legend.margin = margin(t = -12,0,0,0), 
            legend.key.height = unit(0.7, "cm")) +
      guides(color = guide_legend(order = 1), 
             fill = guide_legend(order =2))
    
    
    plot_list[[location_num]] <- hydrograph
    
  }else{
    hydrograph <- ggplot() + 
      #geom_ribbon(all_hydro_sites_historical, mapping = aes(ymin = min, ymax = max, x = arbitrary_date, fill = "Minimum-Maximum")) +
      geom_ribbon(all_hydro_sites_historical_filtered, mapping = aes(ymin = q5, ymax = q95, x = arbitrary_date, fill = "q5-95"), 
                  alpha = 0.75) +
      geom_ribbon(all_hydro_sites_historical_filtered, mapping = aes(ymin = q25, ymax = q75, x = arbitrary_date, fill = "q25-75"), 
                  alpha = 0.8) +
      geom_line(all_hydro_sites_historical_filtered, mapping = aes(x = arbitrary_date, y = median, color = "Median"), linewidth = 0.6) +
      geom_line(all_hydro_sites_historical_filtered, mapping = aes(x = arbitrary_date, y = mean, color = "Mean"), linewidth = 0.6) +
      geom_line(all_hydro_sites_1yr_filtered, mapping = aes(x =arbitrary_date, y = Value, color = as.character(year_label)), linewidth = 0.7) + 
      theme_bw() +
      scale_linetype_manual(values = c(2), name = element_blank()) +
      
      scale_x_date(date_labels = "%b", breaks = "1 month",  name = "Date") +
      scale_y_continuous(breaks = break_seq,
                         limits = c(custom_ymin, custom_ymax),
                         name = y_lab) +
      scale_fill_manual(values = c(#"lightblue2", 
        "lightblue4", 
        "lightblue3"), name = element_blank()) +
      scale_color_manual(values = c("deeppink4","beige", "black"), name = "Daily Statistics") +
      theme(panel.grid.minor.x =  element_blank(), 
            #axis.title.x = element_blank(), 
            #axis.text.x = element_blank(), 
            #axis.ticks.x = element_blank(),
            axis.title.y = element_text(margin = margin(r=marg_value)),
            legend.margin = margin(t = -12,0,0,0), 
            legend.key.height = unit(0.7, "cm")) +
      guides(color = guide_legend(order = 1), 
             fill = guide_legend(order =2))
    
    # if figure represents flow add Mean Annual Discharge line
    if (tolower(parameter) == "flow"){
      
      hydrograph <- hydrograph +   
        geom_hline(aes(yintercept = mean(all_hydro_sites_historical_filtered$mean),linetype = "MAD"))
      
    }
    
    # Use tryCatch to test if the plot can be printed without errors
    tryCatch({
      print(hydrograph)  # Attempt to print the plot
      
      # If successful, add to plot_list
      plot_list[[location_num]] <- hydrograph
      
    }, error = function(e) {
      # If an error occurs, print a message and skip this plot
      message(paste("Error in printing hydrograph for location", location_num, ":", e$message))
    })
  }
  
}


arranged_plots <- ggpubr::ggarrange(plotlist = rev(plot_list), 
                                    ncol = 1, 
                                    heights = c(rep(1, length(plot_list)-1), 1.07),
                                    common.legend = TRUE, 
                                    widths = c(rep(1, length(plot_list))),
                                    legend = "right") 


# if outputting graph into a .jpeg, add a figure title to easily know which station the figure represents
if (tolower(output_type) == "jpeg"){
  
  arranged_plots <- arranged_plots + 
    ggtitle(paste(locations))
  
  
  file_path <- sprintf("figures/hydrograph_joined_%s.jpeg",
                       purrr::reduce(lapply(locations, stringr::str_remove, pattern = " "), ~paste(.x, .y, sep = "_"))) # for each STATION_NUMBER in list remove the spaces in the name and then join all strings with an understore between
  
  ggsave(file_path, plot = arranged_plots, width = 9, height = 5.5, create.dir = T)
  simpleMessage(sprintf("Figure saved to %s", file_path))
  
  
}else if(tolower(output_type) == "print"){
  return(arranged_plots)
}else{
  stop("Incorrect input to output_type. Please enter either print or jpeg and try again")
  
}
