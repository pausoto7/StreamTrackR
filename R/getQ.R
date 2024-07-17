









dl_and_wrangle_tidydydat <- function(station_number = "09EB001", start_date = NA, end_date = Sys.Date()){
  
  
  # get level and wrangle ------------------------------------------------------
  level_historic <- tidyhydat::hy_daily_levels(station_number = "09EB001") 
  
  level_final_date <- tail(level_historic, 1)$Date
  
  level_real_time <- tidyhydat::realtime_ws(
    station_number = "09EB001", 
    parameters = 46, 
    start_date = level_final_date, 
    end_date = Sys.Date()
  ) 
  
  level_real_time <- level_real_time %>% 
    mutate(Parameter = "Level") %>%
    select(-Name_En, -Unit, -Grade, -Approval, -Code)
  
  
  # get flow and wrangle ------------------------------------------------------
  
  flow_historic <- tidyhydat::hy_daily_flows(station_number = "09EB001")
  
  discharge_final_date <- tail(flow_historic, 1)$Date
  
  flow_real_time <- tidyhydat::realtime_ws(
    station_number = "09EB001", 
    parameters = 47, 
    start_date = discharge_final_date, 
    end_date = Sys.Date()
  )
  
  flow_real_time <- flow_real_time %>% 
    select(-Name_En, -Unit, -Grade, -Approval, -Code) %>%
    group_by(Date = as.Date(Date)) %>%
    summarise(Value = mean(Value, na.rm = TRUE)) %>%
    mutate(Parameter = "Flow", 
           STATION_NUMBER = station_number) 
    
  
  
  
  # combine all flow and discharge into one df
  
  all_hydro_data <- level_historic %>%
    full_join(level_real_time) %>%
    full_join(flow_historic) %>%
    full_join(flow_real_time)
  
  
  if (is.na(start_date)){
    start_date <- min(all_hydro_data$Date)
    
  }
  
  all_hydro_data <- all_hydro_data %>%
    filter(Date >= start_date, 
           Date <= end_date)

  return(all_hydro_data)
}


create_stats_table <- function(all_hydro_data, YOI = 2024){
  
  YOI <- 2024
  
  
  all_hydro_data_historical <- all_hydro_data %>%
    filter(lubridate::year(Date) < YOI)
  
  all_hydro_data_YOI <- all_hydro_data %>%
    filter(lubridate::year(Date) == YOI)
  
  
  all_hydro_data_YOI_WL <- all_hydro_data_YOI %>% filter(Parameter == "Level")
  all_hydro_data_YOI_Q <- all_hydro_data_YOI %>% filter(Parameter == "Flow")
  
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
  
  WL_72hrs_ago <- (all_hydro_data_YOI_WL %>% filter(Date == WL_DATE_TIME_72))$Value
  Q_72hrs_ago <- (all_hydro_data_YOI_Q %>% filter(Date == Q_DATE_TIME_72))$Value
  
  
  
  # hist average for a single date
  hist_ave_val_day <- as.Date(tail(all_hydro_data_YOI, 1)$Date)
  
  single_day_historical <- all_hydro_data %>%
    filter(lubridate::month(Date) == lubridate::month(hist_ave_val_day) & 
             lubridate::day(Date) == lubridate::day(hist_ave_val_day))
  
  single_day_historical_WL <- single_day_historical %>% filter(Parameter == "Level")
  single_day_historical_Q <- single_day_historical %>% filter(Parameter == "Flow")
  
  
  #  MEAN HISTORIC PER DAY
  single_day_hist_mean_WL <- mean(single_day_historical_WL$Value, na.rm = TRUE)
  single_day_hist_mean_Q <- mean(single_day_historical_Q$Value, na.rm = TRUE)
  
  
  #  PERCENT HISTORIC PER DAY
  WL_PERCENT <- round(100*current_WL/single_day_hist_mean_WL,2)
  Q_PERCENT <- round(100*current_Q/single_day_hist_mean_Q,2)
  
  station_numb <- unique(all_hydro_data_historical$STATION_NUMBER)
  
  station_name <- hy_stations(station_numb)$STATION_NAME
  
  # CREATLY WEEKLY STATS TABLE
  stats_table <- all_hydro_data_historical %>%
    group_by(Parameter) %>%
    summarise(MAD = mean(Value, na.rm = TRUE), 
              q25 = quantile(Value, 0.25, na.rm = TRUE), 
              q75 = quantile(Value, 0.75, na.rm = TRUE)) %>%
    ungroup() %>%
    mutate(perc_hist = ifelse(Parameter =="Flow", Q_PERCENT, WL_PERCENT), 
           change_72hrs = ifelse(Parameter == "Flow",current_Q - Q_72hrs_ago , 
                                 current_WL - WL_72hrs_ago), 
           Trajectory = ifelse(change_72hrs > 0, "Rising", 
                               ifelse(change_72hrs == 0, "Steady", 
                                      "Falling"))) %>%
    mutate(station_numb = station_numb, .before = "Parameter") %>%
    mutate(station_name = station_name, .before = "station_numb")
  

  return(stats_table)
}





