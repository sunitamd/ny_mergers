********************************************
* Collapse HCUP NY SID SUPP admissions data to hospital-year-payer level
* Sum utilization flag counts
********************************************

clear
set more off

cap which ftools
if _rc==111 ssc install ftools

********************************************
* MACROS
********************************************

* Directories
global proj_dir "/gpfs/data/desailab/home/ny_mergers"

********************************************
* RUN PROGRAM
********************************************

use "$proj_dir/data_sidclean/sid_work/ny_sid_0612_supp.dta", clear

    * Patient-level variables
        gen discharges = 1
        replace pay1 = 7 if pay1==.
        
        * Collapse newborn utilizations
        egen u_newbn = rowtotal(u_newbn*), misisng
        order u_bewbn, before(u_newbn2l)
        drop u_newbn2l u_newb3l u_newbn4l

        qui lookfor u_
        local util_vars `r(varlist)'
        * Dichotamize utilization variables for summation
        * Original utilization flags are coded as reported from revenue code, procedure code, CCS
        foreach var of varlist `util_vars' {
            replace `var' = 1 if `var'>0 & `var'!=.
        }

    * Hospital-level variables
        replace ahaid = "Missing" if ahaid==""
        encode ahaid, gen(ahaid_cd)

    * Collapse data
        fcollapse (sum) discharges `util_vars', by(ahaid_cd year pay1) fast

********************************************
* SAVE
********************************************

save "$proj_dir/data_analytic/hcup_ny_sid_utils.dta", replace
!chmod g+rw "$proj_dir/data_analytic/hcup_ny_sid_utils.dta"

