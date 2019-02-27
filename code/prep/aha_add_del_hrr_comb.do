************************************************************************
* Obtaining HRR and Merging Add/Delete into main AHA Data Set
* Years 2000 - 2014
* Sarah Friedman
* Began: 10/8/2018
************************************************************************


************* 	PART 1: MERGE ADD/DELETE DATA INTO MAIN AHA DATA SET  *********************

/// Remove years 2013 and 2014 from Addition Data Set
use "C:\Users\sf2756\Dropbox\Sarah-Sunita mergers project\Hospital_Mergers\Data\add_delete\alladds_2000_2014.dta", replace
drop if year==2013 | year==2014
save "C:\Users\sf2756\Dropbox\Sarah-Sunita mergers project\Hospital_Mergers\Data\add_delete\alladds_2000_2012.dta", replace


/// Remove years 2000 and 2014 from Deletion Data Set
clear
use "C:\Users\sf2756\Dropbox\Sarah-Sunita mergers project\Hospital_Mergers\Data\add_delete\alldel_2000_2014.dta", replace
drop if year==2000 | year==2014
save "C:\Users\sf2756\Dropbox\Sarah-Sunita mergers project\Hospital_Mergers\Data\add_delete\alldel_2001_2013.dta", replace


/// Read-in main, already combined AHA data set
use "C:\Users\sf2756\Dropbox\Sarah-Sunita mergers project\Hospital_Mergers\Data\combined.dta"

* Merge-in additions
merge m:m id dsname using "C:\Users\sf2756\Dropbox\Sarah-Sunita mergers project\Hospital_Mergers\Data\add_delete\alladds_2000_2012.dta", keepusing(id dsname add_reason reason_cat addition)
rename _merge merge_adds

//Keep old ID if system ID and thereby hospital ID changes in the event it should not indicate a new hospital or merger
gen old = substr(add_reason, -7, 7) if reason_cat=="System ID Change - New Hospital ID"
* search carryforward (install)
bysort id (dsname) : carryforward old, gen(old_id_sysch)

* Merge deletions
merge m:m id dsname using "C:\Users\sf2756\Dropbox\Sarah-Sunita mergers project\Hospital_Mergers\Data\add_delete\alldel_2001_2013.dta", keepusing(id dsname del_reason del_reason_cat deletion)
rename _merge merge_del


save "C:\Users\sf2756\Dropbox\Sarah-Sunita mergers project\Hospital_Mergers\Data\combined_add_del.dta", replace
clear




********************* PART 2: OBTAIN AND APPEND HOSPITAL REFERRAL REGION (HRR) ZIP CODES *********************


