********************************************
* Construct outcomes for analyses
********************************************

clear
set more off

********************************************
* MACROS
********************************************

* Directories
global proj_dir "/gpfs/data/desailab/home"
local scratch_dir "/gpfs/scratch/azc211/ny_mergers"

* Date
local today: di %tdCCYYNNDD date(c(current_date), "DMY")

* Labels and misc.
local pay_labels `""Medicare" "Medicaid" "PrivIns" "SelfPay" "NoCharge" "Other" "Missing""'

local util_medicaid "u_ed u_mhsa u_newbn"
local util_medicaid_labels `""Emergency Department" "Mental Health/Substance Abuse" "Newborn""'

local util_privins "u_cath u_nucmed u_observation u_organacq u_othimplants u_radtherapy"
local util_privins_labels `""Cardiac Cath. Lab" "Nuclear Medicine" "Observation" "Organ Acquisition" "Other implants" "Radiology/Chemotherapy""'

********************************************
* RUN PROGRAM
********************************************

* Data
use "$proj_dir/ny_mergers/data_hospclean/hhi_ny_sid_supp_hosp.dta", clear

    * Cnty fix for Lewis County General Hospital
    replace cnty="3636049" if ahaid=="6212320" & cnty=="3636043"

    ********************************************
    * Prep outcome variables
    ********************************************
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

********************************************
* SAVE
save "$proj_dir/ny_mergers/data_analytic/hcup_ny_sid_outcomes.dta", replace
        

