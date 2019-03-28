********************************************
* Run fixed effects regression of HCUP NY SID SUPP outcomes on specified independent variables
* NOTE: xvars must be specified through command line argument!
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
	if `aweight' == 1 local aweight_text "_aweight"
	else local aweight_text ""
}


* Directories
global proj_dir "/gpfs/data/desailab/home"
local scratch_dir "/gpfs/scratch/azc211/ny_mergers"

* Date
local today: di %tdCCYYNNDD date(c(current_date), "DMY")

* Filepaths
local log_file "`scratch_dir'/logs/hcup_outcomes_`xvarOpt'`aweight_text'_`today'.smcl"
local log_file_pdf "reports/hcup_outcomes_`xvarOpt'`aweight_text'.pdf"

* Labels and misc.
local pay_labels `""Medicare" "Medicaid" "PrivIns" "SelfPay" "NoCharge" "Other" "Missing""'

local util_medicaid "u_ed u_mhsa u_newbn"
local util_medicaid_labels `""Emergency Department" "Mental Health/Substance Abuse" "Newborn""'

local util_privins "u_cath u_nucmed u_observation u_organacq u_othimplants u_radtherapy"
local util_privins_labels `""Cardiac Cath. Lab" "Nuclear Medicine" "Observation" "Organ Acquisition" "Other implants" "Radiology/Chemotherapy""'

* Model settings
if "`xvarOpt'" == "post_anytarget" {
	local xvars i.post_anytarget
}
else if "`xvarOpt'" == "hhi_hosp" {
	local xvars hhi_hosp
}
else if "`xvarOpt'" == "hhi_avg_hhisys_cnty_T" {
	local xvars "i.hhi_avg_hhisys_cnty_T"
}
local xvars "`xvars' i.year"
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


* HCUP NY SID Outcomes
********************************************
use "$proj_dir/ny_mergers/data_analytic/hcup_ny_sid_outcomes.dta", clear

	* Lookfor yvars
	qui ds discharges*_lg
    local y_ds_logs `r(varlist)'
    qui ds discharges*_pr
    local y_ds_props `r(varlist)'
	qui ds u_*_lg
	local y_util_logs `r(varlist)'
	qui ds u_*_pr
	local y_util_props `r(varlist)'

	* Labels for model output
	label var year

	********************************************
	* Merge on covariates

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
	if "`a_weights'" == 1 {
		bysort ahaid: egen discharges_year = mean(discharges)
			label var discharges_year "Avg. discharges per year"
	}


********************************************
* RUN MODELS
********************************************
n di ""
n di "* * * Model specifications * * *"
n di "xtset `panelvar' year"
n di "xtreg outcome `xvars', fe vce(cluster `cluster_var')"
n di ""

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
			local models `models' `model'
			local title: word `i' of `pay_labels'
			local ++i

			qui xtreg `yvar' `xvars', fe vce(cluster `cluster_var')
			estimates store `model', title(`title')
		}
		noisily estout `models', title(Discharges (log counts)) cells(b(star fmt(2)) se(par fmt(2))) legend label varlabels(_cons Constant)

		********************************************
		* Discharge proportions
		local models
		local i 1
		foreach yvar of local y_ds_props {
			local model "m_`yvar'"
			local models `models' `model'
			local title: word `i' of `pay_labels'
			local ++i

			qui xtreg `yvar' `xvars', fe vce(cluster `cluster_var')
				estimates store `model', title(`title')
		}
		* Output model estimates
		noisily estout `models', title(Discharges (proportions)) cells(b(star fmt(2)) se(par fmt(2))) legend label varlabels(_cons Constant)


	********************************************
	* Service utilization models
	********************************************
	noisily di in red "* * * SERVICE UTILIZATIONS * * *"
		********************************************
		* Utilization log counts
		local i 1
		foreach yvar of local y_util_logs {
			local model "m_`yvar'"
			local title: word `i' of `pay_labels'
			if `i'==5 {
				local i 1
			}
			else {
				local ++i
			}

			qui xtreg `yvar' `xvars', fe vce(cluster `cluster_var')
			estimates store `model', title(`title')
		}
		* Output model estimates
			* Medicaid associated services
			noisily di in red ". . . Medicaid associated services . . ."
			local i 1
			foreach util of local util_medicaid {
				local models
				forvalues p=1/5 {
					local models `models' m_`util'`p'_lg
				}
				local title: word `i' of `util_medicaid_labels'
				local ++i

				noisily estout `models', title(Service Util: `title' (log counts)) cells(b(star fmt(2)) se(par fmt(2))) legend label varlabels(_cons Constant)
			}
			* Private insurance associated services
			noisily di in red ". . . Private insurance associated services . . ."
			local i 1
			foreach util of local util_privins {
				local models
				forvalues p=1/5 {
					local models `models' m_`util'`p'_lg
				}
				local title: word `i' of `util_privins_labels'
				local ++i

				noisily estout `models', title(Service Util: `title' (log counts)) cell(b(star fmt(2)) se(par fmt(2)))  legend label varlabels(_cons Constant)
			}

		********************************************
		* Utiliztion proportions
		local i 1
		foreach yvar of local y_util_props {
			local model "m_`yvar'"
			local title: word `i' of `pay_labels'
			if `i'==5 {
				local i 1
			}
			else {
				local ++i
			}

			qui xtreg `yvar' `xvars', fe vce(cluster `cluster_var')
			estimates store `model', title(`title')
		}
		* Output model estimates
			* Medicaid services
			noisily di in red ". . . Medicaid services . . ."
			local i 1
			foreach util of local util_medicaid {
				local models
				forvalues p=1/5 {
					local models `models' m_`util'`p'_pr
				}
				local title: word `i' of `util_medicaid_labels'
				local ++i

				noisily estout `models', title(Service Util: `title' (proportions)) cells(b(star fmt(2)) se(par fmt(2))) legend label varlabels(_cons Constant)
			}
			* Private insurance services
			noisily di in red ". . . Private insurance services . . ."
			local i 1
			foreach util of local util_privins {
				local models
				forvalues p=1/5 {
					local models `models' m_`util'`p'_pr
				}
				local title: word `i' of `util_privins_labels'
				local ++i

				noisily estout `models', title(Service Util: `title' (proportions)) cell(b(star fmt(2)) se(par fmt(2)))  legend label varlabels(_cons Constant)
			}

********************************************
} // end quietly block


********************************************
* Log close
log close
translate "`log_file'" "`log_file_pdf'"
