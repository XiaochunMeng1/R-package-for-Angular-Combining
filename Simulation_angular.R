
Simulation_angular <- function(F_inv, w,angle, n,seed = NULL) {
  
  
  set.seed(seed) 

  if ((sum(w)- 1)^2>10^-7) {
    stop("Weights do not sum up to 1")
  }

  else if (angle<0 | angle>pi/2) {
    stop("The angle must be acute")
  }


  else if (length(w) != length(F_inv)) {
    stop("Dimensions of the weights and quantile functions are not consistent")
  }
  
  else
  {
  
    # If angle is very small, it is treated as the horizontal combining
  if (tan(angle) < 10^-3) {
    u <- runif(n)
    
    temp= lapply(F_inv, function(f) f(u))
    temp <- Map(`*`, temp, w)
    
    tilde_s<- Reduce(`+`, temp)
    
  } else {
    # Step 1: Generating n randomly sampled values, {s1,...,sn} from the vertical combination of the transformed distributions.
    u <- runif(n)
    index <-sample(1:length(F_inv),n,replace = TRUE,prob = w)
    
    
    s0 <- matrix(NA, nrow = n, ncol = length(F_inv))
    
    for (i in seq_along(F_inv)){
      s0[,i]=F_inv[[i]](u)+ u / tan(angle)
    }
    
    s=s0[cbind(1:n, index)]
   
    # Step 2: Convert {s1,...,sn} to a random sample {tilde_s1,...,tilde_sn}
    # Sort {s1,...,sn} in ascending order
    s_sorted <- sort(s)
    
    
    # Apply inverse quantile transform
    tilde_s=s_sorted-(1:n)/(n* tan(angle))
  }
  
  
  return(tilde_s)}
  
}

