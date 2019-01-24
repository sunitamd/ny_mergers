

clear
set more off


** User macros
local brlist "_merge id year merger merger2 match match_lag*"


*******
** AHA Combined Data
use /gpfs/data/desailab/home/ny_mergers/data_hosp/aha_combined_final_v2.dta, clear

* Keep only general/acute care hospitals
keep if serv==10

replace merge = 0 if merge==.
label define merge 0 "0 No merger", modify

rename aha_year year

* (id, year) does not uniquely identify observations. Duplicates only differ in add_reason, drop arbitrarily for now
duplicates drop id year, force

* Create indicator for hospital merger
gen merger = 1 if inlist(merge, 1, 2, 3)
replace merger = 0 if merge == 0
assert merger != .
* Create lagged merger variables
sort id year
gen merger_lag1 = max(merger, merger[_n-1]) if id[_n-1]==id
* Not enough prior year data available in all instances, replace with 0
replace merger_lag1 = 0 if merger_lag1==.
label var merger_lag1 "AHA lagged merger indicator"

forvalues i=2/12 {
    local newlag = "merger_lag`i'"
    local j = `i' - 1
    local oldlag = "merger_lag`j'"

    gen `newlag' = 1 if `oldlag'==1 | (merger[_n-`i']==1 & id[_n-`i']==id)
    replace `newlag' = 0 if `newlag'==.

    label var `newlag' "AHA lagged merger indicator"
}

forvalues i=2/12 {
    local newlag = "merger_lag`i'"
    local j = `i' - 1
    local oldlag = "merger_lag`j'"

    gen `newlag' = max(merger, `oldlag'[_n-1]) if id[_n-`i']==id
    replace `newlag' = 0 if `newlag'==.
    
    label var `newlag' "AHA lagged merger indicator"
}

tempfile aha
save `aha', replace


*******
** Cooper Hospital Mergers Data
use inputs/cooper_merger/HC_ext_mergerdata_public.dta, clear

* Create merger indicators
gen merger2 = 1 if target==1 | acquirer==1
replace merger2 = 0 if target==0 & acquirer==0
assert merger2==1 if (target==1 | acquirer==1)
assert merger2==0 if (target==0 & acquirer==0)
* Lagged merger indicators
sort id year
gen merger2_lag1 = max(merger2, merger2[_n-1]) if id[_n-1]==id
replace merger2_lag1 = 0 if merger2_lag1==.
label var merger2_lag1 "Cooper lagged merger indicator"

forvalues i=2/12 {
    local newlag  = "merger2_lag`i'"
    local j = `i' - 1
    local oldlag = "merger2_lag`j'"

    gen `newlag' = 1 if `oldlag'==1 | (merger2[_n-`i']==1 & id[_n-`i']==id)
    replace `newlag' = 0 if `newlag'==.
    
    label var `newlag' "Cooper lagged merger indicator"
}

tempfile cooper
save `cooper', replace


*******
** Merge datasets
merge 1:1 id year using `aha', force
label define L_source 1 "Cooper" 2 "AHA" 3 "matched", add
label values _merge L_source

* keep only years that overlap
* keep if year > 2000 & year < 2013

* Identify mergers that matched
gen match = 1 if merger==1 & merger2==1
replace match = 2 if merger==0 & merger2==0
replace match = 3 if merger==1 & merger2==0
replace match = 4 if merger==0 & merger2==1

label define L_match 1 "1 Matched merger" 2 "2 Matched no-merger" 3 "3 Unmatched AHA merger" 4 "4 Unmatched Cooper merger", add
label values match L_match

forvalues i=1/12 {
    local newvar "match_lag`i'"
    local aha_lag "merger_lag`i'"
    local cooper_lag "merger2_lag`i'"

    gen `newvar' = 1 if `aha_lag'==1 & `cooper_lag'==1
    replace `newvar' = 2 if `aha_lag'==0 & `cooper_lag'==0
    replace `newvar' = 3 if `aha_lag'==1 & `cooper_lag'==0
    replace `newvar' = 4 if `aha_lag'==0 & `cooper_lag'==1
    
    label values `newvar' L_match
}

tempfile merged
save `merged', replace

* Among hospital-year observations in both datasets, how do mergers match up?
ta match _merge if _merge==3, m

forvalues i=1/12  {
    ta match_lag`i' _merge if _merge==3, m
}

* Outsheet results
preserve

keep id year merger merger2 merger_lag* merger2_lag* match match_lag* _merge

outsheet using dump/compare_mergers.csv, comma replace nolabel

restore

* PDF output

log using "dump/merger_comparisons.smcl", replace

di "Merge results of two datasets"
table _merge, m
di "10,543 hospital-year obs. not in AHA dataset"
di "9,799 hospital-year obs. not in Cooper dataset"

di "Merger results among matched hospital-year obs."
table match if _m==3, m

di "Merger results among matched hospital-year obs. using a 2 year window"
table match_lag1 if _m==3, m


log close
translate "dump/merger_comparisons.smcl" "dump/merger_comparisons.pdf"

