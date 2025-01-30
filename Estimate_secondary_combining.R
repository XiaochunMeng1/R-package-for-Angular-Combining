Estimate_secondary_combining <- function(F_inv_list,
                                         sec_method ,
                                         first_weights ,
                                         data,
                                         n,
                                         seed = NULL) {

  
  
  set.seed(seed)

  
  
  if (first_weights != "inverse crps tuning") {
    temp = Estimate_angular_weights(F_inv_list, first_weights, data, n, seed)
    w = temp$w
    
    F_inv <- vector("list", length(F_inv_list))
    for (i in 1:length(F_inv_list)) {
      # Apply Forecast_angular for angle pi/2
      F1 <- Forecast_angular(F_inv_list[[i]], w, pi / 2, n, seed)
      
      # Apply Forecast_angular for angle 0
      F2 <- Forecast_angular(F_inv_list[[i]], w, 0, n, seed)
      
      # Store the results as a list of F_inv
      F_inv[[i]] <- list(F1$F_inv, F2$F_inv)
    }

    
    ind_weights = list(w, w)
    
  }
  else if (first_weights == "inverse crps tuning")
  {
    w1 = Estimate_angular_weights(F_inv_list, first_weights, data, n, seed, angle =
                                    pi / 2)
    w2 = Estimate_angular_weights(F_inv_list, first_weights, data, n, seed, angle =
                                    0)
    

    
    F_inv <- vector("list", length(F_inv_list))

    
    ind_weights = list(w1$w, w2$w)
    # Loop over the indices
    for (i in 1:length(F_inv_list)) {
      # Apply Forecast_angular for angle pi/2 using w1$w
      F1 <- Forecast_angular(F_inv_list[[i]], ind_weights[[1]], pi / 2, n, seed)
      
      # Apply Forecast_angular for angle 0 using w2$w
      F2 <- Forecast_angular(F_inv_list[[i]], ind_weights[[2]], 0, n, seed)
      
      # Store the results as a list of F_inv
      F_inv[[i]] <- list(F1$F_inv, F2$F_inv)
    }
    
  }
  
  
  
  if (sec_method == "vertical averaging") {
    
    return(list(
      angle = pi / 2,
      ind_weights = ind_weights,
      sec_weight = c(0.5, 0.5),
      CRPS=CRPS(F_inv, pi/2, c(0.5, 0.5), data, n, seed)
    ))
    
  }
  
  else if (sec_method == "horizontal averaging") {
    
    
    return(list(
      angle = 0,
      ind_weights = ind_weights,
      sec_weight = c(0.5, 0.5),
      CRPS=CRPS(F_inv, 0, c(0.5, 0.5), data, n, seed)
    ))
  }
  
  else{
    
    if (sec_method == "vertical combining") {
      theta = pi / 2
    }
    
    else if (sec_method == "horizontal combining" | sec_method =="switching") # The angle doesn't affect switching
    {
      theta = 0
    }
    
    
    CRPS_ww_only <- function(ww) {
      CRPS(F_inv, theta, c(ww, 1 - ww), data, n, seed)
    }
    
    # grid of initial values
    if (sec_method != "switching") {
    grid = seq(0, 1, length.out = 20)
    
    score <- vector("numeric", length(grid))
    for (i in 1:length(grid)) {
      score[i] = CRPS_ww_only(grid[i])
    }
    
    
    
    lowest_value <- min(score)
    index_of_lowest <- which.min(score)
    ww0 = grid[index_of_lowest]
    
    
    lower_bound <- 0
    upper_bound <- 1
    
    
    result <- optim(
      par = ww0,
      fn = CRPS_ww_only,
      method = "L-BFGS-B",
      lower = lower_bound,
      upper = upper_bound
    )
    
    return(list(
      angle = theta,
      ind_weights = ind_weights,
      sec_weight = c(result$par, 1 - result$par),
      CRPS=result$value
    ))
    }
    else if (sec_method == "switching"){
      
      
        grid = seq(0, 1, length.out = 2)

        
        score <- vector("numeric", length(grid))
        for (i in 1:length(grid)) {
          score[i] = CRPS_ww_only(grid[i])
        }
        lowest_value <- min(score)
        index_of_lowest <- which.min(score)
        ww0 = grid[index_of_lowest]
        
        
        return(list(
          angle = theta,
          ind_weights = ind_weights,
          sec_weight = c(ww0, 1 - ww0),
          CRPS=lowest_value
        ))
      
    }
    
  }
}
