********************************************
* Run fixed effects regression of HCUP NY SID SUPP outcomes on specified independent variables
* NOTE: this script requires 3 user arguments:
*		1: xvar, name of xvar for model
*		2: hospital-year discharge minimum
*		3: aweight switch 0/1
* Sample run command:
*	sbatch -t 0-1 --mem=8GB code/slurm/stata.sh code/analysis/hcup_outcomes_fe.do hhi_hosp 80 1
********************************************

clear
set more off


********************************************
* MACROS
********************************************

* User args
* xvar for model
local xvarOpt `1'
local avail_xvarOpts `""post_target", "hhi_hosp", "avg_hhisys_cnty_T""'
if !inlist("`xvarOpt'", `avail_xvarOpts') {
	di in red "! ! ! xvar: `xvar' IS NOT CURRENTLY SUPPORTED ! ! !"
	di in red "* * * supported xvars are: `avail_xvarOpts' * * *"
	break
}
* hospital-year discharge minimum threshold
local hosp_year_ds_min `2'
cap confirm number `hosp_year_ds_min'
if _rc {
	if "`hosp_year_ds_min'" == "" {
		local hosp_year_ds_min 0
	}
	else {
		di in red "! ! ! hospital-year discharge min. must be numeric ! ! !"
		di in red "* * * user specified: `hosp_year_ds_min'"
		break
	}
}
* analytical weight switch
local aweight `3'
if "`aweight'" == "" local aweight 0
if !inlist(`aweight', 0, 1) {
	di in red "! ! ! aweight option must be one of {0, 1} ! ! !"
	break
}
else {
	if `aweight' == 1 local _aweight "_aweight"
	else local _aweight ""
}


* Directories
global proj_dir "/gpfs/data/desailab/home"

* Date
local today: di %tdCCYYNNDD date(c(current_date), "DMY")

* Filepaths
local log_file "logs/hcup_outcomes_`xvarOpt'`_aweight'_`today'.smcl"
local log_file_pdf "reports/hcup_outcomes_`xvarOpt'`_aweight'.pdf"

* Labels and misc.
local pay_labels `""Medicare" "Medicaid" "PrivIns" "SelfPay" "NoCharge" "Other" "Missing""'

local mdc_cds 1 4 5 6 8 15 19 20 25
local mdc_labels `""Nervous System" "Respiratory System" "Ciculatory System" "Digestive System" "Musculoskeletal System" "Newborn" "Mental Health" "Alcohol/Drug Abuse" "HIV""'

* Model settings
if "`xvarOpt'" == "post_anytarget" {
	local xvar i.post_anytarget
}
else if "`xvarOpt'" == "hhi_hosp" {
	local xvar hhi_hosp
}
else if "`xvarOpt'" == "hhi_avg_hhisys_cnty_T" {
	local xvar "i.hhi_avg_hhisys_cnty_T"
}
local xvars "`xvar' i.year total_enroll_log"
local panelvar ahaid
local panelvar_id "`panelvar'_id"
local cluster_var cnty


********************************************
* Log start
log using "`log_file'", replace

quietly {
********************************************
* RUN PROGRAM
********************************************

* Prep covariates data
if "`xvarOpt'" == "post_anytarget" {
	* Treatent/Control data
	********************************************
	use "$proj_dir/ny_mergers/data_hospclean/ny_treatcontrol_Feb 12.dta", clear

		keep year cnty post_*
		tostring cnty, replace
}
else if "`xvarOpt'" == "hhi_hosp" {
	* Hospital-level HHI
	********************************************
	use "$proj_dir/ny_mergers/data_analytic/hhi_hospital.dta", clear
}
else if "`xvarOpt'" == "avg_hhisys_cnty_T" {
	* Average county system-HHI terciles
	********************************************
	use "$proj_dir/ny_mergers/data_analytic/hhisys_terciles.dta", clear
}

tempfile cov
save `cov', replace

	* Bring in county Medicaid enrollment
	use "$proj_dir/ny_mergers/data_hospclean/mmc_totals.dta", clear

	collapse (sum) total_enroll, by(county year)

	gen total_enroll_log = log(total_enroll)

	keep if year>=2006 & year<=2012

	tempfile mmc
	save `mmc', replace

	* NY County FIPS Codes
	import excel using "$proj_dir/ny_mergers/inputs/ny_fips.xlsx", clear firstrow

	gen cnty = "3636" + string(cnty_fips, "%03.0f")

	replace county = subinstr(county, " County", "", .)
	replace county = "St Lawrence" if county=="St. Lawrence"
	replace county = "NYC" if inlist(county, "Bronx", "Kings", "New York", "Queens", "Richmond")

	joinby county using `mmc'
	* data check: assert we have 62 counties * 7 years
	qui count
	assert `r(N)' == 62 * 7

	save `mmc', replace

	* Map to AHAID from AHA-Cooper
	use "$proj_dir/ny_mergers/data_hospclean/ahacooperall_cleaned.dta", clear

	rename id ahaid

	keep ahaid year cnty

	merge m:1 cnty year using `mmc', keep(3) nogen

	save `mmc', replace


* HCUP NY SID Outcomes
********************************************
use "$proj_dir/ny_mergers/data_analytic/hcup_ny_sid_outcomes.dta", clear

	* Lookfor yvars
	* Discharges
		ds discharges*_lg
    	local y_ds_logs `r(varlist)'
    	ds discharges*_pr
    	local y_ds_props `r(varlist)'
    * MDCs
    	local y_mdc_logs
    	local y_mdc_props
    	foreach cd of local mdc_cds {
    		ds mdc_`cd'_*_lg
    		local y_mdc_logs `y_mdc_logs' `r(varlist)'
    		ds mdc_`cd'_*_pr
    		local y_mdc_props `y_mdc_props' `r(varlist)'
    	}
    * Utilization flags
		ds u_*_lg
		local y_util_logs `r(varlist)'
		ds u_*_pr
		local y_util_props `r(varlist)'

	* Labels for model output
	label var year

	********************************************
	* Merge on covariates

	* County Medicaid enrollment
	merge 1:1 ahaid year using `mmc', keep(3) nogen

	if "`xvarOpt'" == "post_anytarget" {
		merge m:1 cnty year using `cov', assert(3) nogen
	}
	else if "`xvarOpt'" == "hhi_hosp" {
		merge 1:1 ahaid year using `cov', keep(3) nogen
	}
	else if "`xvarOpt'" == "hhi_avg_hhisys_cnty_T" {
		merge 1:1 ahaid year using `cov', assert(3) nogen
	}

	********************************************
	* Drop hospital-years below discharge minimum threshold
	n di ". . . dropping all hosp-years with less than `hosp_year_ds_min' discharges . . ."
	drop if discharges < `hosp_year_ds_min'

	********************************************
	* Analytical weights
	if `aweight' == 1 {
		bysort ahaid: egen discharges_year = mean(discharges)
			label var discharges_year "Avg. discharges per year"
		gen discharges_year_log = log(discharges_year)

		local aweight_opt [aweight=discharges_year_log]
	}
	else local aweight_opt ""


