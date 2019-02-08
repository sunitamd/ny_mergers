* Investigate differences between AHA & Cooper merger datasets


********************************************
clear
set more off


********************************************
* Macros
********************************************
local projdir "/gpfs/data/desailab/home/ny_mergers"
local brlist "id year sysid sysid_cooper merge merger_aha merger_cooper"


********************************************
* Read in merged data
********************************************
use "`projdir'/data_hospclean/aha_cooper.dta", clear

* subset data
keep if fstcd==36
keep if serv==10
* analysis is 2006-2012, but need 2005 to look missing sysid in previous year
keep if year>=2005 & year<=2012


********************************************
* Mergers identified by each source separately
qui count if merger_aha==1 & year>2005
local mergers_aha = `r(N)'

di in red "AHA mergers: `mergers_aha'"

qui count if merger_cooper==1 & year>2005
local mergers_cooper = `r(N)'

di in red "Cooper mergers: `mergers_cooper'"

* How do the mergers agree at hospital-year level
gen merger_match = 1 if merger_aha == merger_cooper & merger_aha==1
	replace merger_match = 0 if merger_match==.
qui summarize merger_match if merger_aha==1 & year>2005
local temp: di %4.2f `r(mean)'

di in red "At hospital-year level, " `temp' * 100 "% of AHA mergers match Cooper merger"

* Investigate the AHA mergers that do not match
local temp1 = 100 - `temp'*100
qui sum sys_merge if merger_aha==1 & merger_match==0 & year>2005
local temp_num `r(sum)'
qui count if merger_aha==1 & merger_match==0 & year>2005
local temp_denom `r(N)'
local temp2: di %4.0f `temp_num' / `temp_denom' * 100


di in red "Of the " `temp1' "% of AHA mergers that do not match Cooper, " `temp2' "% are due to sysid-only mergers"

tempfile aha_cooper
save `aha_cooper', replace

********************************************
* How many of these sysid-only mergers are due to changes from sys_id being missing?
* look at only hospitals w/ unmatched mergers
levelsof id if merger_aha==1 &  merger_match==0, local(ids) clean
gen keep = 0
foreach id of local ids {
	replace keep = 1 if id=="`id'"
}
keep if keep==1
drop keep

* tag sysid-only merges where sysid (lag or current) was missing
bys id: gen sysid_merge_na = 1 if merge==2 & (sysid[_n-1]=="." | sysid==".")
	label var sysid_merge_na "sysid-only mergers involving missing sysid"
drop if year==2005

qui sum sysid_merge_na
local temp: di %4.0f `r(sum)' / `temp_num' * 100

di in red `temp' "% of sysid-only mergers due to missing sysid in AHA"

tempfile non_matching_mergers
save `non_matching_mergers', replace

********************************************
* There are non-matching mergers due to add/del-only or sysid-only. Do these mergers match Cooper on a hospital level?
bys id: egen merger_hosp_aha = sum(merger_aha)
	label var merger_hosp_aha  "Hosp-level AHA mergers"
bys id: egen merger_hosp_cooper = sum(merger_cooper)
	label var merger_hosp_cooper "Hosp-level Cooper mergers"
gen merger_hosp_match = 1 if merger_hosp_aha>0 & merger_hosp_cooper>0
	replace merger_hosp_match = 0 if merger_hosp_match==.

cap restore, not
preserve

********************************************
* number of non-matching add/del-only mergers
qui count if merger_match==0 & merge==3
local total `r(N)'
* how many now match at hospital level
qui count if merger_match==0 & merge==3 & merger_hosp_match==1

di in red "Number of non-matching add/del-only mergers that match at hospital level: " `r(N)' + 0 " out of " `total'

* number of non-matching sysid-only mergers
qui count if merger_match==0 & merge==2
local total `r(N)'
* how many now match at hospital level
qui count if merger_match==0 & merge==2 & merger_hosp_match==1

di in red "Number of non-matching sysid-only mergers that match at hospital level: " `r(N)' " out of " `total'

* of the sysid-only mergers that match at hospital level, how many are "extra" mergers
local temp `r(N)'
qui count if merger_match==0 & merge==2 & merger_hosp_match==1 & merger_hosp_aha > merger_hosp_cooper

di in red `r(N)' " out of " `temp' " non-matching sysid-only mergers create extra merger at hospital-level, compared to Cooper"

********************************************
* create a new merger variable that doesn't include mergers due to previuosly missing sysid
gen merger_aha_new = merger_aha
	replace merger_aha_new = 0 if sysid_merge_na==1
	label var merger_aha_new "AHA merger indicator (no missing sysid mergers)"
* compare new merger with Cooper
ta merger_aha_new merger_cooper, m
ta merger_aha merger_cooper, m


* non-sysid-only AHA mergers
tab merge if merger_aha==1 & merger_match==0, m



