# This "Examples.R" file contains illustrative examples demonstrating how to implement the models listed in Section 1 of this document. 
# In this file, simulated data is used, with the two individual CDF forecasts being the same as those in the illustrative example in Section 2.1 of the paper by Taylor and Meng (2024). 
# The two individual CDFs Gaussian have means of -0.15 and 0.15, and standard deviations of 0.1. The data generating process is a Gaussian distribution having mean of 0 and standard deviation of 0.15.
# In this file, Section 1 loads all the libraries and functions, Section 2 loads the simulated data, and Section 3 contains examples showing how to implement each combining method listed in Section 1 of this document.

# ---- Section 1: Load libraries and intermediate functions ----

# Remove all variables
rm(list = ls())
# Close all open graphical devices (clear plots)
while (dev.cur() > 1) {
  dev.off()
}
# Set path
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

# Load libraries
library(stats)
library(scoringRules)

# load intermediate functions
source("Simulation_angular.R")
source("CRPS.R")
source("Estimate_angular_weights.R")
source("Forecast_angular.R")
source("Estimate_targeting_variance.R")
source("Estimate_secondary_combining.R")
source("Estimate_angular_combining.R")
source("Forecast_secondary_combining.R")

# ---- Section 2: Load data. The data are simulated and only used for illustration. ----

m <- 100 # Insample length

# For each time point, we assume there are two individual predictions to combine, 
# both following normal distributions that do not vary over time.
F_inv1 <- function(p) qnorm(p, mean = -0.15, sd = 0.1)
F_inv2 <- function(p) qnorm(p, mean = 0.15, sd = 0.1)

# F_inv_list stores the inverse CDFs (also known as quantile functions) from each individual forecasting method. 
# It is structured as a list with m elements, one for each time point in the in-sample period. Within each of these elements is another list of length k, 
# representing the inverse CDFs for each of the k individual forecasting methods at that specific time point.
# The final entry F_inv_list[[m+1]] is viewed as the first out-of-sample predictions.
temp1 <- list(F_inv1, F_inv2)
k=length(temp1) # number of individual predictions
F_inv_list <- vector("list", m+1)
for (i in 1:(m+1)) {
  F_inv_list[[i]]=temp1
}

set.seed(123) # Fix a random seed for reproducibility
# Simulate a random sample of length m from a normal distribution
data<- rnorm(m, 0, sd = 0.15)



n <- 1000 # Specify the number of values to generate in the simulation algorithm.
seed=120 # Fix a random seed for reproducibility



# ---- Section 3: Examples ----
# ---- Section 3.1 Angular averaging ----

# 3.1.1 The angle is estimated by minimizing the insample CRPS.
#       Mdl=Estimate_angular_combining(F_inv_list=F_inv_list[1:m],weights="averaging",data=data,n=n,seed=seed)
# 3.1.2 The angle is estimated to have the desired standard deviation lying between the standard deviations of 
#       horizontal and vertical averaging), "target_weight[1]*sigma_V+targer_weight[2]*sigma_H"
#       Mdl=Estimate_angular_combining(F_inv_list[1:m],weights="averaging",lossfunction="target standard deviation",target_weight=c(0.3,0.7), data,n,seed=120)
# 3.1.3 Custom angle: there is no parameter to estimate, and we just need to specify an angle (say pi/4) and use equal weights
#       Mdl <- list(weights=c(0.5,0.5),angle=pi/4)

# 3.1.4 Make a prediction
#       Prediction=Forecast_angular(F_inv_list[[m+1]],Mdl$weights,Mdl$angle, n,seed = seed)



# ---- Section 3.2 Angular weighted combining ----

# 3.2.1 The weights are "inverse crps". The angle is estimated by minimizing the insample CRPS.
#       Mdl=Estimate_angular_combining(F_inv_list=F_inv_list[1:m],weights="inverse crps",data=data,n=n,seed=seed)

# 3.2.2 The weights are "inverse crps tuning". The angle and tuning parameter are are simultaneously estimated by minimizing the in-sample CRPS.
#       Mdl=Estimate_angular_combining(F_inv_list[1:m],weights="inverse crps tuning",data=data,n=n,seed=seed)

# 3.2.3 The weights are "inverse crps" or "inverse crps tuning". The angle is estimated to have the desired standard deviation lying between the standard deviations of 
#       horizontal and vertical averaging), "target_weight[1]*sigma_V+target_weight[2]*sigma_H"
#       Mdl=Estimate_angular_combining(F_inv_list[1:m],weights="inverse crps",lossfunction="target standard deviation",target_weight=c(0.3,0.7), data,n,seed=120)
#       Mdl=Estimate_angular_combining(F_inv_list[1:m],weights="inverse crps tuning",lossfunction="target standard deviation",target_weight=c(0.3,0.7), data,n,seed=120)

# 3.2.3 Custom angle and weights: there is no parameter to estimate, and we just need to specify an angle (say pi/4) and weights (say c(0.2,0.8))
#       Mdl <- list(weights=c(0.2,0.8),angle=pi/4)

