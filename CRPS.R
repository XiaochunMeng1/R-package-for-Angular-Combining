CRPS <- function(F_inv_list, angle, w, data, n, seed = NULL)
{
 
  

  score <- numeric(length(F_inv_list))
  

  for (i in 1:length(F_inv_list)) {
    random_sample <- Simulation_angular(F_inv_list[[i]], w, angle, n, seed)
    
    score[i] <- crps_sample(data[[i]], random_sample)
  }
  
  
  return(mean(score))
  
  
}
