* Purpose: Compare mergers between combined AHA data to Cooper merger dataset. Comparing only General/Acute care hospitals in NY State 2006-2012.

clear
set more off


*******
** AHA Combined Data
use "/gpfs/data/desailab/home/ny_mergers/data_hosp/aha_combined_final_v2.dta", clear

tostring sysid, replace

replace merge = 0 if merge==.
label define merge 0 "0 No merger", modify

rename aha_year year

* (id, year) does not uniquely identify observations. Duplicates only differ in add_reason, drop arbitrarily for now (none are in NY)
duplicates drop id year, force

* Create indicator for hospital merger
gen merger = 1 if inlist(merge, 1, 2, 3)
replace merger = 0 if merge == 0
assert merger != .
label var merger "AHA merger indicator"

* Create lagged merger variables
sort id year

gen merger_lag1 = max(merger, merger[_n-1]) if id[_n-1]==id
replace merger_lag1 = 0 if merger_lag1==.
label var merger_lag1 "AHA 1-year lag merger indicator"

forvalues i=2/10 {
    local newlag = "merger_lag`i'"
    local j = `i' - 1
    local oldlag = "merger_lag`j'"

    gen `newlag' = max(merger[_n-`i'], `oldlag') if id[_n-`i']==id
    replace `newlag' = `oldlag' if id[_n-`i']!=id
    replace `newlag' = 0 if `newlag'==.
    
    label var `newlag' "AHA `i'-year lag merger indicator"
}

* Create leading merger indicator (opposite of lag)
gen merger_lead1 = max(merger, merger[_n+1]) if id[_n+1]==id
replace merger_lead1 = 0 if merger_lead1==.
label var merger_lead1 "AHA 1-year lead merger indicator"

forvalues i=2/10 {
    local newlead = "merger_lead`i'"
    local j = `i' - 1
    local oldlead = "merger_lead`j'"

    gen `newlead' = max(merger[_n+`i'], `oldlead') if id[_n+`i']==id
    replace `newlead' = `oldlead' if id[_n+`i']!=id
    replace `newlead' = 0 if `newlead'==.

    label var `newlead' "AHA `i'-year lead merger indicator"
}

* Create bandwidth merger indicator
forvalues i=1/10 {
    local merger_bw = "merger_bw`i'"
    local lag = "merger_lag`i'"
    local lead = "merger_lead`i'"

    gen `merger_bw' = max(merger, `lag', `lead')
    assert `merger_bw' != .

    label var `merger_bw' "AHA +/- 1-year window merger indicator"
}

tempfile aha
save `aha', replace


*******
** Cooper Hospital Mergers Data
use "/gpfs/data/desailab/home/ny_mergers/data_hosp/HC_ext_mergerdata_public.dta", clear

* Create merger indicators
gen merger2 = 1 if target==1 | acquirer==1
replace merger2 = 0 if target==0 & acquirer==0
assert merger2==1 if (target==1 | acquirer==1)
assert merger2==0 if (target==0 & acquirer==0)
label var merger2 "Cooper merger indicator"

tempfile cooper
save `cooper', replace


*******
** Merge datasets
merge 1:1 id year using `aha', force
label define L_source 1 "Cooper" 2 "AHA" 3 "matched", add
label values _merge L_source

tempfile merged
save `merged', replace

* keep only years relevant for analysis
keep if year >= 2006 & year <= 2012

* keep only hospitals in NY state
keep if fstcd==36

* keep only General/Acute care hospitals
* The type of facility is determined from the last four digits of its CMS Certification Number:
* Short Term Acute Care   0001-0899
* Childrens   3300-3399
* Critical Access 1300-1399
* Long Term   2000-2299
* Psychiatric 4000-4499
* Rehabilitation  3025-3099
* Other none of above

keep if serv==10 | regexm(id, "0[0-8][0-9][1-9]$")==1


** Merger comparisons
* Total mergers across both datasets
gen merger_combined = 1 if merger==1 | merger2==1
replace merger_combined = 0 if merger_combined==.

* Percentage of hospital-year mergers that match between AHA & Cooper
gen match = 1 if merger==1 & merger2==1
replace match = 2 if merger2==1 & merger!=1
replace match = 3 if merger==1 & merger2!=1

label var match "Merger concordance"
label define L_match 1 "In AHA & Cooper" 2 "In Cooper only" 3 "In AHA only", modify
label values match L_match

qui count if match==1
local merger_matches = `r(n)'
qui sum merger
local mergers_aha = `r(sum)'
qui sum merger2
global mergers_cooper = `r(sum)'

di in red round(`merger_matches'/`mergers_aha'*100,2) "% of AHA mergers match to Cooper dataset"
di in red round(`merger_matches'/$mergers_cooper*100,2) "% of Cooper mergers matched by AHA"

* Consider windows of varying years
foreach i in 1 2 5 10 {
    local aha_merger = "merger_bw`i'"

    qui gen match_temp = 1 if `aha_merger'==1 &  merger2==1

    qui sum match_temp
    local merger_matches_temp = `r(sum)'

    di in red "Considering a `i'-year window..."
    di in red round(`merger_matches_temp'/$mergers_cooper*100,2) "% of Cooper mergers matched by AHA"
    di ""

    qui drop match_temp
}
