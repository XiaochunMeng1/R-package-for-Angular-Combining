Estimate_angular_combining <- function(F_inv_list,
                                       weights,
                                       data,
                                       n,
                                       grid = pi / 2 / 90 * seq(0, 90, by = 1),
                                       local_opt = TRUE,
                                       seed = NULL,
                                       lossfunction = "crps",
                                       target_weight = NULL) {
 
  
  set.seed(seed)

  if (weights != "inverse crps tuning") {
    temp = Estimate_angular_weights(F_inv_list, weights, data, n, seed)
    w = temp$w
    
    tuning = temp$tuning
    
    
    score <- vector("numeric", length(grid))
    
    
    for (i in 1:length(grid)) {
      score[i] = CRPS(F_inv_list, grid[i], w, data, n, seed)
    }
    
    
    
    lowest_value <- min(score)
    index_of_lowest <- which.min(score)
    Angle0 = grid[index_of_lowest]
    
    if (lossfunction == 'crps') {
      if (local_opt == FALSE) {
        return(list(
          weights = w,
          angle = Angle0,
          CRPS = score[index_of_lowest]
        ))
      }
      else if (local_opt == TRUE) {
        CRPS_theta_only <- function(theta) {
          CRPS(F_inv_list, theta, w, data, n, seed)
        }
        
        
        lower_bound <- c(-1, -4)
        upper_bound <- c(3, 2)
        
        
        result <- optim(
          par = Angle0,
          fn = CRPS_theta_only,
          method = "L-BFGS-B",
          lower = lower_bound,
          upper = upper_bound
        )
        
        
        return(list(
          weights = w,
          angle = result$par,
          CRPS = result$value
        ))
        
        
      }
      
    }
    else if (lossfunction == "target standard deviation")
    {
      temp = Estimate_targeting_variance(F_inv_list, weights, target_weight, data, n, seed)
      return(temp)
    }
  }
  
  else if (weights == "inverse crps tuning") {
    if (local_opt == TRUE) {
      x <- seq(0.2, 5, length.out = 10)
      y <- seq(0, pi / 2, length.out = 10)
      grid1 <- expand.grid(x = x, y = y)
      
      m = length(F_inv_list[[1]])
      TT = length(F_inv_list)
      
      score <- matrix(NA, nrow = TT, ncol = m)
      
      for (i in 1:TT) {
        u <- runif(n)
        sample = lapply(F_inv_list[[i]], function(f)
          f(u))
        temp <- lapply(sample, function(s)
          crps_sample(data[i], s))
        
        for (j in 1:m) {
          score[i, j] = temp[[j]]
        }
      }
      
      
      score = apply(score, MARGIN = 2, mean)
      
      CRPS_angle_beta <- function(z) {
        w = 1 / score ^ z[[1]]
        w = w / sum(w)
        return(CRPS(F_inv_list, z[[2]], w, data, n, seed))
      }
      
      
      s <- rep(NA, nrow(grid1))
      
      for (i in 1:nrow(grid1)) {
        s[i] = CRPS_angle_beta(grid1[i, ])
        
      }
      
      
      lowest_value <- min(s)
      index_of_lowest <- which.min(s)
      
      
      initial_values <- grid1[index_of_lowest, ]

      
   
      lower_bound <- c(0.2, 0)
      upper_bound <- c(5, pi / 2)
      
      
      CRPS_angle_beta <- function(z) {
        w = 1 / score ^ z[[1]]
        w = w / sum(w)
        return(CRPS(F_inv_list, z[[2]], w, data, n, seed))
      }
      
      
      result <- optim(
        par = initial_values,
        fn = CRPS_angle_beta,
        method = "L-BFGS-B",
        lower = lower_bound,
        upper = upper_bound
      )
      
      
      w = 1 / score ^ result$par[[1]]
      w = w / sum(w)
      
      return(list(
        weights = w,
        angle = result$par[[2]],
        CRPS = result$value,
        tuning = result$par[[1]]
      ))
      
    }
    
    
    
    
    else if (local_opt == FALSE) {
      if (length(grid) == 1) {
        
        temp = Estimate_angular_weights(F_inv_list, weights, data, n, seed, angle =
                                          grid)
        
        
        return(list(
          weights = temp$w,
          angle = grid,
          tuning = temp$tuning
        ))
      }
      
    
    
  }
  
  
  
  }
  
}