* Add hrrcode data, based on zip code, from http://www.dartmouthatlas.org/tools/downloads.aspx?tab=39#zip_crosswalks
//2000
import excel "C:\Users\sf2756\Dropbox\Sarah-Sunita mergers project\Hospital_Mergers\Data\hrr_zip\ziphsahrr00.xls", sheet("ziphsahrr00.csv") firstrow
tostring zipcode00, replace
replace zipcode00 = "00"+zipcode00 if length(zipcode00)==3
replace zipcode00 = "0"+zipcode00 if length(zipcode00)==4
rename zipcode00 mloczip
keep mloczip hrrnum
gen hrr_year = 2000
save "C:\Users\sf2756\Dropbox\Sarah-Sunita mergers project\Hospital_Mergers\Data\hrr_zip\zip00.dta", replace
clear
* 2001
import excel "C:\Users\sf2756\Dropbox\Sarah-Sunita mergers project\Hospital_Mergers\Data\hrr_zip\ZipHsaHrr01.xls", sheet("ziphsahrr01.csv") firstrow
tostring zipcode01, replace
replace zipcode01 = "00"+zipcode01 if length(zipcode01)==3
replace zipcode01 = "0"+zipcode01 if length(zipcode01)==4
rename zipcode01 mloczip
keep mloczip hrrnum
gen hrr_year = 2001
save "C:\Users\sf2756\Dropbox\Sarah-Sunita mergers project\Hospital_Mergers\Data\hrr_zip\zip01.dta", replace
clear
* 2002
import excel "C:\Users\sf2756\Dropbox\Sarah-Sunita mergers project\Hospital_Mergers\Data\hrr_zip\ZipHsaHrr02.xls", sheet("ziphsahrr02.csv") firstrow
tostring zipcode02, replace
replace zipcode02 = "00"+zipcode02 if length(zipcode02)==3
replace zipcode02 = "0"+zipcode02 if length(zipcode02)==4
rename zipcode02 mloczip
keep mloczip hrrnum
gen hrr_year = 2002
save "C:\Users\sf2756\Dropbox\Sarah-Sunita mergers project\Hospital_Mergers\Data\hrr_zip\zip02.dta", replace
clear
* 2003
import excel "C:\Users\sf2756\Dropbox\Sarah-Sunita mergers project\Hospital_Mergers\Data\hrr_zip\ZipHsaHrr03.xls", sheet("ziphsahrr03.csv") firstrow
tostring zipcode03, replace
replace zipcode03 = "00"+zipcode03 if length(zipcode03)==3
replace zipcode03 = "0"+zipcode03 if length(zipcode03)==4
rename zipcode03 mloczip
keep mloczip hrrnum
gen hrr_year = 2003
save "C:\Users\sf2756\Dropbox\Sarah-Sunita mergers project\Hospital_Mergers\Data\hrr_zip\zip03.dta", replace
clear
* 2004
import excel "C:\Users\sf2756\Dropbox\Sarah-Sunita mergers project\Hospital_Mergers\Data\hrr_zip\ZipHsaHrr04.xls", sheet("ziphsahrr04.csv") firstrow
tostring zipcode04, replace
replace zipcode04 = "00"+zipcode04 if length(zipcode04)==3
replace zipcode04 = "0"+zipcode04 if length(zipcode04)==4
rename zipcode04 mloczip
keep mloczip hrrnum
gen hrr_year = 2004
save "C:\Users\sf2756\Dropbox\Sarah-Sunita mergers project\Hospital_Mergers\Data\hrr_zip\zip04.dta", replace
clear
* 2005
import excel "C:\Users\sf2756\Dropbox\Sarah-Sunita mergers project\Hospital_Mergers\Data\hrr_zip\ZipHsaHrr05.xls", sheet("ziphsahrr05.csv") firstrow
tostring zipcode05, replace
replace zipcode05 = "00"+zipcode05 if length(zipcode05)==3
replace zipcode05 = "0"+zipcode05 if length(zipcode05)==4
rename zipcode05 mloczip
keep mloczip hrrnum
gen hrr_year = 2005
save "C:\Users\sf2756\Dropbox\Sarah-Sunita mergers project\Hospital_Mergers\Data\hrr_zip\zip05.dta", replace
clear
* 2006
import excel "C:\Users\sf2756\Dropbox\Sarah-Sunita mergers project\Hospital_Mergers\Data\hrr_zip\ZipHsaHrr06.xls", sheet("ziphsahrr06.csv") firstrow
tostring zipcode06, replace
replace zipcode06 = "00"+zipcode06 if length(zipcode06)==3
replace zipcode06 = "0"+zipcode06 if length(zipcode06)==4
rename zipcode06 mloczip
keep mloczip hrrnum
gen hrr_year = 2006
save "C:\Users\sf2756\Dropbox\Sarah-Sunita mergers project\Hospital_Mergers\Data\hrr_zip\zip06.dta", replace
clear
* 2007
import excel "C:\Users\sf2756\Dropbox\Sarah-Sunita mergers project\Hospital_Mergers\Data\hrr_zip\ZipHsaHrr07.xls", sheet("ziphsahrr07") firstrow
tostring zipcode07, replace
replace zipcode07 = "00"+zipcode07 if length(zipcode07)==3
replace zipcode07 = "0"+zipcode07 if length(zipcode07)==4
rename zipcode07 mloczip
keep mloczip hrrnum
gen hrr_year = 2007
save "C:\Users\sf2756\Dropbox\Sarah-Sunita mergers project\Hospital_Mergers\Data\hrr_zip\zip07.dta", replace
clear
* 2008
import excel "C:\Users\sf2756\Dropbox\Sarah-Sunita mergers project\Hospital_Mergers\Data\hrr_zip\ZipHsaHrr08.xls", sheet("ziphsahrr08") firstrow
tostring zipcode08, replace
replace zipcode08 = "00"+zipcode08 if length(zipcode08)==3
replace zipcode08 = "0"+zipcode08 if length(zipcode08)==4
rename zipcode08 mloczip
keep mloczip hrrnum
gen hrr_year = 2008
save "C:\Users\sf2756\Dropbox\Sarah-Sunita mergers project\Hospital_Mergers\Data\hrr_zip\zip08.dta", replace
clear
* 2009
import excel "C:\Users\sf2756\Dropbox\Sarah-Sunita mergers project\Hospital_Mergers\Data\hrr_zip\ZipHsaHrr09.xls", sheet("ziphsahrr09") firstrow
tostring zipcode09, replace
replace zipcode09 = "00"+zipcode09 if length(zipcode09)==3
replace zipcode09 = "0"+zipcode09 if length(zipcode09)==4
rename zipcode09 mloczip
keep mloczip hrrnum
gen hrr_year = 2009
save "C:\Users\sf2756\Dropbox\Sarah-Sunita mergers project\Hospital_Mergers\Data\hrr_zip\zip09.dta", replace
clear
* 2010
import excel "C:\Users\sf2756\Dropbox\Sarah-Sunita mergers project\Hospital_Mergers\Data\hrr_zip\ZipHsaHrr10.xls", sheet("ziphsahrr10.csv") firstrow
tostring zipcode10, replace
replace zipcode10 = "00"+zipcode10 if length(zipcode10)==3
replace zipcode10 = "0"+zipcode10 if length(zipcode10)==4
rename zipcode10 mloczip
keep mloczip hrrnum
gen hrr_year = 2010
save "C:\Users\sf2756\Dropbox\Sarah-Sunita mergers project\Hospital_Mergers\Data\hrr_zip\zip10.dta", replace
clear
* 2011
import excel "C:\Users\sf2756\Dropbox\Sarah-Sunita mergers project\Hospital_Mergers\Data\hrr_zip\ZipHsaHrr11.xls", sheet("ziphsahrr11") firstrow
tostring zipcode11, replace
replace zipcode11 = "00"+zipcode11 if length(zipcode11)==3
replace zipcode11 = "0"+zipcode11 if length(zipcode11)==4
rename zipcode11 mloczip
keep mloczip hrrnum
gen hrr_year = 2011
save "C:\Users\sf2756\Dropbox\Sarah-Sunita mergers project\Hospital_Mergers\Data\hrr_zip\zip11.dta", replace
clear
//Append
use "C:\Users\sf2756\Dropbox\Sarah-Sunita mergers project\Hospital_Mergers\Data\hrr_zip\zip00.dta", clear
append using "C:\Users\sf2756\Dropbox\Sarah-Sunita mergers project\Hospital_Mergers\Data\hrr_zip\zip01.dta"
append using "C:\Users\sf2756\Dropbox\Sarah-Sunita mergers project\Hospital_Mergers\Data\hrr_zip\zip02.dta"
append using "C:\Users\sf2756\Dropbox\Sarah-Sunita mergers project\Hospital_Mergers\Data\hrr_zip\zip03.dta"
append using "C:\Users\sf2756\Dropbox\Sarah-Sunita mergers project\Hospital_Mergers\Data\hrr_zip\zip04.dta"
append using "C:\Users\sf2756\Dropbox\Sarah-Sunita mergers project\Hospital_Mergers\Data\hrr_zip\zip05.dta"
append using "C:\Users\sf2756\Dropbox\Sarah-Sunita mergers project\Hospital_Mergers\Data\hrr_zip\zip06.dta"
append using "C:\Users\sf2756\Dropbox\Sarah-Sunita mergers project\Hospital_Mergers\Data\hrr_zip\zip07.dta"
append using "C:\Users\sf2756\Dropbox\Sarah-Sunita mergers project\Hospital_Mergers\Data\hrr_zip\zip08.dta"
append using "C:\Users\sf2756\Dropbox\Sarah-Sunita mergers project\Hospital_Mergers\Data\hrr_zip\zip09.dta"
append using "C:\Users\sf2756\Dropbox\Sarah-Sunita mergers project\Hospital_Mergers\Data\hrr_zip\zip10.dta"
append using "C:\Users\sf2756\Dropbox\Sarah-Sunita mergers project\Hospital_Mergers\Data\hrr_zip\zip11.dta"

