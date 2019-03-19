********************************************
* Construct hospital-level hhi measures
********************************************

clear
set more off


********************************************
* MACROS
********************************************

* Directories
global proj_dir "/gpfs/data/desailab/home"
global scratch_dir "/gpfs/scratch/azc211/ny_mergers"

* Date
local today: di %tdCCYYNNDD date(c(current_date), "DMY")

* Log file
local log_file "$scratch_dir/logs/construct_hospital_hhi_`today'.smcl"


********************************************
* RUN PROGRAM
********************************************

log using `log_file', replace
cap log close

* Check for ftools package
cap which ftools
if _rc==111 ssc install ftools

use "$proj_dir/ny_mergers/data_hospclean/ahacooperall_cleaned.dta", clear

	keep if fstcd==36
	keep id sysid2 year
	rename id ahaid
		encode ahaid, gen(ahaid_cd)
	rename sysid2 sysid
		encode sysid, gen(sysid_cd)

	tempfile sysids
	save `sysids', replace

use "$proj_dir/ny_mergers/data_sidclean/sid_work/ny_sid_0612_supp.dta", clear

	tempfile master
	save `master', replace

* Standard HHI (share of commercially-insured patients within each zipcode-MDC combination)
********************************************
	* Collapse private insurance discharges to zip-mdc-hospital-year level
		keep if pay1==3
		gen discharge = 1

		* Encode string id variables for ftool functions
		foreach var of varlist zip ahaid {
			encode `var', gen(`var'_cd)
		}

		join sysid_cd, from(`sysids') by(ahaid_cd year)

		fcollapse (sum) discharges=discharge, by(zip_cd mdc ahaid_cd year) fast

	* HHI_z,m
	bysort zip_cd mdc year: egen total_discharges = total(discharges)


qui levelsof zip_id, local(zips) clean
foreach zip of local zips {
	qui levelsof mdc if zip_id==`zip', local(mdcs) clean
	foreach mdc of local mdcs {

	}
}
	

* Hospital-specific HHI
********************************************
