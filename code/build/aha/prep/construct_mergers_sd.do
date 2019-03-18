**********************************************************************
* Identifying number of hosital mergers by market + control group
* Creator / Last updated by : Sunita / Sunita
* Date created - updated: 01/22/19 - 02/11/19
********************************************************************** 
* Set directory
********************************************************************** 
	global proj_dir "/gpfs/data/desailab/home"

********************************************************************** 
* Set locals
********************************************************************** 
global mkt cnty

********************************************************************** 
* Do Data Analysis
*********************************************************************

use "$proj_dir/ny_mergers/data_hospclean/ahacooperall_cleaned.dta", clear	
	drop add_reason_cat add_reason dup deletion sys_merge merge mergect mergert sys_wi_merge sys_cm_merge merger add_del_merge
			

	* Dropping non-merges
	drop if _merge == 2
	
	* rename some variables
		rename sysid sysid_orig
		rename sysid2 sysid_coop 
		rename merger2 merger
		
	* Create new SYS ID 
		gen sysid = sysid_coop
		
	* Replace bed variable for missing hospitals 
		gen nbeds = bdtot 
		replace nbeds = bdtot if nbeds == . 
		
* HHI variable construction - Hospital
	foreach mkt in cnty hrr {
	capture drop hhi_`mkt' 
	capture drop nbeds_mkt mktshr mktshr_sq
		bysort `mkt' year: egen nbeds_mkt = total(nbeds) 
		gen mktshr = nbeds/nbeds_mkt
		gen mktshr_sq = mktshr^2
		bysort `mkt' year: egen hhi_`mkt' = total(mktshr_sq)
		la var hhi_`mkt' "HHI - `mkt', Mkt shr based on nbeds"	
		drop nbeds_mkt mktshr mktshr_sq
	}
	
* HHI variable construction - System
	*Create new sys_id so no system hospitals get a unique id  
	foreach mkt in cnty hrr {
	capture drop hhisys_`mkt' 
	capture drop nbeds_mkt nbeds_sys mktshr_sys sysid_temp mktshr_sys_temp mktshr_syssq_temp hhi_sys_temp
		* Create market share variables 
			bysort `mkt' year: egen nbeds_mkt = total(nbeds) 
			bysort sysid `mkt' year: egen nbeds_sys = total(nbeds) 
			gen mktshr_sys = nbeds_sys/nbeds_mkt 
			
		* Create unique values for systems to avoid double counting
			bysort `mkt' sysid year: gen sysid_temp = 1 if [_n==1]
			gen mktshr_sys_temp = mktshr_sys if sysid_temp == 1 
			gen mktshr_syssq_temp = mktshr_sys_temp^2
			bysort `mkt' year: egen hhi_sys_temp = total(mktshr_syssq_temp) 
		
			gen hhisys_`mkt' = hhi_sys_temp 
			bysort `mkt'  (hhisys_`mkt'): replace hhisys_`mkt' = hhisys_`mkt'[_n-1] if missing(hhisys_`mkt')
			la var  hhisys_`mkt' "`mkt'-level HHI by system mktshr"
		}

* Number of hospitals in market
	gen one = 1
	foreach mkt in cnty hrr {
		bysort `mkt' year: egen nhosp_`mkt' = total(one)
		la var nhosp_`mkt' "# hosp mkts (`mkt')"
	}
	
	* Save file before creating event study indicators
		save "$proj_dir/ny_mergers/data_hospclean/ahacooperall_whhi.dta", replace
		!chmod g+rw "$proj_dir/ny_mergers/data_hospclean/ahacooperall_whhi.dta"
	
***********************************************************************
* Create event study merger varaibles
***********************************************************************
* Old; 

use "$proj_dir/ny_mergers/data_hospclean/ahacooperall_whhi.dta", clear

keep if year >= 2006 & year <= 2012 

foreach mrg in merger target acquirer { 
foreach wind in 2 {
* Create merger variable at hospital level (2-year )
capture drop `mrg'_tag `mrg'_none 
capture drop `mrg'_yrtemp  `mrg'_yrfrst 
capture drop post_`mrg'`wind' 

	* Change the merger_none variable so a hospital cannot be a control hospital after it has a merger
		gen `mrg'_yrtemp = year if `mrg' == 1 
		bysort id: egen `mrg'_yrfrst = min(`mrg'_yrtemp )	
		
	* How many mergers are before 2008 
		tab  `mrg'_yrfrst
		tab `mrg'_yrfrst if fstcd==36
		
	* Create a window 
		gen `mrg'_dif =  year -`mrg'_yrfrst 
		
	* Generate treatment var 
		by id: gen `mrg'_wind`wind'=1 if `mrg'_dif >=-`wind' & `mrg'_dif <=`wind'
		bysort id: egen cnt_`mrg'_obs=total(`mrg'_wind`wind')
		local minobs = `wind'*2+1
		
		gen post_`mrg' = 1 if `mrg'_yrfrst != . & `mrg'_wind`wind' == 1 & cnt_`mrg'_obs >= `minobs' & cnt_`mrg'_obs != . & `mrg'_dif >=0
		replace post_`mrg' = 0 if `mrg'_yrfrst != . & `mrg'_wind`wind' == 1 & cnt_`mrg'_obs >= `minobs' & cnt_`mrg'_obs != . & `mrg'_dif <0
		replace post_`mrg' = 0 if `mrg'_yrfrst == .
	}
}

