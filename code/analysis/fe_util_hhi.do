********************************************
* Fixed effects regression of service utilization (HCUP NY SID SUPP) on county average system HHI
********************************************

clear
set more off


********************************************
* Macros

* Directories
local proj_dir "/gpfs/data/desailab/home/ny_mergers"
local scratch_dir "/gpfs/scratch/azc211/ny_mergers"

* Date
local today: di %tdCCYYNNDD date(c(current_date), "DMY")

* Filepaths
local log_file "`scratch_dir'/logs/fe_util_hhi_`today'.smcl"
local log_file_pdf "`scratch_dir'/logs/fe_util_hhi_`today'.pdf"

* Labels and misc.
local pay_labels `""Medicare" "Medicaid" "PrivIns" "SelfPay" "NoCharge" "Other" "Missing""'

local util_medicaid "u_ed u_mhsa u_newbn"
local util_medicaid_labels `""Emergency Department" "Mental Health/Substance Abuse" "Newborn""'

local util_privins "u_cath u_nucmed u_observation u_organacq u_othimplants u_radtherapy"
local util_privins_labels `""Cardiac Cath. Lab" "Nuclear Medicine" "Observation" "Organ Acquisition" "Other implants" "Radiology/Chemotherapy""'


********************************************
* Log start
log using "`log_file'", replace

quietly {
* Data
use "`proj_dir'/data_hospclean/hhi_ny_sid_supp_hosp.dta", clear

	label var year ""
	label var avg_hhisys_cnty "HHI (sys) (county-avg.)"

	********************************************
	* Prep outcome variables

		* Discharges
			* Counts
			local y_ds_cnts "discharges1 discharges2 discharges3 discharges4 discharges5"

			* Proportions
			foreach var of local y_ds_cnts {
				gen `var'_pr = `var' / discharges
			}
			qui ds discharges*_pr
			local y_ds_props `r(varlist)'

		* Service utilizations
			* Totals
			local y_util_totals "u_ed u_mhsa u_newbn u_cath u_nucmed u_observation u_organacq u_othimplants u_radtherapy"
			
			local y_util_cnts
			foreach var of local y_util_totals {
				forvalues i=1/4 {
					* Counts
					local y_util_cnts "`y_util_cnts' `var'`i'"
					* Proportions
					gen `var'`i'_pr = `var'`i' / `var'
				}
			}
			qui ds u_*_pr
			local y_util_props `r(varlist)'

	********************************************
	* Run models
		local xvars "avg_hhisys_cnty i.year"
		encode ahaid, gen(ahaid_id)
		xtset ahaid_id year, yearly

		********************************************
		* Discharge models
		noisily di in red "* * * DISCHARGES * * *"
			* Discharge counts
			local models
			local i 1
			foreach yvar of local y_ds_cnts {
				local model "m_`yvar'"
				local models `models' `model'
				local title: word `i' of `pay_labels'
				local ++i

				qui xtreg `yvar' `xvars', fe
				estimates store `model', title(`title')
			}
			noisily estout `models', title(Discharges (counts)) cells(b(star fmt(1)) se(par fmt(1))) legend label varlabels(_cons Constant)


			* Discharge proportions
			local models
			local i 1
			foreach yvar of local y_ds_props {
				local model "m_`yvar'"
				local models `models' `model'
				local title: word `i' of `pay_labels'
				local ++i

				qui xtreg `yvar' `xvars', fe
				estimates store `model', title(`title')
			}
			* Output model estimates
			noisily estout `models', title(Discharges (proportions)) cells(b(star fmt(2)) se(par fmt(2))) legend label varlabels(_cons Constant)

		********************************************
		* Service utilization models
		noisily di in red "* * * SERVICE UTILIZATIONS * * *"
			* Utilization counts
			local i 1
			foreach yvar of local y_util_cnts {
				local model "m_`yvar'"
				local title: word `i' of `pay_labels'
				if `i'==4 {
					local i 1
				}
				else {
					local ++i
				}

				qui xtreg `yvar' `xvars', fe
				estimates store `model', title(`title')
			}
			* Output model estimates
				* Medicaid services
				noisily di in red ". . . Medicaid services . . ."
				local i 1
				foreach util of local util_medicaid {
					local models
					forvalues p=1/4 {
						local models `models' m_`util'`p'
					}
					local title: word `i' of `util_medicaid_labels'
					local ++i

					noisily estout `models', title(Medicaid Service Util: `title' (counts)) cells(b(star fmt(1)) se(par fmt(1))) legend label varlabels(_cons Constant)
				}
				* Private insurance services
				noisily di in red ". . . Private insurance services . . ."
				local i 1
				foreach util of local util_privins {
					local models
					forvalues p=1/4 {
						local models `models' m_`util'`p'
					}
					local title: word `i' of `util_privins_labels'
					local ++i

					noisily estout `models', title(Private Insurance Service Util: `title' (counts)) cells(b(star fmt(1)) se(par fmt(1))) legend label varlabels(_cons Constant)

				}

			* Utiliztion proportions
			local i 1
			foreach yvar of local y_util_props {
				local model "m_`yvar'"
				local title: word `i' of `pay_labels'
				if `i'==4 {
					local i 1
				}
				else {
					local ++i
				}

				qui xtreg `yvar' `xvars', fe
				estimates store `model', title(`title')
			}
			* Output model estimates
				* Medicaid services
				noisily di in red ". . . Medicaid services . . ."
				local i 1
				foreach util of local util_medicaid {
					local models
					forvalues p=1/4 {
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
					forvalues p=1/4 {
						local models `models' m_`util'`p'_pr
					}
					local title: word `i' of `util_privins_labels'
					local ++i

					noisily estout `models', title(Private Insurance Service Util: `title' (proportions)) cell(b(star fmt(2)) se(par fmt(2)))  legend label varlabels(_cons Constant)
				}
* end quietly block
}


********************************************
* Log close
log close
translate "`log_file'" "`log_file_pdf'"
