********************************************
* Collapse HHI x NY SID SUPP data to hospital-year level
********************************************

clear
set more off

* Install ftools (fast collapse function for large data)
cap ssc install ftools


********************************************
* Macros

* Directories
local proj_dir "/gpfs/data/desailab/home/ny_mergers"
local scratch_dir "/gpfs/scratch/azc211/ny_sid"

* Filepaths
local log_file "`scratch_dir'/logs/collapse_hhi_ny_sid_supp.smcl"


********************************************
* Log start
log using "`log_file'", replace

* Data
use "`proj_dir'/data_hospclean/hhi_ny_sid_supp.dta", clear

* Prepare data for collapse to hospital-level
	* Patient-level variables
	gen discharges = 1

	qui lookfor u_
	local util_vars `r(varlist)'
	* Dichotamize utilitization variables for summing
	foreach var of varlist `util_vars' {
		replace `var' = 1 if `var'>0 & `var'!=.
	}

	* Hospital-level variables
	local bed_vars "bdtot bdtot_orig2"

	qui lookfor own_
	local own_vars `r(varlist)'

	local hhi_vars "hhi_cnty hhisys_cnty avg_hhi_cnty avg_hhisys_cnty"

	local merger_vars "acquirer target"

	* Encode string variables for fcollapse
	encode ahaid, gen(ahaid_temp)
	encode sysid_coop, gen(sysid_coop_temp)
	local by_vars "ahaid_temp sysid_coop_temp year"

********************************************
* Collapse data to hospital-year level

	fcollapse (mean) `bed_vars' `own_vars' `hhi_vars' `merger_vars' (sum) discharges `util_vars', by(`by_vars') fast

	decode ahaid_temp, gen(ahaid)
	decode sysid_coop, gen(sysid_coop)
	drop ahaid_temp sysid_coop_temp


	save "`proj_dir'/data_hospclean/hhi_ny_sid_supp_hosp.dta", replace


********************************************
* Log close
log close