# 3.2.4 Make a prediction
#       Prediction=Forecast_angular(F_inv_list[[m+1]],Mdl$weights,Mdl$angle, n,seed = seed)



# ---- Section 3.3 Horizontal and vertical averaging/combining ----

# 3.3 Horizontal and vertical averaging and weighted combining: Special cases of angular averaging/combining.

# 3.3.1 Horizontal averaging: There is no parameter to estimate, and we just need to set angle = 0 and use equal weights.
#       Mdl <- list(weights=c(0.5,0.5),angle=0)

# 3.3.2 Vertical averaging: There is no parameter to estimate, and we just need to set angle = pi/2 and use equal weights.
#       Mdl <- list(weights=c(0.5,0.5),angle=pi/2)

# 3.3.3 Horizontal weighted combining: It is a special case of angular weighted combining that requires only setting angle = 0.
#       Combining weights are either "inverse crps" or "inverse crps tuning"
#       Mdl=Estimate_angular_combining(F_inv_list=F_inv_list[1:m],weights="inverse crps",data=data,n=n,seed=seed,local_opt = FALSE,grid=0)
#       Mdl=Estimate_angular_combining(F_inv_list=F_inv_list[1:m],weights="inverse crps tuning",data=data,n=n,seed=seed,local_opt = FALSE,grid=0)

# 3.3.4 Vertical weighted combining: It is a special case of angular weighted combining that requires only setting angle = pi/2.
#       Combining weights are either "inverse crps" or "inverse crps tuning"
#       Mdl=Estimate_angular_combining(F_inv_list=F_inv_list[1:m],weights="inverse crps",data=data,n=n,seed=seed,local_opt = FALSE,grid=pi/2)
#       Mdl=Estimate_angular_combining(F_inv_list=F_inv_list[1:m],weights="inverse crps tuning",data=data,n=n,seed=seed,local_opt = FALSE,grid=pi/2)

# 3.3.5 Make a prediction
#       Prediction=Forecast_angular(F_inv_list[[m+1]],Mdl$weights,Mdl$angle, n,seed = seed)



# ---- Section 3.4 Horizontal/vertical switching ----

# 3.4.1 Switching between horizontal and vertical averaging. The output is either horizontal or vertical averaging, depending on which achieves the lower in-sample CRPS.
#       Mdl=Estimate_secondary_combining(F_inv_list[1:m],sec_method = "switching", first_weights="averaging",data,n,seed = seed)

# 3.4.2 Switching between horizontal and vertical weighted combining. The output is either horizontal or vertical weighted combining, depending on which achieves the lower in-sample CRPS.
#       Mdl=Estimate_secondary_combining(F_inv_list[1:m],sec_method = "switching", first_weights="inverse crps",data,n,seed = seed)
#       Mdl=Estimate_secondary_combining(F_inv_list[1:m],sec_method = "switching", first_weights="inverse crps tuning",data,n,seed = seed)

# 3.4.3 Make a prediction
#       Prediction=Forecast_secondary_combining(F_inv_list[[m+1]],angle=Mdl$angle,ind_weights=Mdl$ind_weights, sec_weight=Mdl$sec_weight,n,seed = seed)



# ---- Section 3.5 Secondary weighted combining ----

# 3.5.1: Secondary horizontal weighted combining between vertical and horizontal weighted combinations. The secondary combining weight is estimated by minimizing the insample CRPS.
#        Mdl=Estimate_secondary_combining(F_inv_list[1:m],sec_method = "horizontal combining", first_weights="averaging",data,n,seed=seed)
#        Mdl=Estimate_secondary_combining(F_inv_list[1:m],sec_method = "horizontal combining", first_weights="inverse crps",data,n,seed=seed)
#        Mdl=Estimate_secondary_combining(F_inv_list[1:m],sec_method = "horizontal combining", first_weights="inverse crps tuning",data,n,seed=seed) 

# 3.5.2: Secondary vertical weighted combining between vertical and horizontal weighted combinations. The secondary combining weight is estimated by minimizing the in-sample CRPS.
#        Mdl=Estimate_secondary_combining(F_inv_list[1:m],sec_method = "vertical combining", first_weights="averaging",data,n,seed=seed) 
#        Mdl=Estimate_secondary_combining(F_inv_list[1:m],sec_method = "vertical combining", first_weights="inverse crps",data,n,seed=seed) 
#        Mdl=Estimate_secondary_combining(F_inv_list[1:m],sec_method = "vertical combining", first_weights="inverse crps tuning",data,n,seed=seed)

# 3.5.3 Make a prediction
#       Prediction=Forecast_secondary_combining(F_inv_list[[m+1]],angle=Mdl$angle,ind_weights=Mdl$ind_weights, sec_weight=Mdl$sec_weight,n,seed = seed)




#  ---- Check the histogram of prediction ---- 
      hist(Prediction$Sample)






