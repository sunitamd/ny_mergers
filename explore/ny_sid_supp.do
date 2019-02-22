********************************************
* Summary statistics of utilization services in NY SID
********************************************

log using "/gpfs/scratch/azc211/ny_sid/logs/ny_sid_supp.smcl", replace

clear
set more off


********************************************
* Macros

local sample `1'

local proj_dir "/gpfs/data/desailab/home/ny_mergers"
local sample_data "`proj_dir'/data_sidclean/ny_sid_supp/samples/ny_sid_0612_util_sample2.dta"
local full_data "`proj_dir'/data_sidclean/ny_sid_supp/ny_sid_0612_util.dta"


********************************************
* Read in subsetted SID data

if `sample' {
	use "`sample_data'", clear
}
else {
	use "`full_data'", clear
}

* store utilization variables
qui lookfor u_
local util_vars "`r(varlist)'"

* Convert utilization variables into binary indicators
foreach var of varlist `util_vars' {
	gen i_`var' = 1 if `var'!=0
}

tempfile all_data
save `all_data', replace

********************************************
*  Utilization by payer type & year
	qui lookfor i_u_
	local util_vars_i "`r(varlist)'"

	fcollapse (sum) `util_vars_i', by(year pay1) fast

	* Calculate utilization totals by payer types
	fsort year pay1
	foreach var of local util_vars_i {
		by year: egen `var'_tot = total(`var')
	}

	* Cleanup variable names
	rename i_u_* *
	qui ds year pay1 *_tot, not
	local util_vars "`r(varlist)'"

	* Calculate utilization shares by payer types
	foreach var of local util_vars {
		gen `var'_pc = `var' / `var'_tot
	}

	save "dump/ny_sid_supp_pay.dta", replace

********************************************
* Payer type by utilization & year
	use `all_data', clear

	fcollapse (sum) `util_vars_i', by(year pay1) fast

	* Transpose utilization and payer variables
	reshape long i_u_, i(year pay) j(service) string
	rename i_u_ pay_
	reshape wide pay_, i(year service) j(pay1)

	qui lookfor pay_
	local pay_vars "`r(varlist)'"
	encode service, gen(service_id)
	fcollapse (sum) `pay_vars', by(year service_id) fast
	decode service_id, gen(service)

	* Calculate payer type totals, share by utilization services
	fsort year service_id
	foreach var of local pay_vars {
		by year: egen `var'_tot =  total(`var')
		gen `var'_pc = `var' / `var'_tot
	}

	save "dump/ny_sid_supp_util.dta", replace

********************************************
* Utilization by household income quartiles & year
	use `all_data', clear

	fcollapse (sum) `util_vars_i', by(year zipinc_qrtl) fast

	* Calculate utilization totals by income quartiles
	fsort year zipinc_qrtl
	foreach var of local util_vars_i {
		by year: egen `var'_tot = total(`var')
	}

	* Cleanup variable names
	rename i_u_* *
	qui ds year zipinc_qrtl *_tot, not
	local util_vars "`r(varlist)'"

	* Calculate utilization shares by payer types
	foreach var of local util_vars {
		gen `var'_pc = `var' / `var'_tot
	}

	save "dump/ny_sid_supp_inc.dta", replace


********************************************
log close
log translate "/gpfs/scratch/azc211/ny_sid/logs/ny_sid_supp.smcl" "/gpfs/scratch/azc211/ny_sid/logs/ny_sid_supp.log"
