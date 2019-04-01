********************************************
* Collapse HCUP NY SID SUPP to MDC-Zipcode-Payer-Hospital-Year level
* with sums for unique patients and discharges
********************************************

clear
set more off

cap which ftools
if _rc==111 ssc install ftools

********************************************
* MACROS
********************************************

global proj_dir "/gpfs/data/desailab/home"


********************************************
* RUN PROGRAM
********************************************

use "$proj_dir/ny_mergers/data_sidclean/sid_work/ny_sid_0612_supp.dta", clear

    * Prep missing variables for collapse
    replace pay1 = 7 if pay1 == .
    replace visitlink = 9 if visitlink==.
    replace zip = "missing" if zip==""

    * Gen unique patient & discharge measure
    bysort visitlink: gen patient = 1 if _n==1
    gen discharge = 1

    * Prep string by vars for fcollapse
    local string_by_vars zip ahaid
    foreach var of local string_by_vars {
        encode `var', gen(`var'_cd)
    }

    * Collapse data
    fcollapse (sum) discharges=discharge, by(ahaid_cd year mdc zip_cd pay1 visitlink) fast

    foreach var of local string_by_vars {
        decode `var'_cd, gen(`var')
        drop `var'_cd
    }

********************************************
* SAVE
********************************************

save "$proj_dir/ny_mergers/data_analytic/hcup_ny_sid_supp_collapsed.dta", replace
!chmod g+rw "$proj_dir/ny_mergers/data_analytic/hcup_ny_sid_supp_collapsed.dta"
