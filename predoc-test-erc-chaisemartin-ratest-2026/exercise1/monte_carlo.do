*----------------------------------------------------------------------*
* monte_carlo.do  Exercise 1, part (h)                                 *
* compares theta_MM = 2*mean(Y) and theta_ML = max(Y) for U[0, theta]  *
*----------------------------------------------------------------------*

clear all
set more off
set varabbrev off
version 19

local outdir "/Users/sid/Desktop/Git/Chaisemartin/submission/exercise1"

local n     = 1000
local theta = 1

*--- part 1: single sample, theta = 1 ---

set seed 12345
clear
set obs `n'
gen y = runiform()     
su y, meanonly
local theta_mm = 2 * r(mean)
local theta_ml = r(max)
local err_mm   = abs(`theta_mm' - `theta')
local err_ml   = abs(`theta_ml' - `theta')

disp _n "theta_MM = " %9.6f `theta_mm' "    theta_ML = " %9.6f `theta_ml'
disp    "|err_MM| = " %9.6f `err_mm'   "    |err_ML| = " %9.6f `err_ml'

*--- part 2: 1000 replications, rescaled estimators in a tempfile ---

set seed 67890
local R = 1000

tempfile mc
cap postclose mc
postfile mc double a_r double b_r double theta_mm_rep double theta_ml_rep ///
    using "`mc'", replace

forvalues r = 1/`R' {
    qui {
        clear
        set obs `n'
        gen y = runiform()
        su y, meanonly
        local mm = 2 * r(mean)
        local ml = r(max)
        local a  = sqrt(`n') * (`mm' - `theta')
        local b  = `n' * (`theta' - `ml') / `theta'
        post mc (`a') (`b') (`mm') (`ml')
    }
}
postclose mc

use "`mc'", clear
su a_r b_r theta_mm_rep theta_ml_rep

*--- plots: a_r against N(0, 1/3); b_r against Exp(1) ---

twoway ///
    (histogram a_r, density width(0.05) color(gs13) lcolor(gs8)) ///
    (function y = normalden(x, 0, sqrt(1/3)), range(-2.5 2.5) lwidth(medthick)), ///
    title("CLT for sqrt(n) (theta_MM - theta)") ///
    subtitle("R = `R' replications, n = `n'") ///
    xtitle("sqrt(n) (theta_MM - 1)") ytitle("Density") ///
    legend(order(1 "Monte Carlo histogram" 2 "N(0, 1/3) density")) ///
    graphregion(color(white))
graph export "`outdir'/ex1_mm_clt.pdf", replace

twoway ///
    (histogram b_r, density width(0.25) color(gs13) lcolor(gs8)) ///
    (function y = exp(-x), range(0 8) lwidth(medthick)), ///
    title("Super consistency of theta_ML") ///
    subtitle("R = `R' replications, n = `n'") ///
    xtitle("n (theta - theta_ML) / theta") ytitle("Density") ///
    legend(order(1 "Monte Carlo histogram" 2 "Exp(1) density")) ///
    graphregion(color(white))
graph export "`outdir'/ex1_ml_exp.pdf", replace
