# Package “Angular_Combining”

## November 21, 2024

## 1 Overview

This R package implements several combining methods in the paper by Taylor and Meng (2024), entitled
“Angular Combining of Forecasts of Probability Distributions”. In this R package, the output for each
combining method is a random sample of values from the CDF forecast produced by the combining method.
The R package includes the following combining methods:

1. Angular averaging - To generate CDF forecasts, the package uses the simulation algorithm, detailed
in Online Appendix C of the paper. The angle can be subjectively chosen or optimized by minimizing the
CRPS for the estimation sample. The angle can also be chosen so that the CDF forecast has the desired
standard deviation (lying between the standard deviations of horizontal and vertical combining), as discussed
in the final paragraph of Section 6.9 of the paper.
2. Angular weighted combining - The angle and weights can be subjectively chosen or optimized. The
weights are chosen as inversely proportional to the in-sample CRPS of the individual methods, or inversely
proportional to their in-sample CRPS raised to the power of a tuning parameter.
3. Horizontal and vertical averaging, and horizontal and vertical weighted combining.
4. Switching between horizontal and vertical averaging, and switching between horizontal and vertical
weighted combining.
5. Secondary weighted combining - This set of methods is discussed in the final paragraph of Section
6.9 of the paper. The user can choose between vertical weighted combining of horizontal and vertical
averaging, horizontal weighted combining of horizontal and vertical averaging, vertical weighted combining
of horizontal and vertical weighted combining, and horizontal weighted combining of horizontal and vertical
weighted combining.

## 2 Contents

The required libraries for the package are “stats” and “scoringRules”. The package contains the following
files:


- Examples.R
- - CRPS.R
- Estimate_angular_combining.R
- Estimate_angular_weights.R
- Estimate_secondary_combining.R
- Estimate_targeting_variance.R
- Forecast_angular.R
- Forecast_secondary_combining.R
- Simulation_angular.R


The rest of this document provides a description for each of these files. For clarity, we assume we are working
with in-sample historical data containingmtime points. At each time point, we have a single historical
observation andk individual forecasts that we aim to aggregate. The package employs the simulation
algorithm detailed in Online Appendix C of Taylor and Meng (2024), to estimate CDF forecasts. We
generate a random sample of sizenfrom each of thek individual models at each time point, for both
parameter estimation and prediction.

## 2.1 CRPS.R

Description:

This function computes the average CRPS over a sample period for angular combining.

Usage:

CRPS <- function(F_inv_list,
angle,
w,
data,
n,
seed = NULL)

Inputs:

```
F_inv_list: it stores the inverse CDFs (also known as quantile functions) from each individual fore-
casting method. It is structured as a list withmelements, one for each time point in the
in-sample period. Within each of these elements is another list of lengthk, representing
the inverse CDFs for each of thekindividual forecasting methods at that specific time
point.
```
```
angle: angle for angular combining.
```
```
w: vector of combining weights.
```
```
data: in-sample data.
```
```
n: number of values to generate in the simulation algorithm.
```
```
seed: random seed for reproducibility. The default is NULL.
```
Outputs:

```
average CRPS for angular combining
```
## 2.2 Estimate_angular_combining.R

Description:

This function estimates the angle and combining weights for angular combining fitted to historical data.

Usage:

