********************************************
* Fixed effects regression of service utilization (HCUP NY SID SUPP) on county average system HHI
********************************************

clear
set more off


********************************************
* Macros

* Directories
global proj_dir "/gpfs/data/desailab/home"
local scratch_dir "/gpfs/scratch/azc211/ny_mergers"

* Date
local today: di %tdCCYYNNDD date(c(current_date), "DMY")

* Filepaths
local log_file "`scratch_dir'/logs/fe_util_hhi_`today'.smcl"
local log_file_pdf "reports/fe_util_hhi.pdf"

* Labels and misc.
local pay_labels `""Medicare" "Medicaid" "PrivIns" "SelfPay" "NoCharge" "Other" "Missing""'

local util_medicaid "u_ed u_mhsa u_newbn"
local util_medicaid_labels `""Emergency Department" "Mental Health/Substance Abuse" "Newborn""'

local util_privins "u_cath u_nucmed u_observation u_organacq u_othimplants u_radtherapy"
local util_privins_labels `""Cardiac Cath. Lab" "Nuclear Medicine" "Observation" "Organ Acquisition" "Other implants" "Radiology/Chemotherapy""'

* Model settings
local xvars "i.post_anytarget i.year"
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


* Treatent/Control data
********************************************
use "$proj_dir/ny_mergers/data_hospclean/ny_treatcontrol_Feb 12.dta", clear

	keep year cnty post_*
	tostring cnty, replace

	tempfile treatcontrol
	save `treatcontrol', replace


* Market-level exposure data
********************************************
use "$proj_dir/ny_mergers/data_analytic/market_exposure.dta", clear

	* keep only NY state observations
	keep if fstcd==36

	keep cnty year exposure_*
	duplicates drop

	merge 1:1 cnty year using `treatcontrol', assert(3) nogen

	tempfile cov
	save `cov', replace

* HCUP NY SID SUPP
********************************************
use "$proj_dir/ny_mergers/data_hospclean/hhi_ny_sid_supp_hosp.dta", clear

	label var year ""
	label var avg_hhisys_cnty "HHI (sys, cnty avg)"

	* Cnty fix for Lewis County General Hospital
	replace cnty="3636049" if ahaid=="6212320" & cnty=="3636043"

	********************************************
	* Merge on covariates
		merge m:1 cnty year using `cov', assert(3) nogen

	********************************************
	* Prep outcome variables

		* Discharges
			* Counts
			local y_ds_cnts "discharges1 discharges2 discharges3 discharges4 discharges5"

			* Proportions
			foreach var of local y_ds_cnts {
				gen `var'_pr = `var' / discharges

				* Generate log outcomes for counts
				gen `var'_lg = log(`var' + 1)
			}
			qui ds discharges*_lg
			local y_ds_logs `r(varlist)'
			qui ds discharges*_pr
			local y_ds_props `r(varlist)'

		* Service utilizations
			* Totals
			local y_util_totals "u_ed u_mhsa u_newbn u_cath u_nucmed u_observation u_organacq u_othimplants u_radtherapy"
			
			local y_util_cnts
			foreach var of local y_util_totals {
				forvalues i=1/5 {
					* Counts
					local y_util_cnts "`y_util_cnts' `var'`i'"
					
					* Proportions
					gen `var'`i'_pr = `var'`i' / `var'

					* Generate log outcomes for counts
					gen `var'`i'_lg = log(`var'`i' + 1)
				}
			}
			qui ds u_*_lg
			local y_util_logs `r(varlist)'
			qui ds u_*_pr
			local y_util_props `r(varlist)'

	********************************************
	* Bin average county system HHI into terciles
		_pctile avg_hhisys_cnty if year == 2006, nquantiles(3)
		local q1 = `r(r1)'
		local q2 = `r(r2)'

		assert avg_hhisys_cnty != .
		gen avg_hhisys_cnty_T = 1 if avg_hhisys_cnty <= `q1'
		replace avg_hhisys_cnty_T = 2 if avg_hhisys_cnty > `q1' & avg_hhisys_cnty <= `q2'
		replace avg_hhisys_cnty_T = 3 if avg_hhisys_cnty > `q2'
		assert avg_hhisys_cnty_T != .
		label var avg_hhisys_cnty_T "Cnty avg. HHI sys tercile"

		noisily di ""
		noisily di in red "* * * avg_hhisys_cnty terciles for 2006 * * "
		noisily di ""
		noisily di in red "... Tercile 1: " %6.3f `q1'
		noisily di in red "... Tercile 2: " %6.3f `q2'
		noisily di ""

	* Save data in dump for scp to local
	* save "dump/hhi_ny_sid_supp_hosp.dta", replace


	********************************************
	* Run models
	********************************************
	n di ""
	n di "* * * Model specifications * * *"
	n di "xvars: `xvars'"
	n di "panel var: `panelvar'"
	n di "cluster var: `cluster_var'"
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

				qui xtreg `yvar' `xvars', fe vce(cluster `panelvar_id')
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

				qui xtreg `yvar' `xvars', fe vce(cluster `panelvar_id')
				estimates store `model', title(`title')
			}
			* Output model estimates
				* Medicaid services
				noisily di in red ". . . Medicaid services . . ."
				local i 1
				foreach util of local util_medicaid {
					local models
					forvalues p=1/5 {
						local models `models' m_`util'`p'_lg
					}
					local title: word `i' of `util_medicaid_labels'
					local ++i

					noisily estout `models', title(Medicaid Service Util: `title' (log counts)) cells(b(star fmt(2)) se(par fmt(2))) legend label varlabels(_cons Constant)
				}
				* Private insurance services
				noisily di in red ". . . Private insurance services . . ."
				local i 1
				foreach util of local util_privins {
					local models
					forvalues p=1/5 {
						local models `models' m_`util'`p'_lg
					}
					local title: word `i' of `util_privins_labels'
					local ++i

					noisily estout `models', title(Private Insurance Service Util: `title' (log counts)) cell(b(star fmt(2)) se(par fmt(2)))  legend label varlabels(_cons Constant)
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

				qui xtreg `yvar' `xvars', fe vce(cluster `panelvar_id')
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

					noisily estout `models', title(Medicaid Service Util: `title' (proportions)) cells(b(star fmt(2)) se(par fmt(2))) legend label varlabels(_cons Constant)
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

					noisily estout `models', title(Private Insurance Service Util: `title' (proportions)) cell(b(star fmt(2)) se(par fmt(2)))  legend label varlabels(_cons Constant)
				}
********************************************
* end quietly block
}


********************************************
* Log close
log close
translate "`log_file'" "`log_file_pdf'"