********************************************
* RUN MODELS
********************************************
n di "* * *" _n "* * * Model specifications * * *"
n di "xtset `panelvar' year"
n di "xtreg outcome `xvars' `aweight_opt', fe vce(cluster `cluster_var')"
n di "* * *"

encode `panelvar', gen(`panelvar_id')
xtset `panelvar_id' year, yearly

	********************************************
	* Discharge models
	noisily di in red "* * * DISCHARGES * * *"
		********************************************
		* Discharge log counts
		local models
		local i 1
		foreach yvar of local y_ds_logs {
			local model "m_`yvar'"
			local title: word `i' of `pay_labels'
			local ++i

			* Only run for certain payers
			if !inlist(`i'-1, 2,3) continue

			xtreg `yvar' `xvars' `aweight_opt', fe vce(cluster `cluster_var')
			estimates store `model', title(`title')
			local models `models' `model'
		}
		noisily estout `models' using "reports/hcup_analysis.tex", title(Discharges (log counts)) cells(b(star fmt(2)) se(par fmt(2))) keep(`xvar') legend label varlabels(_cons Constant) replace style(tex)

		********************************************
		* Discharge proportions
		local models
		local i 1
		foreach yvar of local y_ds_props {
			local model "m_`yvar'"
			local payer: word `i' of `pay_labels'
			local ++i

			* Only run for certain payers
			if !inlist(`i'-1, 2,3) continue

			xtreg `yvar' `xvars' `aweight_opt', fe vce(cluster `cluster_var')
			estimates store `model', title(`payer')
			local models `models' `model'
		}
		* Output model estimates
		noisily estout `models' using "reports/hcup_analysis.tex", title(Discharges (proportions)) cells(b(star fmt(2)) se(par fmt(2))) keep(`xvar') legend label varlabels(_cons Constant) append style(tex)


	********************************************
	* MDC models
	********************************************
	noisily di in red "* * * DISCHARGES BY MAJOR DIAGNOSTIC CATEGORY * * *"
		********************************************
		* MDC log counts
		local i 1
		foreach yvar of local y_mdc_logs {
			local model "m_`yvar'"
			local payer: word `i' of `pay_labels'
			if `i'==5 local i 1
			else local ++i

			* Only run for certain payers
			if !inlist(`i'-1, 2,3) continue

			xtreg `yvar' `xvars' `aweight_opt', fe vce(cluster `cluster_var')
			estimates store `model', title(`payer')
		}
		* Output model estimates
		noisily di in red ". . . Log Discharges of Major Diagnositc Categories . . ."
		foreach cd of local mdc_cds {
			local models
			* Only run for certain payers
			forvalues p=2/3 {
				local models `models' m_mdc_`cd'_`p'_lg
				local title: word `p' of `mdc_labels'
			}

			noisily estout `models' using "reports/hcup_analysis.tex", title(MDC: `title' (log counts)) cells(b(star fmt(2)) se(par fmt(2))) keep(`xvar') legend label varlabels(_cons Constant) append style(tex)
		}

		********************************************
		* MDC proportions
		local i 1
		foreach yvar of local y_mdc_props {
			local model "m_`yvar'"
			local payer: word `i' of `pay_labels'
			if `i'==5 local i 1
			else local ++i

			* Only run for certain payers
			if !inlist(`i'-1, 2,3) continue

			xtreg `yvar' `xvars' `aweight_opt', fe vce(cluster `cluster_var')
			estimates store `model', title(`payer')
		}
		* Output model estimates
		noisily di in red ". . . Proportions of Discharges of Major Diagnostic Categories . . ."
		foreach cd of local mdc_cds {
			local models
			* Only run for certain payers
			forvalues p=2/3 {
				local models `models' m_mdc_`cd'_`p'_pr
				local title: word `p' of `mdc_labels'
			}

			noisily estout `models' using "reports/hcup_analysis.tex", title(MDC: `title' (proportions)) cells(b(star fmt(3)) se(par fmt(3))) keep(`xvar') legend label varlabels(_cons Constant) append style(tex)
		}

********************************************
} // end quietly block


********************************************
* Log close
log close
translate "`log_file'" "`log_file_pdf'"
