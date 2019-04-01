********************************************
* Construct outcomes for HCUP analyses
* Output is at hospital level
********************************************

clear
set more off

cap which ftools
if _rc==111 ssc install ftools

********************************************
* MACROS
********************************************

* Directories
global proj_dir "/gpfs/data/desailab/home"

* Misc.
local outcome_vars

********************************************
* RUN PROGRAM
********************************************

* Data
use "$proj_dir/ny_mergers/data_analytic/hcup_ny_sid_supp_collapsed.dta", clear

    ********************************************
    * Collapse to hospital-level
    encode ahaid, gen(ahaid_cd)
    fcollapse (sum) discharges, by(year pay1 ahaid_cd) fast
    decode ahaid_cd, gen(ahaid)
    drop ahaid_cd

    * Merge on utilization variables
    drop if ahaid==""
    merge 1:1 ahaid year pay1 using "$proj_dir/ny_mergers/data_analytic/hcup_ny_sid_utils.dta", assert(2 3)
    assert ahaid=="Missing" if _merge==2
    drop if ahaid=="Missing"
    drop _merge

    qui lookfor u_
    local util_vars `r(varlist)'

    reshape wide discharges `util_vars', i(ahaid year) j(pay1)

    order discharges* u_*, alpha last

    ********************************************
    * Prep outcome variables
    ********************************************
    
    * Discharges
    ********************************************
        * Counts
        local y_ds_cnts "discharges1 discharges2 discharges3 discharges4 discharges5"

        egen discharges = total(discharges1-discharges6)

        * Proportions
        foreach var of local y_ds_cnts {
            gen `var'_pr = `var' / discharges

            * Generate log outcomes for counts
            gen `var'_lg = log(`var' + 1)

            local outcome_vars `outcome_vars' `var'_pr `var'_lg
        }


    * Service utilizations
    ********************************************
        * Totals
        local y_util_totals "u_ed u_mhsa u_newbn u_cath u_nucmed u_observation u_organacq u_othimplants u_radtherapy"
            
        local y_util_cnts
        foreach var of local y_util_totals {

            egen `var' = total(`var'1-`var'6)

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
!chmod g+rw "$proj_dir/ny_mergers/data_analytic/hcup_ny_sid_outcomes.dta"

