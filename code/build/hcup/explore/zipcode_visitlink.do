********************************************
* Exploring missing zipcode and visitlink discharges in HCUP NY SID SUPP
********************************************

clear
set more off

********************************************
* MACROS

local proj_dir "/gpfs/data/desailab/home"

********************************************
* DATA

use "`proj_dir'/ny_mergers/data_hospclean/hhi_ny_sid_supp.dta", clear

* create indicators
    gen zip_len = strlen(zip)

    gen zip_0 = 1 if zip_len==0
    gen zip_3 = 1 if zip_len==3

    gen visitlink_0 = 1 if visitlink==.

    gen ds = 1


    * Collapse to hospital level
    encode ahaid, gen(ahaid_cd)
    fcollapse (sum) ds zip_0 zip_3 visitlink_0, by(ahaid_cd)
