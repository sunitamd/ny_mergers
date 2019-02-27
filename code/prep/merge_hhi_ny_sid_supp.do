********************************************
* Merge together market- and hospital-level datasets to HCUP NY SID SUPP dataset
********************************************
clear
set more off


********************************************
* Macros

* Directories
local proj_dir "/gpfs/data/desailab/home/ny_mergers"
local scratch_dir "/gpfs/scratch/azc211/ny_sid"

* Filepaths
local log_file "`scratch_dir'/logs/ny_sid.smcl"


********************************************
* Start log
log using "`log_file'", replace

* Data

* Market-level HHI data
di in red "...prepping market-level HHI data..."
use "`proj_dir'/data_hospclean/ny_treatcontrol_Feb 12.dta", clear

* prep for merge
	tostring cnty, replace

tempfile market_hhi
save  `market_hhi', replace

* Hospital-level HHI data
di in red "...prepping hospital-level HHI data..."
use "`proj_dir'/data_hospclean/hospmerger_ny_fin0210.dta", clear

* prep for merge
	tostring fstcd, replace
	rename _merge _merge1
	label var _merge1 "_merge results btwn AHA & Cooper"

* Merge market-level HHI data
di in red "...merging market-level HHI to hospital-level HHI"
	merge m:1 cnty year using `market_hhi', assert(3) nogen

* prep for merge to NY SID SUPP
	tostring id, gen(ahaid)
	drop id
	compress

	tempfile hhi
	save `hhi', replace

* Merge NY SID SUPP 2006-2012 data
di in red "...merging HCUP NY SID SUPP 2006-2012 data..."
	merge 1:m ahaid year using "`proj_dir'/data_sidclean/sid_work/ny_sid_0612_supp.dta", gen(_merge)

	label var _merge "_merge results btwn HHI & NY SID SUPP"
	label define L_merge 1 "1 HHI (master)" 2 "2 NY SID SUPP (using)" 3 "3 matched", modify
	label values _merge L_merge


save "`proj_dir'/data_hospclean/hhi_ny_sid_supp.dta", replace

********************************************
* Close log
log close