Estimate_angular_combining <- function(F_inv_list,
weights,
data,
n,
grid = pi/2/90*seq(0, 90, by = 1),
local_opt = TRUE,


```
seed = NULL,
lossfunction = “crps”,
target_weight = NULL)
```
Inputs:

```
F_inv_list: it stores the inverse CDFs (also known as quantile functions) from each individual fore-
casting method. It is structured as a list withmelements, one for each time point in the
in-sample period. Within each of these elements is another list of lengthk, representing
the inverse CDFs for each of thekindividual forecasting methods at that specific time
point.
```
```
weights: string specifying the combining weights: “averaging” (equal weights), “inverse crps”
(weights are inversely proportional to individual methods’ in-sample CRPS), or “inverse
crps tuning” (weights are inversely proportional to individual methods’ in-sample CRPS
raised to the power of a tuning parameter).
data: in-sample data.
```
```
n: number of values to generate in the simulation algorithm.
grid: the set of parameter values searched during the optimization of the angle. The default
is a grid of 0 ◦, 1 ◦,..., 90 ◦.
```
```
local_opt: i) TRUE (default), perform local optimization algorithm after the grid search. ii)
FALSE, do not perform local optimization algorithm after the grid search (used in
vertical and horizontal switching).
seed: random seed for reproducibility. The default is NULL.
```
```
lossfunction: i) (minimizing) “crps” (default) ii) (matching) “target standard deviation”.
target_weight: only used when lossfunction=“target standard deviation”, and target standard deviation=
target weight×σV+ (1−target weight)×σH, whereσVandσHare the standard devi-
ations for vertical and horizontal combining.
```
Outputs:

```
w: vector of combining weights.
angle: angle for angular combining.
```
```
CRPS: average CRPS.
```
```
tuning: tuning parameter for the “inverse crps tuning” method, if applicable.
```
## 2.3 Estimate_angular_weights.R

Description:

This intermediate function is used within “Estimate_angular_combining.R” to estimate the combining
weights for angular combining fitted to historical data.

Usage:

Estimate_angular_weights <- function(F_inv_list,
weights,
data,
n,
seed = NULL,
angle = NULL)


Inputs:

```
F_inv_list: it stores the inverse CDFs (also known as quantile functions) from each individual fore-
casting method. It is structured as a list withmelements, one for each time point in the
in-sample period. Within each of these elements is another list of lengthk, representing
the inverse CDFs for each of thekindividual forecasting methods at that specific time
point.
```
```
weights: string specifying the combining weights: “averaging” (equal weights), “inverse crps”
(weights are inversely proportional to individual methods’ in-sample CRPS), or “inverse
crps tuning” (weights are inversely proportional to individual methods’ in-sample CRPS
raised to the power of a tuning parameter).
```
```
data: in-sample data.
```
```
n: number of values to generate in the simulation algorithm.
```
```
seed: random seed for reproducibility. The default is NULL.
```
```
angle: angle for angular combining. It is used only for horizontal and vertical combining when
weights have been chosen as “inverse crps tuning”. The default is NULL, in which case
the angle will be estimated in “Estimate_angular_combining.R”.
```
Outputs:

```
w: vector of combining weights.
```
```
tuning: tuning parameter for the “inverse crps tuning” method, if applicable.
```
## 2.4 Estimate_secondary_combining.R

Description:

This function estimates the combining weight for the following secondary combining methods: vertical
weighted combining of horizontal and vertical averaging, horizontal weighted combining of horizontal and
vertical averaging, vertical weighted combining of horizontal and vertical weighted combining, or horizontal
weighted combining of horizontal and vertical weighted combining.

Usage:

Estimate_secondary_combining <- function(F_inv_list,
first_weights,
sec_method,
data,
n,
seed = NULL)

Inputs:

```
F_inv_list: it stores the inverse CDFs (also known as quantile functions) from each individual fore-
casting method. It is structured as a list withmelements, one for each time point in the
in-sample period. Within each of these elements is another list of lengthk, representing
the inverse CDFs for each of thekindividual forecasting methods at that specific time
point.
```
```
first_weights: combining methods involved in vertical and horizontal combining for the first stage, “av-
eraging” (equal weights), “inverse crps” (weights are inversely proportional to individual
methods’ in-sample CRPS), or “inverse crps tuning” (weights are inversely proportional
to individual methods’ in-sample CRPS raised to the power of a tuning parameter).
```

```
sec_method: secondary combining method, “vertical combining” or “horizontal combining”.
```
```
data: in-sample data.
```
```
n: number of values to generate in the simulation algorithm.
```
```
seed: random seed for reproducibility. The default is NULL.
```
Outputs:

```
ind_weights: weights involved in vertical and horizontal combining for the first stage.
```
```
sec_weight: secondary combining weight.
```
```
angle: type of secondary combining, 0 or pi/2, representing horizontal or vertical combining.
```
## 2.5 Estimate_targeting_variance.R

Description:

This intermediate function is used within “Estimate_angular_combining.R” when users specify “lossfunc-
tion=target standard deviation”. Given a set of combining weights, it determines the angle that aligns the
standard deviation of this angular combining method with a target standard deviation. This target standard
deviation is calculated as a weighted average of the standard deviations from horizontal and vertical com-
bining methods. That is, target standard deviation=target weight×σV+ (1−target weight)×σH, where
σVandσHare the standard deviations for vertical and horizontal combining.

Usage:

Estimate_targeting_variance <- function(F_inv_list,
weights,
target_weight,
data,
n,
seed = NULL)

Inputs:

```
F_inv_list: it stores the inverse CDFs (also known as quantile functions) from each individual fore-
casting method. It is structured as a list withmelements, one for each time point in the
in-sample period. Within each of these elements is another list of lengthk, representing
the inverse CDFs for each of thekindividual forecasting methods at that specific time
point.
```
```
weights: string specifying the combining weights: “averaging” (equal weights), “inverse crps”
(weights are inversely proportional to individual methods’ in-sample CRPS), or “inverse
crps tuning” (weights are inversely proportional to individual methods’ in-sample CRPS
raised to the power of a tuning parameter).
```
```
target_weight: weight between horizontal and vertical combining, target standard deviation=target weight×
σV+ (1−target weight)×σH
```
```
data: in-sample data.
```
```
n: number of values to generate in the simulation algorithm.
```
```
seed: random seed for reproducibility. The default is NULL.
```

Outputs:

```
w: vector of combining weights.
```
```
angle: angle for angular combining.
```
```
precision: absolute error of the difference between the standard deviation of the angular combina-
tion and the target standard deviation.
```
## 2.6 Examples.R

This file contains illustrative examples demonstrating how to implement the models listed in Section 1 of
this document. In “Examples.R”, simulated data is used, with the two individual CDF forecasts being the
same as those in the illustrative example in Section 2.1 of the paper by Taylor and Meng (2024). The two
individual CDFs Gaussian have means of -0.15 and 0.15, and standard deviations of 0.1. The data generating
process is a Gaussian distribution having mean of 0 and standard deviation of 0.15. In “Examples.R”, Section
1 loads all the libraries and functions, Section 2 loads the simulated data, and Section 3 contains examples
showing how to implement each combining method listed in Section 1 of this document.

## 2.7 Forecast_angular.R

Description:

The function produces the CDF forecast for angular combining.

Usage:

Forecast_angular <- function(F_inv_list,
w,
angle,
n,
seed = NULL)

Inputs:

```
F_inv_list: it stores the inverse CDFs (also known as quantile functions) from each individual fore-
casting method. It is structured as a list withmelements, one for each time point in the
in-sample period. Within each of these elements is another list of lengthk, representing
the inverse CDFs for each of thekindividual forecasting methods at that specific time
point.
```
```
w: vector of combining weights.
```
```
angle: angle for angular combining.
```
```
n: number of values to generate in the simulation algorithm.
```
```
seed: random seed for reproducibility. The default is NULL.
```
Outputs:

```
Sample: random sample of sizendrawn from the resulting combined CDF.
```
```
F_inv: the inverse CDF function estimated from the random sample.
```

## 2.8 Forecast_secondary_combining.R

Description:

The function produces the CDF forecast for the secondary angular combination of vertical and horizontal
combinations.

Usage:

Forecast_secondary_combining <- function(F_inv_list,
angle,
ind_weights,
sec_weight,
n,
seed = NULL)

Inputs:

```
F_inv_list: it stores the inverse CDFs (also known as quantile functions) from each individual fore-
casting method. It is structured as a list withmelements, one for each time point in the
in-sample period. Within each of these elements is another list of lengthk, representing
the inverse CDFs for each of thekindividual forecasting methods at that specific time
point.
```
```
angle: type of secondary combining, 0 or pi/2, representing horizontal or vertical combining.
```
```
ind_weights: weights involved in vertical and horizontal combining for the first stage. Equal weights
represent vertical and horizontal averaging.
```
```
sec_weight: secondary combining weight.
```
```
n: number of values to generate in the simulation algorithm.
```
```
seed: random seed for reproducibility. The default is NULL.
```
Outputs:

```
Sample: random sample of sizendrawn from the resulting combined CDF.
```
```
F_inv: the inverse CDF function estimated from the random sample.
```
## 2.9 Simulation_angular.R

Description:

The function simulates a random sample for angular combining. Users need to provide all the parameters.

Usage:

Simulation_angular <- function(F_inv,
w,
angle,
n,
seed = NULL)


Inputs:

```
F_inv_list: it stores the inverse CDFs (also known as quantile functions) from each individual fore-
casting method. It is structured as a list withmelements, one for each time point in the
in-sample period. Within each of these elements is another list of lengthk, representing
the inverse CDFs for each of thekindividual forecasting methods at that specific time
point.
```
```
w: vector of combining weights.
```
```
angle: angle for angular combining.
```
```
n: number of values to generate in the simulation algorithm.
```
```
seed: random seed for reproducibility. The default is NULL.
```
Outputs:

```
random sample of sizenfor angular combining.
```

