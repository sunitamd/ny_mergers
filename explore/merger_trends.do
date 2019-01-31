*******************
* Exploratory analysis of market-level merger trends in New York state versus rest of country
*******************

clear
set more off


*******************
* Set macros
*******************
local projdir = "/gpfs/data/desailab/home/ny_mergers"
local mkt "fips"
local mkt_label "County"


*******************
* Data Prep
*******************
use "`projdir'/data_hosp/aha_combined_final_v2.dta", clear

* One fstcd is missing
levelsof fstcd if stcd==14, local(temp)
replace fstcd = `temp' if fstcd==. & stcd==14

* Some mcntycd values also missing
levelsof mcntycd if fcounty==9003 & fcntycd==3, local(temp)
replace mcntycd = `temp' if fcounty==9003 & fcntycd

* Generate true unique FIPS county codes
gen fips = string(fstcd, "%02.0f") + string(fcntycd, "%03.0f")

* Hospital-year merger indicator
gen merger = cond(merge!=., 1, 0, 0)

* NY state indicator
gen ny = cond(fstcd==36, 1, 0)

* Indicator for analysis timeframe
gen time = cond(aha_year>=2006 & aha_year<=2012, 1, 0)

tempfile master
save `master', replace


* Total number of hospitals by state
keep if time==1
duplicates drop ny id, force
gen one = 1
bys ny: egen total_hospitals = total(one)
keep ny total_hospitals
duplicates drop

tempfile total_hospitals
save `total_hospitals', replace

* Total number of markets by state
use `master', clear
keep if time==1
duplicates drop ny `mkt', force
gen one = 1
collapse (sum) total_mkts=one, by(ny) fast

tempfile total_markets
save `total_markets', replace

*******************
* Tables (New York State vs Other States)
*******************

** A1. Mergers per hospital
use `master', clear
keep if time==1

* Hospital-level merger indicator
collapse (max) merger, by(ny id) fast
* Average & SD of hospitals w/ mergers by state
collapse (mean) mean=merger (sd) sd=merger, by(ny) fast

merge 1:1 ny using `total_hospitals', nogen

tempfile a1
save `a1', replace


** B1. Mergers per market
use `master', clear
keep if time==1

* Market-level merger indicator
collapse (max) merger, by(ny `mkt') fast
* Average & SD of market mergers by state
collapse (mean) mean=merger (sd) sd=merger, by(ny) fast
gen metric = "mergers"

tempfile b1
save `b1', replace


** B2. Closures per market
use `master', clear
keep if time==1

* Market-level hospital closure
gen closure = cond(del_reason_cat=="Closed", 1, 0, 0)
collapse (max) closure, by(ny `mkt') fast
* Average & SD of markets w/ closures by state
collapse (mean) mean=closure (sd) sd=closure, by(ny) fast
gen metric = "closures"

tempfile b2
save `b2', replace


** B3. Openings per market
use `master', clear
keep if time==1

* Market-level openings
gen opening = cond(add_reason_cat=="Newly added, New Hospital ID", 1, 0, 0)
collapse (max) opening, by(ny `mkt') fast
* Average & SD
collapse (mean) mean=opening (sd) sd=opening, by(ny) fast
gen metric = "openings"

tempfile b3
save `b3', replace


** B4. Hospitals per market
use `master', clear
keep if time==1

* Count hospitals per market
duplicates drop ny `mkt' id, force
gen one = 1
collapse (count) hospitals=one, by(ny `mkt') fast
* Average & SD hopsitals/market by state
collapse (mean) mean=hospitals (sd) sd=hospitals, by(ny) fast
gen metric = "hospitals"

tempfile b4
save `b4', replace


** B5. Beds (across all hospitals) per market
use `master', clear
keep if time==1

* Sum beds across hospitals
collapse (sum) hospbd, by(ny `mkt') fast
* Average & SD total beds/market by state
collapse (mean) mean=hospbd (sd) sd=hospbd, by(ny) fast
gen metric = "beds"

tempfile b5
save `b5', replace


** B6. Teaching hospitals per market
use `master', clear
keep if time==1

* need to add teaching variable to AHA first
gen metric = "teaching hospitals"

tempfile b6
save `b6', replace


** B7. Hospital Ownership
use `master', clear
keep if time==1

* Ownership type
gen own_govn = cond(cntrl>=12 & cntrl<=16, 1,0,0)
gen own_govf = cond(cntrl>=41 & cntrl<=48, 1,0,0)
gen own_npro = cond(cntrl>=21 & cntrl<=23, 1,0,0)
gen own_fpro = cond(cntrl>=31 & cntrl<=33, 1,0,0)
* Sum ownership types per market
collapse (sum) own_govn own_govf own_npro own_fpro, by(ny `mkt') fast
reshape long own_, i(ny `mkt') j(type) string
* Average & SD ownership types/market by state
collapse (mean) mean=own_ (sd) sd=own_, by(ny type) fast
gen metric = "ownership type"

tempfile b7
save `b7', replace


** B8. Discharges by type per market
use `master', clear
keep if time==1

* Sum discharge types per market
collapse (sum) mcrdc mcddc, by(ny `mkt')
rename *dc dc*
reshape long dc , i(ny `mkt') j(type) string
replace type = "medicaid" if type=="mcd"
replace type = "medicare" if type=="mcr"
* Average & SD discharges/market by state
collapse (mean) mean=dc (sd) sd=dc, by(ny type) fast
gen metric = "discharges"

tempfile b8
save `b8', replace


*******************
* Output
*******************
* Append tables together
clear
preserve

forvalues i=1/7 {
	* skip until teaching variable added into AHA
	if (`i'==6) {
		continue
	}

	append using `b`i''
}

save "dump/merger_trends.dta", replace