********************************************
* Genearte summary statistics of utilization services in NY SID Supplemental data
********************************************


********************************************
clear
set more off


********************************************
* Macros

* User arguments
local sample `1'

* Directories
local proj_dir "/gpfs/data/desailab/home/ny_mergers"
local scratch_dir "/gpfs/scratch/azc211/ny_sid"

* Filepaths
local log_file "`scratch_dir'/logs/ny_sid.smcl"

* Varlist
local vars "key pstco hospstco ahaid year ayear pay1 zipinc_qrtl u_blood u_cath u_ccu u_chestxray u_ctscan u_dialysis u_echo u_ed u_eeg u_ekg u_epo u_icu u_lithotripsy u_mhsa u_mrt u_newbn2l u_newbn3l u_newbn4l u_nucmed u_observation u_occtherapy u_organacq u_othimplants u_pacemaker u_phytherapy u_radtherapy u_resptherapy u_speechtherapy u_stress u_ultrasound"


********************************************
* Read in NY SID Supplemental data

log using "`log_file'"

use "`proj_dir'/data_sidclean/sid_work/ny_sid_0612_supp.dta", clear

keep `vars'

if `sample' {
	* Take 15% sample
	sample 15
}

compress

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
* Close log
log close
