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
local scratch_dir "/gpfs/scratch/azc211/ny_mergers"

* Date
local today: di %tdCCYYNNDD date(c(current_date), "DMY")

* Filepaths
local log_file "`scratch_dir'/logs/collapse_hhi_ny_sid_supp_`today'.smcl"


********************************************
* Log start
log using "`log_file'", replace

* Data
use "`proj_dir'/data_hospclean/hhi_ny_sid_supp.dta", clear

* Keep only matched merged results for now
	keep if _merge==3

* Prepare data for collapse to hospital-level
	
	* Patient-level variables
		gen discharges = 1

		replace pay1 = 7 if pay1==.

	* collapse newborn utilizations
		egen u_newbn = rowtotal(u_newbn*), missing
		order u_newbn, before(u_newbn2l)
		drop u_newbn2l u_newbn3l u_newbn4l
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

		local id_vars "ahaid_temp sysid_coop_temp year"

********************************************
* Collapse data to hospital-year level

	fcollapse (mean) `bed_vars' `own_vars' `hhi_vars' `merger_vars' (sum) discharges `util_vars', by(`id_vars' pay1) fast

	tempfile collapsed
	save `collapsed', replace

	* Save hospital-level variables
	keep `bed_vars' `own_vars' `hhi_vars' `merger_vars' `id_vars'
	duplicates drop `id_vars', force

	tempfile hospital
	save `hospital', replace

	* Reshape patient-level variables wide by payer type
	use `collapsed', clear

		keep discharges pay1 `util_vars' `id_vars'

		reshape wide `util_vars' discharges, i(`id_vars') j(pay1)

	* Calculate discharge and utilization totals for all payer types
		foreach var in `util_vars' discharges {
			* Capture payer type subtotals
			qui lookfor `var'
			local var_subtotals `r(varlist)'

			egen `var' = rowtotal(`var_subtotals')
			label var `var' "Total"
		}

	* Merge on hospital-level data
		merge 1:1 `id_vars' using `hospital', assert(3) nogen

	* Decode id vars
		decode ahaid_temp, gen(ahaid)
		decode sysid_coop, gen(sysid_coop)
		drop ahaid_temp sysid_coop_temp

		order ahaid sysid_coop year, first


	save "`proj_dir'/data_hospclean/hhi_ny_sid_supp_hosp.dta", replace
	!chmod g+rw "`proj_dir'/data_hospclean/hhi_ny_sid_supp_hosp.dta"


********************************************
* Log close
log close