* Check for changes in hrr codes for zip codes
sort mloczip hrrnum
by mloczip (hrrnum), sort: gen diff = hrrnum[1] != hrrnum[_N]

* Keep earliest assigned hrrcode for each zip code
bysort mloczip (hrr_year): gen id = _n
keep if id==1
duplicates list mloczip
drop diff id
rename hrrnum hrrnum_new
rename hrr_year hrryear_new
save "C:\Users\sf2756\Dropbox\Sarah-Sunita mergers project\Hospital_Mergers\Data\hrr_zip\zip_hrr_tomerge.dta"






************ PART 3: INCORPORATE HRR ZIP CODE DATA INTO MAIN DATA SET AND EDIT MAIN DATA SET **************

* Read-in AHA data 
clear
use "C:\Users\sf2756\Dropbox\Sarah-Sunita mergers project\Hospital_Mergers\Data\combined_add_del.dta", clear
rename reason_cat add_reason_cat

* Remove observations which did not match to any additions or deletions
drop if merge_adds==2 | merge_del==2
drop merge_adds merge_del

* Remove US territories
drop if stcd>=3 & stcd<=8

* Prepare zip code variable
tostring mloczip, replace
replace mloczip = "0"+mloczip if length(mloczip)==4

* Add in missing zip code
replace mloczip="89081" if mlocaddr=="6900 North Pecos Road" & mloccity=="North Las Vegas"

