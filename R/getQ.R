
create_stats_table <- function(all_hydro_data, YOI = 2024){
  

  #print("Start create_stats_table")
  all_hydro_data_historical <- all_hydro_data %>%
    dplyr::filter(lubridate::year(Date) < YOI)
  
  #print("Filter for YOI")
  all_hydro_data_YOI <- all_hydro_data %>%
  dplyr::filter(lubridate::year(Date) == YOI)
  
  # Check to see that the YOI exists for this station
  if (nrow(all_hydro_data_YOI) > 0){
    
    #print("Filter for Parameter")
    all_hydro_data_YOI_WL <- all_hydro_data_YOI %>% dplyr::filter(Parameter == "Level")
    all_hydro_data_YOI_Q <- all_hydro_data_YOI %>% dplyr::filter(Parameter == "Flow")
    
    current_WL_data <- tail(all_hydro_data_YOI_WL, 1)
    current_Q_data <- tail(all_hydro_data_YOI_Q, 1)
    
    WL_DATE_TIME <- current_WL_data$Date
    Q_DATE_TIME <- current_Q_data$Date
    
    
    # CURRENT LEVEL (m)
    current_WL <- current_WL_data$Value
    current_Q <- current_Q_data$Value
    
    
    # 72 HOUR CHANGE
    WL_DATE_TIME_72 <- WL_DATE_TIME - lubridate::days(3)
    Q_DATE_TIME_72 <- Q_DATE_TIME - lubridate::days(3)
    
    #print("Filter for 72 hour value")
    WL_72hrs_ago <- (all_hydro_data_YOI_WL %>% dplyr::filter(Date == WL_DATE_TIME_72))$Value
    Q_72hrs_ago <- (all_hydro_data_YOI_Q %>% dplyr::filter(Date == Q_DATE_TIME_72))$Value
    
    
    
    # hist average for a single date
    hist_ave_val_day <- as.Date(tail(all_hydro_data_YOI, 1)$Date)
    
    #print("Filter for today's date for stats")
    single_day_historical <- all_hydro_data %>%
      dplyr::filter(lubridate::month(Date) == lubridate::month(hist_ave_val_day) & 
                      lubridate::day(Date) == lubridate::day(hist_ave_val_day))
    
     #print("Filter for params 2")  
    single_day_historical_WL <- single_day_historical %>% dplyr::filter(Parameter == "Level")
    single_day_historical_Q <- single_day_historical %>% dplyr::filter(Parameter == "Flow")
    
     
    #  MEAN HISTORIC PER DAY
    single_day_hist_mean_WL <- mean(single_day_historical_WL$Value, na.rm = TRUE)
    single_day_hist_mean_Q <- mean(single_day_historical_Q$Value, na.rm = TRUE)
    
    single_day_historical_stats <- single_day_historical %>%
      group_by(Parameter) %>%
      summarise(mean_today = mean(Value, na.rm = TRUE), 
                q25_today = quantile(Value, 0.25, na.rm = TRUE), 
                q75_today = quantile(Value, 0.75, na.rm = TRUE))
    
    #  PERCENT HISTORIC PER DAY
    WL_PERCENT <- round(100*current_WL/single_day_hist_mean_WL,2)
    Q_PERCENT <- round(100*current_Q/single_day_hist_mean_Q,2)
    
    

    
    station_numb <- unique(all_hydro_data_historical$STATION_NUMBER)
    
    station_name <- hy_stations(station_numb)$STATION_NAME
    
    MAD_df <- all_hydro_data_historical %>%
      filter(Parameter == "Flow") %>%
      group_by(year = lubridate::year(Date)) %>%
      summarise(MAD = mean(Value, na.rm = TRUE) )
      
    mean_MAD <- mean(MAD_df$MAD, na.rm = TRUE)
    
    
    single_day_historical_stats_df <- single_day_historical_stats %>%
      mutate(MAD = ifelse(Parameter == "Flow", mean_MAD, NA), 
             hist_mean = ifelse(Parameter == "Flow",single_day_hist_mean_Q, 
                                single_day_hist_mean_WL), 
             PERCENT = ifelse(Parameter == "Flow", Q_PERCENT, WL_PERCENT), 
             change_72hrs = ifelse(Parameter == "Flow",current_Q - Q_72hrs_ago , 
                                   current_WL - WL_72hrs_ago), 
             Trajectory = ifelse(change_72hrs > 0, "Rising", 
                                 ifelse(change_72hrs == 0, "Steady", 
                                        "Falling")), 
             station_numb = station_numb, .before = "Parameter", 
             station_name = station_name)
             
    single_day_historical_stats_df <- single_day_historical_stats_df %>%
      select(station_name, station_numb, Parameter, mean_today, hist_mean, PERCENT,  q25_today, q75_today, change_72hrs, Trajectory )
    
    round_and_format <- function(x) {
      if (is.numeric(x)) {
        format(round(x, 3), nsmall = 3)
      } else {
        x
      }
    }
    
    single_day_historical_stats_df <- single_day_historical_stats_df %>%
      mutate(across(where(is.numeric), round_and_format)) %>%
      mutate(PERCENT = round(as.numeric(PERCENT))) %>%
      mutate_all(as.character())
    

    return(single_day_historical_stats_df)
    #print("Succesfully returned table")
    
  }else{
    stop(simpleError("Please input a new station or new YOI. The YOI you have chosen for this station does not exist."))
    
    
  }  
    
    

}







