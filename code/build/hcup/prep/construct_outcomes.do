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

* Misc.
local outcome_vars

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

            local outcome_vars `outcome_vars' `var'_pr `var'_lg
        }


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

                local outcome_vars `outcome_vars' `var'`i'_pr `var'`i'_lg
            }
        }

********************************************
* SAVE
********************************************
    
    keep ahaid cnty year discharges `y_ds_cnts' `y_util_totals' `outcome_vars'

save "$proj_dir/ny_mergers/data_analytic/hcup_ny_sid_outcomes.dta", replace
        

