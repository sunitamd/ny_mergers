********************************************
* Create merged AHA and Cooper hospital mergers dataset
********************************************


********************************************
clear
set more off


********************************************
* Macros
********************************************
local projdir "/gpfs/data/desailab/home/ny_mergers"


********************************************
* Read in datasets
********************************************
* AHA data
use "`projdir'/data_hospclean/aha_combined_final_v2.dta", clear

tostring sysid, replace
label var sysid "AHA sysid"

rename aha_year year

* (id, year) does not uniquely identify hosp-year obs. Duplicates only differ in add_reason (either registered or non-registered addition).
* Arbritrarily keep duplicates where add reason is due to status change to registered
duplicates tag id year, gen(dup)
drop if dup>0 & add_reason!="Status Changed To Registered"

* Merger indicator
gen merger_aha = 1 if inlist(merge, 1,2,3)
replace merger_aha = 0 if merger_aha==.
label var merger_aha "AHA merger indicator"

tempfile aha
save `aha', replace


* Cooper data
use "`projdir'/data_hospclean/HC_ext_mergerdata_public.dta", clear

tempfile cooper
save `cooper', replace


********************************************
* Merge data
use `aha', clear

merge 1:1 id year using `cooper', gen(_merge)
label define L__merge 1 "AHA (master)" 2 "Cooper (using)" 3 "Matched", modify
label values _merge L__merge


* Save
save "`projdir'/data_hospclean/aha_cooper.dta", replace
!chmod g+rw "`projdir'/data_hospclean/aha_cooper.dta"

