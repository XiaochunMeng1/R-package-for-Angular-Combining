Estimate_angular_weights <- function(F_inv_list,
                                     weights,
                                     data,
                                     n,
                                     seed = NULL,
                                     angle = NULL) {
  
  
  set.seed(seed)
  
  #number of models and sample size
  m = length(F_inv_list[[1]])
  TT = length(F_inv_list)
  
  

  if (weights == "averaging") {
    w = rep(1, m)
    w = w / m
    return(list(w = w))
    
  }

  else if (weights == "inverse crps") {
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
    w = 1 / score
    w = w / sum(w)
    
    return(list(w = w))
    
    
  }

  else if (weights == "inverse crps tuning") {
    # Angle must be a single value
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
    w0 = 1 / score
    w0 = w0 / sum(w0)
    
    
    
    CRPS_beta_only <- function(beta) {
      w = 1 / score ^ beta
      w = w / sum(w)
      return(CRPS(F_inv_list, angle, w, data, n, seed))
    }
    
    # grid search of initial values
    grid = seq(0.2, 5, by = 0.1)
    s <- vector("numeric", length(grid))
    
    
    
    for (i in 1:length(grid)) {
      s[i] = CRPS_beta_only(grid[i])
      
    }
    
    
    lowest_value <- min(s)
    index_of_lowest <- which.min(s)
    w0 = grid[index_of_lowest]
    
    
    
    lower_bound <- 0.2
    upper_bound <- 5
    

    result <- optim(
      par = w0,
      fn = CRPS_beta_only,
      method = "L-BFGS-B",
      lower = lower_bound,
      upper = upper_bound
    )

    w = 1 / score ^ result$par
    w = w / sum(w)
    
    return(list(w = w, tuning = result$par))
    
  }
  
  # ---- custom weights ----
  else
  {
    w = weights
    return(list(w = w, tuning = NULL))
  }
  
  
}