* Remove those hospitals involved in acquisition from the post_target group 
	replace post_target = . if post_target == 0 & post_acquirer == 1
tab post_merger	
tab post_target	
	
* create variable for number of unique systems 
	bysort $mkt year sysid : gen sys_n = _n if _n == 1
	bysort $mkt year sysid : egen numsys = total(sys_n)
	
	destring id, replace ignore("A")
	xtset id year 
		
save "$proj_dir/ny_mergers/data_hospclean/hospmerger_fin0210.dta", replace
!chmod g+rw "$proj_dir/ny_mergers/data_hospclean/hospmerger_fin0210.dta"
		
* Save NY-only data set
	keep if year >= 2003 & year <=2012 
	keep if fstcd == 36

	tab post_merger 
	tab post_target
save "$proj_dir/ny_mergers/data_hospclean/hospmerger_ny_fin0210.dta", replace
!chmod g+rw "$proj_dir/ny_mergers/data_hospclean/hospmerger_ny_fin0210.dta"

********************************************
* Construct market-level exposure indicator
********************************************
use "$proj_dir/ny_mergers/data_hospclean/ahacooperall_whhi.dta", clear

	keep if year >= 2006 & year <= 2012

	keep sysid_coop id year merger $mkt
	gen sysid = sysid_coop

	* Drop Cooper observations w/o cnty information
	if "$mkt" == "cnty" {
		drop if inlist($mkt, ".", "..")
	}

	* Create market-level merger exposure indicator
	bysort $mkt year: egen exposure_$mkt = max(merger)

	save "$proj_dir/ny_mergers/data_analytic/market_exposure.dta", replace
	!chmod g+rw "$proj_dir/ny_mergers/data_analytic/market_exposure.dta"
	
****************************************
* Collapse to market-level data set
****************************************
use "$proj_dir/ny_mergers/data_hospclean/hospmerger_fin0210.dta", clear
	
	collapse (max) anymerger=merger anytarget=target anyacquirer=acquirer (sum) nmerger=merger ntarget=target nacquirer=acquirer nhosps=one nadm=admtot2 n_admcare=mcrdc2 n_admcaid=mcddc2  (mean) avg_hhi_$mkt=hhi_$mkt avg_hhisys_$mkt=hhisys_$mkt numsys ,  by($mkt year )
	
* Gen state code 
	gen fstcd = substr(cnty,1,2)
	
***************************************************
* Create indicators 
*browse cnty year anytarget anyacquirer anymerger post_anymerger anymerger_yrfrst
***************************************************

foreach mrg in anymerger anytarget anyacquirer {
foreach wind in 2 {

capture drop `mrg'_tag `mrg'_none 
capture drop `mrg'_yrtemp  `mrg'_yrfrst 
capture drop post_`mrg'`wind' 

	* Change the merger_none variable so a hospital cannot be a control hospital after it has a merger
		gen `mrg'_yrtemp = year if `mrg' == 1 
		bysort $mkt: egen `mrg'_yrfrst = min(`mrg'_yrtemp )	
		
	* How many mergers are before 2008 
		tab  `mrg'_yrfrst
		tab `mrg'_yrfrst if fstcd=="36"
		
	* Create a window 
		gen `mrg'_dif =   year - `mrg'_yrfrst
		
	* Generate treatment var 
		by $mkt: gen `mrg'_wind`wind'=1 if `mrg'_dif >=-`wind' & `mrg'_dif <=`wind'
		bysort $mkt: egen cnt_`mrg'_obs=total(`mrg'_wind`wind'==1 )
		local minobs = `wind'*2+1
		gen post_`mrg' = 1 if `mrg'_yrfrst != . & `mrg'_wind`wind' == 1 & cnt_`mrg'_obs >= `minobs' & cnt_`mrg'_obs != . & `mrg'_dif >=0
		replace post_`mrg' = 0 if `mrg'_yrfrst != . & `mrg'_wind`wind' == 1 & cnt_`mrg'_obs >= `minobs' & cnt_`mrg'_obs != . & `mrg'_dif <0
		replace post_`mrg' = 0 if `mrg'_yrfrst == .

}
}
	replace post_anytarget = . if post_anytarget == 0 & post_anyacquirer == 1 
	tab post_anymerger 
	tab post_anytarget 
	
	drop if cnty == ".."
	destring cnty, replace 
	xtset $mkt year 
	
	save "$proj_dir/ny_mergers/data_hospclean/market_treatcontrol_Feb 12.dta", replace
	!chmod g+rw "$proj_dir/ny_mergers/data_hospclean/market_treatcontrol_Feb 12.dta"
	
	keep if fstcd == "36"
	tab post_anymerger 
	tab post_anytarget 
	
	save "$proj_dir/ny_mergers/data_hospclean/ny_treatcontrol_Feb 12.dta", replace
	!chmod g+rw "$proj_dir/ny_mergers/data_hospclean/ny_treatcontrol_Feb 12.dta"