* Merge-in hrr zip data
merge m:1 mloczip using "C:\Users\sf2756\Dropbox\Sarah-Sunita mergers project\Hospital_Mergers\Data\hrr_zip\zip_hrr_tomerge.dta"
drop if _merge==2
drop _merge

* Edit year variable
gen aha_year = 2000 if dsname=="AHA00"
replace aha_year = 2001 if dsname=="AHA01"
replace aha_year = 2002 if dsname=="AHA02"
replace aha_year = 2003 if dsname=="AHA03"
replace aha_year = 2004 if dsname=="AHA04"
replace aha_year = 2005 if dsname=="AHA05"
replace aha_year = 2006 if dsname=="AHA06"
replace aha_year = 2007 if dsname=="AHA07"
replace aha_year = 2008 if dsname=="AHA2008"
replace aha_year = 2009 if dsname=="AHA2009"
replace aha_year = 2010 if dsname=="AHA2010"
replace aha_year = 2011 if dsname=="AHA2011"
replace aha_year = 2012 if dsname=="AHA2012"





******************** PART 4: CREATE MERGER INDICATOR VARIABLES ****************************
* Create merger variable based on change in sysid
* Code below marks a 1 for each observation of a hospital that goes through a system id change
gen sys_merge=.
bysort id (aha_year): replace sys_merge=1 if sysid != sysid[_n-1] & aha_year!=2000 & _n!=1

* indicate if merger but should not be one as hospital id is not consistent -- should look into more
sort id aha_year
gen prob=1 if sys_merge==1 & id!=id[_n-1]

