**********************************************************************
* Identifying number of hosital mergers by market + control group
* Creator / Last updated by : Sunita / Sunita
* Date created - updated: 01/22/19 - 01/22/19
********************************************************************** 
* Set directory
********************************************************************** 
	cd "/gpfs/data/desailab/home/ny_mergers/data_hosp/"

********************************************************************** 
* Set locals
********************************************************************** 
local mkt fcounty


********************************************************************** 
* Create market-year level data with HHI and merger indicators
********************************************************************** 
	use "aha_combined_final_v2.dta", clear
	use "aha_cooper_combined.dta", clear
	
* To do 
	* Var with # unique systems in a market
	* 

* Keep NY and GAC
	keep if mlocstcd == "21"
	keep if serv == 10

* HHI variable construction - Hospital
	bysort `mkt' aha_year: egen tot_hospbd = total(hospbd) 
	gen mktshr = hospbd/tot_hospbd
	gen mktshr_sq = mktshr^2
	bysort `mkt' aha_year: egen hhi = total(mktshr_sq)
	la var hhi "County-level HHI, Var used for market share: hospbd"

* HHI variable construction - System
	*Create new sys_id so no system hospitals get a unique id  
		gen sysid_temp = _n
		replace sysid_temp = sysid 
		
	* Create system level market share 
		bysort sysid_temp `mkt' aha_year: egen mktshr_sys = total (mktshr) 
		gen mktshr_sys_sq = mktshr_sys^2
		bysort `mkt' aha_year: egen hhi_sys = total(mktshr_sys_sq) 
		la var "County-level HHI by system"
		

* Number of hospitals
	gen one = 1
	bysort `mkt' aha_year: egen num_hosps = total(one)
	la var num_hosps "Number of hospitals in market (county)"

* Indicator for any market
	gen merge_any = cond(sys_merge == 1 | add_del_merge == 1, 1, 0)
	gen hosp = 1

****************************************
* Collapse to market-level data set
****************************************
	collapse (sum) merge_any hosp (mean) hhi  ,  by(`mkt' aha_year)

* Indicator for any merge 
	gen merge_mkt = cond(merge_any>1,1,0)

* Indicator for markets with merger in observation year and no mergers in 2 years before or after (treatment)
	bysort `mkt': gen merge_tag = cond(merge_mkt == 1 & merge_mkt[_n-1] != 1 & merge_mkt[_n-2] != 1 & merge_mkt[_n+1] != 1 & merge_mkt[_n+2] != 1,1,0) 

* Indicator for markets with no mergers in observation year or 2 years before or after (control)
	bysort `mkt': gen merge_none = cond(merge_mkt == 0 & merge_mkt[_n-1] == 0 & merge_mkt[_n-2] == 0 & merge_mkt[_n+1] == 0 & merge_mkt[_n+2] == 0,1,0) 

* Create treatment var 
	gen treat = . 
	replace treat = 1 if merge_tag == 1
	replace treat = 0 if merge_none == 1
	la var treat "Treatment==1, Control==0, Neither==."
	
	tab merge_tag if aha_year > 2005 & aha_year < 2013
	tab merge_none if aha_year > 2005 & aha_year < 2013


