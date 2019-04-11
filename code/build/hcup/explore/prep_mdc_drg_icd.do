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

use pay1 mdc dx1 using "$proj_dir/data_sidclean/sid_work/ny_sid_0612_supp.dta", clear

    gen ds = 1

    tostring pay1, replace
    tostring mdc, replace

    fcollapse (sum) ds, by(pay1 mdc dx1)

save "dump/icds.dta", replace
