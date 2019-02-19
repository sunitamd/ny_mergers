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
gen total_enroll_d_pct = total_enroll_d / total_enroll_l * 100
format %3.0f total_enroll_d_pct

* Collapse across counties, calculate summary statistics
collapse (mean) mean1=total_enroll mean2=total_enroll_d mean3=total_enroll_d_pct (sd)sd1=total_enroll sd2=total_enroll_d sd3=total_enroll_d_pct (p25) p251=total_enroll p252=total_enroll_d p253=total_enroll_d_pct (p50) p501=total_enroll p502=total_enroll_d p503=total_enroll_d_pct (p75) p751=total_enroll p752=total_enroll_d p753=total_enroll_d_pct (min) min1=total_enroll min2=total_enroll_d min3=total_enroll_d_pct (max) max1=total_enroll max2=total_enroll_d max3=total_enroll_d_pct, by(year) fast
reshape long mean sd p25 p50 p75 min max, i(year) j(metric)

tostring metric, replace
replace metric = "Total enrollment" if metric=="1"
replace metric = "Change in enrollment" if metric=="2"
replace metric = "Pct. change in enrollment" if metric=="3"
sort metric year


* Save
save "`data_dir'/mmc_summary_stats.dta", replace


