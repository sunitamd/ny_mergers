********************************************
* Create regression weights: hospital-level private insurance patients per MDC
********************************************

clear
set more off


* Check for ftools package
cap which ftools
if _rc==111 ssc install ftools

********************************************
* MACROS
********************************************

* Directories
global proj_dir "/gpfs/data/desailab/home"


********************************************
* RUN PROGRAM
********************************************

* HCUP NY SID SUPP data
********************************************
use pay1 visitlink mdc ahaid year using "$proj_dir/ny_mergers/data_sidclean/sid_work/ny_sid_0612_supp.dta", clear

    * keep private insurance
    keep if pay1==3

    * Drop if no patient ID
    drop if visitlink==.

    * collapse from admissions-level to patient-level
    keep visitlink mdc ahaid year
    duplicates drop

    gen patient = 1
        label var patient "Unique patient count"

    tostring year, replace
    tostring mdc, replace

    fcollapse (sum) patients=patient, by(ahaid year mdc) fast

    destring year, replace
    destring mdc, replace

    drop if ahaid==""

    * reshape wide
    rename patients patients_mdc

    reshape wide patients_mdc, i(ahaid year) j(mdc)

    * Generate log weights
    ds patients_mdc*
    local mdc_wts `r(varlist)'
    foreach wt of local mdc_wts {
        gen `wt'_log = log(`wt')
    }

    * Save
    save "$proj_dir/ny_mergers/data_analytic/hospital_weights.dta", replace
    !chmod g+rw "$proj_dir/ny_mergers/data_analytic/hospital_weights.dta"
