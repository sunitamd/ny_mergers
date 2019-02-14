********************************************
* Import county-level Medicaid enrollment data (Orin)
********************************************

clear
set more off


********************************************
* Macros
local data_dir "/gpfs/home/azc211/ny_mergers/dump/"


********************************************
* Import total enrollment data

foreach y of num 4/5 {
	local j : di %02.0f `y'
	local f = 2000 + `y'
	foreach t of num 1/12 {
		local m : di %02.0f `t'
		import excel "`data_dir'/total_enrollment/`f'/`f'-`m'_eligibles.xls", cellrange(A10:P69) clear
 
		rename A county
		rename B total_enroll
		rename C tanf_child_ms
		rename D tanf_adults_ms
		rename E sn_child_ms
		rename F sn_adults_ms
		rename G ssi_aged_ms
		rename H ssi_bd_ms
		rename I tanf_child_mo
		rename J tanf_adults_mo
		rename K sn_child_mo
		rename L sn_adults_mo
		rename M aged_mo
		rename N bd_mo
		rename O fhp_mo
		rename P other_mo
 
		drop if county == "New York State" | county == "Rest of State"
 
		replace county = "NYC" if county ==  "New York City"
		replace county = "St Lawrence" if county ==  "  St. Lawrence"

		replace county = trim(county)
		
		gen month = `t'
		gen year = `f'
		
		tempfile mmc`t'_`j'
		save `mmc`t'_`j'', replace
	}
}

foreach y of num 6/7 {
	local j : di %02.0f `y'
	local f = 2000 + `y'
	foreach t of num 1/12 {
		local m : di %02.0f `t'
		import excel "`data_dir'/total_enrollment/`f'/`f'-`m'_eligibles.xls", cellrange(A7:P66) clear
 
		rename A county
		rename B total_enroll
		rename C tanf_child_ms
		rename D tanf_adults_ms
		rename E sn_child_ms
		rename F sn_adults_ms
		rename G ssi_aged_ms
		rename H ssi_bd_ms
		rename I tanf_child_mo
		rename J tanf_adults_mo
		rename K sn_child_mo
		rename L sn_adults_mo
		rename M aged_mo
		rename N bd_mo
		rename O fhp_mo
		rename P other_mo
 
		drop if county == "New York State" | county == "Rest of State"
 
		replace county = "NYC" if county ==  "New York City"
		replace county = "St Lawrence" if county ==  "  St. Lawrence"

		replace county = trim(county)

		gen month = `t'
		gen year = `f'
		
		tempfile mmc`t'_`j'
		save `mmc`t'_`j'', replace
	}
}

foreach y of num 8/12 {
	local j : di %02.0f `y'
	local f = 2000 + `y'
	foreach t of num 1/12 {
		local m : di %02.0f `t'
		import excel "`data_dir'/total_enrollment/`f'/`f'-`m'_enrollees.xls", cellrange(A7:P66) clear
 
		rename A county
		rename B total_enroll
		rename C tanf_child_ms
		rename D tanf_adults_ms
		rename E sn_child_ms
		rename F sn_adults_ms
		rename G ssi_aged_ms
		rename H ssi_bd_ms
		rename I tanf_child_mo
		rename J tanf_adults_mo
		rename K sn_child_mo
		rename L sn_adults_mo
		rename M aged_mo
		rename N bd_mo
		rename O fhp_mo
		rename P other_mo
 
		drop if county == "New York State" | county == "Rest of State"
 
		replace county = "NYC" if county ==  "New York City"
		replace county = "St Lawrence" if county ==  "  St. Lawrence"

		replace county = trim(county)

		gen month = `t'
		gen year = `f'
		
		tempfile mmc`t'_`j'
		save `mmc`t'_`j'', replace
	}
}


********************************************
* Formatting monthly files in single MMC dataset

* Append months together
forvalues y = 4/12 {
	local j : di %02.0f `y'
	local f = 2000 + `y'
	
	use `mmc1_`j'', clear
	
	forvalues n = 2/12 { 
		append using `mmc`n'_`j''
	}

	tempfile mmc_`f'
	save `mmc_`f'', replace
}

* Append years together
use `mmc_2004', clear
forvalues i = 2005/2012 {
	append using `mmc_`i''
}

replace county = trim(county)

save "`data_dir'/mmc_totals.dta", replace


