* Investigate differences between AHA & Cooper merger datasets


********************************************
clear
set more off


********************************************
* Macros
********************************************
local projdir "/gpfs/data/desailab/home/ny_mergers"


********************************************
* Read in merged data
********************************************
use "`projdir'/data_hospclean/aha_cooper.dta", clear

* subset data
keep if fstcd==36
keep if serv==10
keep if year>=2006 & year<=2012

tempfile aha_cooper
save `aha_cooper', replace


* Mergers identified by each source separately
qui count if merger_aha==1
local mergers_aha = `r(N)'

di in red "AHA mergers: `mergers_aha'"

qui count if merger_cooper==1
local mergers_cooper = `r(N)'

di in red "Cooper mergers: `mergers_cooper'"

* How do the mergers agree at hospital-year level
gen merger_match = 1 if merger_aha == merger_cooper & merger_aha==1
replace merger_match = 0 if merger_match==.
qui summarize merger_match if merger_aha==1
local temp: di %4.2f `r(mean)'

di in red "At hospital-year level, " `temp' * 100 "% of AHA mergers match Cooper merger"

* Investigate the AHA mergers that do not match
local temp1 = 100 - `temp'*100
qui sum sys_merge if merger_aha==1 & merger_match==0
local temp_num `r(sum)'
qui count if merger_aha==1 & merger_match==0
local temp_denom `r(N)'
local temp2: di %4.0f `temp_num' / `temp_denom' * 100


di in red "Of the " `temp1' "% of AHA mergers that do not match Cooper, " `temp2' "% are due to sysid-only mergers"
* So all 66% of AHA mergers that aren't found in Cooper are due to sysid-only mergers
* How many of these sysid-only mergers are due to changes from sys_id being missing in the prior year?
cap restore, not
preserve
levelsof id if merger_aha==1 &  merger_match==0, local(ids) clean
gen keep = 0
foreach id of local ids {
	replace keep = 1 if id=="`id'"
}
keep if keep==1
drop keep

sort id year
local brlist "id year sysid sysid_cooper merge merger_aha merger_cooper"
* tag sysid-only merges where sysid (lag or current) was missing
bys id: gen sysid_merge_na = 1 if merge==2 & (sysid[_n-1]=="." | sysid==".")
qui sum sysid_merge_na
local temp: di %4.0f `r(sum)' / `temp_num' * 100

di in red `temp' "% of sysid-only mergers due to missing sysid in AHA"

* create a new merger variable that doesn't include mergers due to previuosly missing sysid
gen merger_aha_new = merger_aha
replace merger_aha_new = 0 if sysid_merge_na==1
* compare new merger with Cooper
ta merger_aha_new merger_cooper, m
ta merger_aha merger_cooper, m
* with merger_aha_new, AHA identifies 11 less mergers


* non-sysid-only AHA mergers
tab merge if merger_aha==1 & merger_match==0, m
* 8 AHA mergers from add/del only that Cooper doesn't have



* Hospital-level comparisons
use `aha_cooper', clear
	* Identify sysid mergers in AHA
	gen merger_sysid = 1 if merge==2
	replace merger_sysid = 0 if merger_sysid==.
	* Summarize mergers at hospital level
	collapse (sum) merger merger_sysid merger2, by(id) fast
	
	* Number of hospitals involved in a merger
		* Cooper data
		count if merger2>0
		* AHA data
		count if merger>0

	* Tag hospitals where there's more AHA mergers than Cooper
	levelsof id if merger>merger2, local(aha_hospitals) clean
		* Of these hospitals, tag the ones where the extra mergers include sysid mergers
		levelsof id if merger>merger2 & merger_sysid>0, local(aha_hospitals_sysid) clean


