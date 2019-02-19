********************************************
* Exploratory data analysis of MMC county-level enrollment data
********************************************

clear
set more off


********************************************
* Macros

local proj_dir "/gpfs/data/desailab/home/ny_mergers"
local data_dir "/gpfs/home/azc211/ny_mergers/dump"


********************************************
* Read in medicaid enrollee data

use "`data_dir'/mmc_totals.dta", clear

* Collapse total enrollees to county-year
collapse (mean) total_enroll, by(county year) fast

gen total_enroll_l = total_enroll[_n-1] if county==county[_n-1]
gen total_enroll_d = total_enroll - total_enroll_l

* Collapse across counties, calculate summary statistics
collapse (mean) mean1=total_enroll mean2=total_enroll_d (sd)sd1=total_enroll sd2=total_enroll_d (p25) p251=total_enroll p252=total_enroll_d (p50) p501=total_enroll p502=total_enroll_d (p75) p751=total_enroll p752=total_enroll_d (min) min1=total_enroll min2=total_enroll_d (max) max1=total_enroll max2=total_enroll_d, by(year) fast
reshape long mean sd p25 p50 p75 min max, i(year) j(metric)

tostring metric, replace
replace metric = cond(metric=="1", "Total enrollment", "Change in enrollment")
sort metric year


* Save
save "`data_dir'/mmc_summary_stats.dta", replace


