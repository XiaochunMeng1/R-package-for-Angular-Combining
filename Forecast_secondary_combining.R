Forecast_secondary_combining <- function(F_inv_list,
                                         angle,
                                         ind_weights,
                                         sec_weight,
                                         n,
                                         seed = NULL) {
  

  F1 <- Forecast_angular(F_inv_list, ind_weights[[1]], pi / 2, n, seed)
  F2 <- Forecast_angular(F_inv_list, ind_weights[[2]], 0, n, seed)
  
  F_inv = list(F1$F_inv, F2$F_inv)
  

  tilde_s = Simulation_angular(F_inv, sec_weight, angle, n, seed)
  
  
  quantile_func <- approxfun(seq(0, 1, length.out = length(tilde_s)), tilde_s, rule = 2)
  
  
  return(list(Sample = tilde_s, F_inv = quantile_func))
}
