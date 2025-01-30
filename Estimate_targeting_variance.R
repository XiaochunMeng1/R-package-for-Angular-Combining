Estimate_targeting_variance <- function(F_inv_list,weights, target_weight, data,n,seed = NULL) {
  
  
  if (sum(target_weight) != 1) {
    stop("Weights do not sum up to 1")
  }
  
  #num_cores <- detectCores() - 1
  

  m=length(F_inv_list[[1]])
  TT=length(F_inv_list)

  temp = Estimate_angular_weights(F_inv_list, weights, data, n, seed)
  w = temp$w
  

  variance1 <- numeric(length(F_inv_list))
  
  # Loop over the indices
  for (i in 1:length(F_inv_list)) {
    # Generate the random sample using the Simulation_angular function
    random_sample <- Simulation_angular(F_inv_list[[i]], w, pi/2, n, seed)
    
    # Compute the variance of the random sample
    variance1[i] <- var(random_sample)
  }
  
  variance1=mean(variance1)
  

  variance2 <- numeric(length(F_inv_list))
  
  # Loop over the indices
  for (i in 1:length(F_inv_list)) {
    # Generate the random sample using the Simulation_angular function
    random_sample <- Simulation_angular(F_inv_list[[i]], w, 0, n, seed)
    
    # Compute the variance of the random sample
    variance2[i] <- var(random_sample)
  }
  
  variance2=mean(variance2)
  
  target_std=sqrt(variance1)*target_weight[1]+sqrt(variance2)*target_weight[2]
  
  
  variance_theta_only <- function(theta) {
    # Initialize an empty vector to store variances
    variance <- numeric(length(F_inv_list))
    
    # Loop over the indices
    for (i in 1:length(F_inv_list)) {
      # Generate the random sample using the Simulation_angular function
      random_sample <- Simulation_angular(F_inv_list[[i]], w, theta, n, seed)
      
      # Compute the variance of the random sample
      variance[i] <- var(random_sample)
    }
    
    # Return the result
    return(sqrt(mean(variance)) - target_std)
  }
  
  
  result <- uniroot(variance_theta_only, interval = c(0, pi/2))

  
  if (abs(result$f.root)>10^-3) {
    stop("Root not found")
  }
  
  return(list(weights=w, angle=result$root,precision=abs(result$f.root)))
  
  
}
