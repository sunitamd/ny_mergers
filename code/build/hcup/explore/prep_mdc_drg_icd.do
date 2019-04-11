********************************************
* Prep HCUP for icd exploration
********************************************

clear

********************************************
* MACROS

global proj_dir "/gpfs/data/desailab/home/ny_mergers"

********************************************
* RUN PROGRAM
********************************************

* Collapse admissions for ICDs (DX1)
use pay1 mdc dx1 using "$proj_dir/data_sidclean/sid_work/ny_sid_0612_supp.dta", clear

    gen ds = 1

    tostring pay1, replace
    tostring mdc, replace

    fcollapse (sum) ds, by(pay1 mdc dx1)

save "dump/icds.dta", replace

* Collapse admissions for DRGS
use pay1 mdc drg using "$proj_dir/data_sidclean/sid_work/ny_sid_0612_supp.dta", clear
    
    gen ds = 1

    tostring pay1, replace
    tostring mdc, replace
    tostring drg, replace
    
    fcollapse (sum) ds, by(pay1 mdc drg)

save "dump/drgs.dta", replace

* Collapse admissions by MDCs

    fcollapse (sum) ds, by(pay1 mdc)

save "dump/mdcs.dta", replace
