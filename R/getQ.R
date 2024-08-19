





create_hydro_stats <- function(all_hydro_data_historical, all_hydro_data_YOI, param_type, YOI = 2024){
  
  station_numb <- unique(all_hydro_data_historical$STATION_NUMBER)
  
  all_hydro_data_YOI <- all_hydro_data_YOI %>% dplyr::filter(Parameter == param_type)
  all_hydro_data_historical <- all_hydro_data_historical %>% dplyr::filter(Parameter == param_type)
  
  
  # DOES YOI EXIST AND DOES TODAYS DATE EXIST 
  if(nrow(all_hydro_data_YOI) > 0 && any(as.Date(all_hydro_data_YOI$Date) %in% Sys.Date())){
    
    current_data <- all_hydro_data_YOI %>%
      dplyr::filter(as.Date(Date) == Sys.Date())
    
    current_mean_value <- mean(current_data$Value, na.rm = TRUE)
    
    df_Date <- Sys.Date()
    
    table_message <- sprintf("%s stats were calculated using %s data", param_type, format(as.Date(df_Date), "%B %d, %Y"))
    
    
  }else if (nrow(all_hydro_data_YOI) > 0 & !any(as.Date(all_hydro_data_YOI$Date) %in% Sys.Date())){
    #Most up to date data in df
    df_Date <- as.Date(tail(all_hydro_data_YOI, 1)$Date)
    
    current_data <- all_hydro_data_YOI %>%
      dplyr::filter(as.Date(Date) == df_Date)
    
    current_mean_value <- mean(current_data$Value, na.rm = TRUE)
    
    table_message <- sprintf("%s stats were calculated using %s data", param_type, format(as.Date(df_Date), "%B %d, %Y"))
    
    
    warning(sprintf("Today's date was not found in the most recently downloaded data.
              Instead the most recent date will be used which is %s", df_Date))
  }else{
    #Most up to date data in df
    df_Date <- Sys.Date()
    
    current_data <- NA
    
    current_mean_value <- NA
    
    table_message <- sprintf("%s stats were unavailable for any dates this year.", param_type)
    
    warning(sprintf("The YOI data for station %s was not found. Value's for YOI will be NA and historical stats will be based off todays date (%s)", station_numb, df_Date))
    
  }
  
  
  
  
  if (nrow(all_hydro_data_historical) > 0){
    
    date_ranges <- get_date_ranges(all_hydro_data_historical)$year_ranges
    
    
    # 72 HOUR CHANGE
    DATE_72hrs_ago <- df_Date - lubridate::days(3)
    
    #Get average value from three days ago
    value_72hrs_ago <- mean((all_hydro_data_YOI %>% dplyr::filter(as.Date(Date) == DATE_72hrs_ago))$Value, na.rm = TRUE)
    
    #print("Filter for today's date for stats")
    single_day_historical <- all_hydro_data_historical %>%
      dplyr::filter(lubridate::month(Date) == lubridate::month(df_Date) & 
                      lubridate::day(Date) == lubridate::day(df_Date))
    
    
    single_day_historical_stats <- single_day_historical %>%
      dplyr::summarise(mean_today = mean(Value, na.rm = TRUE), 
                       q25_today = quantile(Value, 0.25, na.rm = TRUE), 
                       q75_today = quantile(Value, 0.75, na.rm = TRUE))
    
    #  PERCENT HISTORIC PER DAY
    percent_historic <- round(100*current_mean_value/single_day_historical_stats$mean_today,2)
    
    #GET name df
    station_name <- hy_stations(station_numb)$STATION_NAME
    
    if (param_type == "Flow"){
      
      MAD_df <- all_hydro_data_historical %>%
        group_by(year = lubridate::year(Date)) %>%
        summarise(MAD = mean(Value, na.rm = TRUE) )
      
      mean_MAD <- mean(MAD_df$MAD, na.rm = TRUE)
      
    }else{
      
      mean_MAD <- NA
      
    }
    
    single_day_historical_stats_df <- single_day_historical_stats %>%
      mutate(MAD = mean_MAD, 
             current_mean = current_mean_value, 
             parameter = ifelse(param_type == "Flow", "Flow (m<sup>3</sup>/s)", "Level (m)"),
             hist_mean = single_day_historical_stats$mean_today, 
             percent = percent_historic, 
             change_72hrs = current_mean_value - value_72hrs_ago, 
             trajectory = as.character(ifelse(change_72hrs > 0, "Rising", 
                                              ifelse(change_72hrs == 0, "Steady", "Falling"))),
             date_ranges = date_ranges, 
             station_numb = station_numb, .before = "parameter", 
             station_name = station_name)
    
    
    single_day_historical_stats_df <- single_day_historical_stats_df %>%
      select(station_name, station_numb, parameter, current_mean, hist_mean, percent, MAD,  q25_today, q75_today, change_72hrs,date_ranges, trajectory )
    
  }else{
    
    single_day_historical_stats_df <- data.frame(
      station_name = character(), 
      station_numb = character(), 
      parameter = character(),
      current_mean = numeric(), 
      hist_mean = numeric(), 
      percent = numeric(), 
      MAD = numeric(), 
      q25_today = numeric(), 
      q75_today = numeric(), 
      change_72hrs = numeric(), 
      date_ranges = character(), 
      trajectory = character()
    )
    
    
  }

 
  
  
  
  return(list(single_day_historical_stats_df, table_message))
  


}



round_and_format <- function(x, decimals = 3) {
  if (is.numeric(x)) {
    format(round(x, decimals), nsmall = decimals)
  } else {
    x
  }
}



create_stats_table <- function(all_hydro_data, YOI = 2024){
  
  #print("Start create_stats_table")
  all_hydro_data_historical <- all_hydro_data %>%
    dplyr::filter(lubridate::year(Date) < YOI)
  
  #print("Filter for YOI")
  all_hydro_data_YOI <- all_hydro_data %>%
    dplyr::filter(lubridate::year(Date) == YOI)
  
  

  flow_df <- create_hydro_stats(all_hydro_data_historical, all_hydro_data_YOI, param_type = "Flow")
  level_df <- create_hydro_stats(all_hydro_data_historical, all_hydro_data_YOI, param_type = "Level")
  
  
  flow_df_stats <- flow_df[[1]] %>%
    mutate(across(where(is.numeric), ~ round_and_format(., decimals = 1))) 
  
  level_df_stats <- level_df[[1]] %>%
    mutate(across(where(is.numeric), ~ round_and_format(., decimals = 3) )) 
  
  
  single_day_historical_stats_df <- flow_df_stats %>%
    full_join(level_df_stats) %>%
    mutate(percent = round(as.numeric(percent))) %>%
    mutate_all(as.character())
  

    return(list(single_day_historical_stats_df,  flow_df[[2]], level_df[[2]]))

}