* remove problem cases from merger variable
sort id aha_year
replace sys_merge=. if sys_merge==1 & id!=id[_n-1]

* remove from merger variable if merged into only hospital in hrr
bysort sysid aha_year: gen hospnum=_N
replace sys_merge=. if hospnum<2
drop prob hospnum

* Based on system ID merger var [sys_merge] :
* Within-market merger 
bysort hrrnum_new sysid aha_year: gen hospnum2=_N
gen sys_wi_merge=1 if sys_merge==1 & hospnum2>1
gen sys_cm_merge=1 if sys_merge==1 & hospnum2<2
drop hospnum2

* Create Merger Variable Based on Add/Delete Merger Reason
gen add_del_merge = 1 if reason_cat=="Merger result, New Hospital ID" | reason_cat=="Merged into existing hospital, New Hospital ID" | del_reason_cat=="Merged into existing hospital" | del_reason_cat=="Merged with existing hospital to form new hospital"
replace add_del_merge = 0 if add_del_merge==.
la var add_del_merge "Merger occurred in this year, based on addition/deletion aha data"

*Fix add_del_merge
replace add_del_merge=. if aha_year==2000
sort id aha_year
replace add_del_merge=. if add_del_merge==1 & id!=id[_n-1] //why is this happening in the first place?

* Create variable of both mergers
gen merge_type = 1 if sys_merge==1 & add_del_merge==1
replace merge_type=2 if sys_merge==1 & add_del_merge!=1
replace merge_type=3 if sys_merge!=1 & add_del_merge==1
la def merge_type 1 "1 Merge based on sysid and add/del" 2 "2 Merge based on sysid only" 3 "3 Merge based on add/del only"
la val merge_type merge_type
la var merge_type "Merge type variable"

gen merge=1 if merge_type!=.
replace merge=0 if merge==.
la var merge "Merger Occurred"

save "C:\Users\sf2756\Dropbox\Sarah-Sunita mergers project\Hospital_Mergers\Data\aha_combined_final_v2.dta"







************* PART 5: REVIEW MERGER VARIABLE ***********************************

* View merger data by year --- frequencies

* All States
hist aha_year if merge!=., discrete freq ytitle("Frequency") xtitle("Year") xlab(2001(1)2012) title("Frequency of Mergers, All States")

*NY only
hist aha_year if merge!=. & inlist(substr(cntyname, -2, 2), "NY"), discrete freq ytitle("Frequency") xtitle("Year") xlab(2001(1)2012) title("Frequency of Mergers, New York Only")

* Number of mergers in NY
ta merge if inlist(substr(cntyname, -2, 2), "NY")


* View merger data by rate of mergers #mergers/#hospitals at each year
bysort aha_year: egen mergect = count(merge)
bysort aha_year: egen hospct = count(id)

gen mergert = mergect/hospct

* Line Graph of All States
twoway line mergert aha_year, ytitle("Merge Rate") xtitle("Year") xlab(2001(1)2012) title("Rate of Mergers, All States")

* Line Graph of NY only
bysort aha_year: egen mergectNY = count(merge) if inlist(substr(cntyname, -2, 2), "NY")
bysort aha_year: egen hospctNY = count(id) if inlist(substr(cntyname, -2, 2), "NY")
gen mergertNY = mergectNY/hospctNY if inlist(substr(cntyname, -2, 2), "NY")

twoway line mergertNY aha_year if inlist(substr(cntyname, -2, 2), "NY"), ytitle("Merge Rate") xtitle("Year") xlab(2001(1)2012) title("Rate of Mergers, New York State")

* Create state variable from end of county name
gen state=substr(cntyname, -2, 2)


* Export as CSV for use in R
export delimited using "C:\Users\Sarah Friedman\Dropbox\Sarah-Sunita mergers project\Hospital_Mergers\Data\aha_combined_final_v2.csv", replace







