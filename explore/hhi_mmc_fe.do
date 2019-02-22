********************************************
* Preliminary analysis of impact of mergers on medicaid enrollees
********************************************

clear
set more off


********************************************
* Macros

local proj_dir  "/gpfs/data/desailab/home/ny_mergers"


********************************************
* Read in medicaid enrollee data

use "`proj_dir'/data_hospclean/mmc_totals.dta", clear

* Collapse to county-year level
qui lookfor _ms
local vars "`r(varlist)'"
qui lookfor  _mo
local vars = "`vars' `r(varlist)'"
collapse (mean) total_enroll `vars', by(county year)

tempfile mmc
save `mmc', replace

* Read in NY county fips

import excel using "`proj_dir'/inputs/ny_fips.xlsx", firstrow clear

tostring cnty_fips, replace format(%003.0f)
replace county = trim(subinstr(county, "County", "", 1))
replace county = "St Lawrence" if county=="St. Lawrence"

tempfile ny_fips
save `ny_fips', replace

* Read in hospital mergers dataset

use "`proj_dir'/data_hospclean/ny_treatcontrol_Feb 12.dta", clear

* map FIPS cnty code to county name
tostring cnty, gen(cnty_fips)
replace cnty_fips = substr(cnty_fips, -3,3)

merge m:1 cnty_fips using `ny_fips', nogen assert(2 3) keep(3)

replace county = "NYC" if inlist(cnty_fips, "005", "047",  "061", "081", "085")

* collapse (max) anymerger* anytarget* anyacquierer post_anymerger (sum) nmerger ntarget nacquier nhosps nadm n_admcare n_admcaid numsys cnt(mean) avg_hhi_cnty avg_hhisys_cnty, by(year county fstcd)
collapse (mean) avg_hhisys_cnty, by(county year)

merge 1:1 year county using `mmc', assert(2 3) keep(3) nogen


********************************************
* Run linear fixed effects model

gen total_enroll_lg = log(total_enroll)
egen county_id = group(county)

xtset county_id year

xtreg total_enroll_lg avg_hhisys_cnty i.year if county!="NYC", fe

* Predict county-level time-invariant fixed effects
predict county_effect, u
* Predicted total_enrollment including county-level FE
predict total_enroll_hat, xbu
* Predict standard error of prediction (w/o county-level FE)
predict total_enroll_se, stdp





