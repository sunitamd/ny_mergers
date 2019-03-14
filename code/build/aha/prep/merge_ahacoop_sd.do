**********************************************************************
* Identifying number of hosital mergers by market + control group
* Creator / Last updated by : Sunita / Sunita
* Date created - updated: 01/22/19 - 01/22/19
********************************************************************** 
* Set directory
********************************************************************** 
	global filepath /gpfs/data/desailab/home
	cd "$filepath/ny_mergers/"

********************************************************************** 
* Set locals
**********************************************************************
	use "data_hospclean/aha_combined_final_v2.dta", clear
	
	tostring sysid, replace
	label var sysid "AHA sysid"
	
	rename aha_year year 
	rename v53 lon 
	
	replace merge = 0 if merge==.
	label define merge 0 "0 No merger", modify

	* Drop duplicates from raw data
	duplicates tag id year, gen(dup)
	drop if dup>0 & add_reason!="Status Changed To Registered"

	* Fix county data for Lewis County General
	replace mcntycd = 49 if id=="6212320" & mcntycd!=49
	replace fcntycd = 49 if id=="6212320" & fcntycd!=49
	replace cntyname = "Lewis, NY" if id=="6212320" & cntyname!="Lewis, NY"
	replace fcounty = 36049 if id=="6212320" & fcounty!=36049

	
	* Create indicator for hospital merger
		gen merger = 1 if inlist(merge, 1, 2, 3)
		replace merger = 0 if merge == 0
		assert merger != .
		label var merger "AHA merger indicator"

		sort id year

		
	save "data_hospclean/ahaall_cleaned.dta", replace
	!chmod g+rw "data_hospclean/ahaall_cleaned.dta"
	
********************************************
** Cooper Hospital Mergers Data
********************************************
	*use "data_hospclean/HC_ext_mergerdata_public.dta", clear
	use "$filepath/orig_data/cooper_mergers/HC_ext_mergerdata_imputed.dta", clear
	
	rename sysid sysid2
	label var sysid2 "Cooper sysid"
	
	foreach var in provzip bdtot_orig admtot mcrdc mcddc fte techtotal teaching cah own_fp own_np own_gov prop_caid prop_care lat lon {
		rename `var' `var'2
		}
	
	* Create merger indicators
		gen merger2 = 1 if target==1 | acquirer==1
		replace merger2 = 0 if target==0 & acquirer==0
		assert merger2==1 if (target==1 | acquirer==1)
		assert merger2==0 if (target==0 & acquirer==0)
		label var merger2 "Cooper merger indicator"
		
	
		save "data_hospclean/cooperall_cleaned.dta", replace 
		!chmod g+rw "data_hospclean/cooperall_cleaned.dta"
************************************************************************************************		
********************************************************************************************
** Merge data sets 
********************************************************************************************
************************************************************************************************		
	use "data_hospclean/cooperall_cleaned.dta", clear
		merge 1:1 id year using "data_hospclean/ahaall_cleaned.dta"
		label define L_source 1 "Cooper (master)" 2 "AHA (using)" 3 "matched", add
		label values _merge L_source
		
		tab _merge 
		
		rename hrrcode hrr 
		
	* Keep only hospitals in the 50 states and remove rehab hospitals 
		drop if fstcd >=3 & fstcd <=8
		drop if serv == 46 | serv == 62 | serv== 80 | serv==90
	
	* Fill in service type for Cooper data set 
		bysort id (serv) : assert (serv == serv[1]) | missing(serv)
		* Not always consistent but filling in missing values with the previous years type
		bysort id  (serv): replace serv = serv[_n-1] if missing(serv)
	
	* Fill in HRR code for missing 
		bysort id  (hrr): replace hrr = hrr[_n-1] if missing(hrr)
	
	* Fill in fcounty for missing 
		bysort id  (fcounty): replace fcounty = fcounty[_n-1] if missing(fcounty)
		bysort id  (fstcd): replace fstcd = fstcd[_n-1] if missing(fstcd)
		
		* Create state-county FIPS code ; rename hrrcode to be shorter
			gen cnty=string(fstcd,"%02.0f") + string(fcounty,"%05.0f")
	
		count if _merge == 1 & serv == .
		unique id if _merge==1 & serv == .
	
	* Are these hospitals that were added because they were involved in a merger? Yes
			gen ever_merger2 = cond(merger2==1,1,.)
			bysort id (ever_merger2): replace ever_merger2 = ever_merger2[_n-1] if missing(ever_merger2)
			tab ever_merger2 if _merge == 1 & serv == . 

		
	save "data_hospclean/ahacooperall_cleaned.dta", replace
	!chmod g+rw "data_hospclean/ahacooperall_cleaned.dta"
	
************************************************!!!!!!!!!!!!!!!!!!!
* !!!!Explore the unmerged Cooper data set (_merge== 1)
************************************************!!!!!!!!!!!!!!!!!!!!!

* Remove non-overlapping years
	drop if year ==2000 | year > 2014
		
	* No longer an issue after using imputed..
	*	* Are these hospitals that were outside the US?

* Understand the unmerged from AHA data set 
	count if _merge == 2
	unique id if _merge == 2
	tab serv if _merge == 2
	tab fstcd if _merge== 2
		
	tab _merge
	
	gen merge_sarah = cond(merge != . & merge!= 0,1,0)
	
	* How much of the difference is due to system ID issues? Des not make sense since she has much fewer
	* System ID would lead to MORE mergers
	
	* When conditioning on matched observations Cooper has more mergers 
		bysort id (year): gen merge_sunita2 = 1 if sysid2 != sysid2[_n-1] & year >2001
		bysort id (year): gen merge_sunita = 1 if sysid != sysid[_n-1] & year >2001
		tab merge_sunita if year > 2001
		tab merge_sunita2 if year > 2001
		drop merge_sunit*
			


	
	