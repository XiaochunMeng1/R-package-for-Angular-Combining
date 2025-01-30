
Forecast_angular <- function(F_inv_list, w,angle, n,seed = NULL) {
  
  
  tilde_s=Simulation_angular(F_inv_list, w,angle, n,seed)

  
  quantile_func <- approxfun(seq(0, 1, length.out = length(tilde_s)), tilde_s, rule = 2)
  
  
  return(list(Sample=tilde_s,F_inv=quantile_func))
}
