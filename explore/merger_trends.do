********************************************
* Exploratory analysis of market-level merger trends in New York state versus rest of country
********************************************

clear
set more off


********************************************
* Set macros
********************************************
local projdir = "/gpfs/data/desailab/home/ny_mergers"
local mkt "fcounty"
local mkt_label "County"

* Create tempfiles for table outputs
local table_list = "total_mkts hosp_merger_share merger_n merger_pr closure_pr opening_pr hosp_n beds_n ownership_pr discharges"
foreach tbl of local table_list {
	tempfile `tbl'
}


********************************************
* Data Prep
********************************************
use "`projdir'/data_hosp/aha_combined_final_v2.dta", clear

	* One fstcd is missing
		levelsof fstcd if stcd==14, local(temp)
	replace fstcd = `temp' if fstcd==. & stcd==14
	* Some mcntycd values also missing
		levelsof mcntycd if fcounty==9003 & fcntycd==3, local(temp)
		replace mcntycd = `temp' if fcounty==9003 & fcntycd

	* Hospital-year merger indicator
		gen merger = cond(merge!=., 1, 0, 0)
	* NY state indicator
		gen ny = cond(fstcd==36, 1, 0)
	* Keep only data relevant for main analysis
		gen time = cond(aha_year>=2006 & aha_year<=2012, 1, 0, 0)

		keep if time == 1
		keep if serv == 10

tempfile master
save `master', replace


* Total number of hospitals by state, year
use `master', clear
	duplicates drop ny aha_year id, force
	gen one = 1
	bys ny aha_year: egen hospitals = total(one)
	keep ny aha_year hospitals
	duplicates drop

tempfile total_hospitals
save `total_hospitals', replace


* Total number of markets per state, year
use `master', clear
	gen one = 1
	duplicates drop ny `mkt' aha_year, force
	collapse (sum) value=one, by(ny aha_year) fast
	gen metric = "Total number of markets"

save `total_mkts', replace


********************************************
* Tables (New York State vs Other States)
********************************************

********************************************
** HOSPITAL-LEVEL STATISTICS

** Mergers per hospital
use `master', clear

	* Hospital-year level merger indicator
		collapse (max) merger, by(ny aha_year id) fast
	* Sum hospitals experiencing a merger over over years
		collapse (sum) mergers=merger, by(ny aha_year) fast

	merge 1:1 ny aha_year using `total_hospitals', nogen assert(3)
	gen value = mergers / hospitals
	gen metric = "Prop. of hosp involved in merger "

save `hosp_merger_share', replace


********************************************
** MARKET-YEAR LEVEL STATISTICS

** Number of hospitals involved in a merger
use `master', clear

	* indicate hospitals involved in merger
		collapse (max) merger, by(ny `mkt' aha_year id)
	* sum hospitals involved in merger
		collapse (sum) value=merger, by(ny)
		gen metric =  "Num. of hospitals involved in merger"

save `merger_n', replace


** Proportion of market-years with a hospital involved in a merger
use `master', clear
	
	* indicate market-years with a hospital involved in a merger
		collapse (max) merger, by(ny `mkt' aha_year)
	* proportion of market-years with a hospital involved in a merger
		collapse (mean) value=merger, by(ny)
		gen metric = "Prop. of mkt-years w/ hosp involved in merger"

save `merger_pr', replace


** Proportion of market-years experiencing a hospital closure
use `master', clear

	* indicate market-years experiencing a closure
		gen closure = cond(del_reason_cat=="Closed", 1,0,0)
		collapse (max) closure, by(ny `mkt' aha_year) fast
		collapse (mean) value=closure, by(ny)
		gen metric = "Prop. of mkt-years experiencing a closure"

save `closure_pr', replace


** Proportion of market-years experiencing a hospital opening
use `master', clear

	* indicate market-years experiencing an opening
		gen opening  = cond(add_reason_cat=="Newly added, New Hospital ID", 1,0,0)
		collapse (max) opening, by(ny `mkt' aha_year) fast
		collapse (mean) value=opening, by(ny)
		gen metric = "Prop. of mkt-years experiencing an opening"

save `opening_pr', replace


** Number of hospitals

use `master', clear

	* Count hospitals per market
		duplicates drop ny `mkt' id, force
		gen one = 1
		collapse (count) hospitals=one, by(ny `mkt') fast
	* Average & SD hopsitals/market by state
		collapse (mean) mean=hospitals (sd) sd=hospitals, by(ny) fast
		gen metric = "Avg. num. hospitals per mkt"

save `hosp_n', replace


** Number of hospital beds
use `master', clear

	* Sum beds across hospitals
		collapse (sum) hospbd, by(ny `mkt') fast
	* Average & SD total beds/market by state
		collapse (mean) mean=hospbd (sd) sd=hospbd, by(ny) fast
		gen metric = "Avg. num. of beds per mkt"

save `beds_n', replace


** Hospital ownership proportions
use `master', clear

	* Ownership type
		gen type = "gov" if (cntrl>=12 & cntrl<=16) | (cntrl>=41 & cntrl<=48)
		replace type = "nonprof" if cntrl>=21 & cntrl<=23
		replace type = "forprof" if cntrl>=31 & cntrl<=33
		assert type != ""
	* Sum ownership types
		gen one = 1
		collapse (sum) n=one, by(ny type) fast
	* Calculate proportion by ownership type
		bys ny: egen N = total(n)
		gen value = n / N
		keep ny type value
		gen metric = "Prop. ownership types"

save `ownership_pr', replace


** Discharges by type per market
use `master', clear

	* Sum discharge types per market
		collapse (sum) mcrdc mcddc, by(ny `mkt')
		rename *dc discharges*
		reshape long discharges , i(ny `mkt') j(type) string
		replace type = "medicaid" if type=="mcd"
		replace type = "medicare" if type=="mcr"
	* Average & SD discharges/market by state
		collapse (mean) mean=discharges (sd) sd=discharges, by(ny type) fast
		gen metric = "Avg. discharges per mkt"

save `discharges', replace


********************************************
* Output
********************************************
clear

gen tbl = ""

* Append all tables together for output to rmarkdown
foreach tbl of local table_list {
	append using ``tbl''
	replace tbl = "`tbl'" if tbl==""
}

* Save
save "dump/merger_trends.dta", replace
