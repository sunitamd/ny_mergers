********************************************
* Collapse HCUP NY SID SUPP data into utilization flag x drg codes for exploratory analysis
********************************************

clear
set more off


********************************************
* Macros

local proj_dir "/gpfs/data/desailab/home/ny_mergers"


********************************************
* Run program

use "`proj_dir'/data_hospclean/hhi_ny_sid_supp.dta", clear

	* Capture utilization flag variables
	qui lookfor u_
	local util_vars `r(varlist)'
	* Create discharge variable
	gen ds = 1

	fcollapse (sum) ds, by(`util_vars' drg pay1) fast

	save "dump/ny_sid_util_drg.dta", replace
