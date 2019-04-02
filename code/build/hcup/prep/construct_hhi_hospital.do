********************************************
* Construct hospital-level hhi measures
* Resource allocation: mem=128GB, time=1hour
********************************************

clear
set more off


* Check for ftools package
cap which ftools
if _rc==111 ssc install ftools

********************************************
* MACROS
********************************************

* Directories
global proj_dir "/gpfs/data/desailab/home"


********************************************
* RUN PROGRAM
********************************************

* Get sysids from AHA-Cooper dataset
********************************************
use "$proj_dir/ny_mergers/data_hospclean/ahacooperall_cleaned.dta", clear

	keep if fstcd==36
	keep if year>=2006 & year<=2012
	drop if artificial==1

	* Use Cooper sysid ana AHA sysid when missing
	replace sysid2 = sysid if sysid2=="" & sysid!="."
	drop if sysid2 == ""

	keep id sysid2 year
	
	rename id ahaid
	rename sysid2 sysid

tempfile sysids
save `sysids', replace


* HCUP NY SID SUPP data
********************************************
use "$proj_dir/ny_mergers/data_sidclean/sid_work/ny_sid_0612_supp.dta", clear

* Standard HHI (share of commercially-insured patients within each zipcode-MDC combination)
********************************************
		* Keep commerical patients only
		keep if pay1==3

		* Drop regular newborn to avoid over counting with delivery
		drop if drg==795

		* Drop Foreign, Homeless, Invalid, Missing zipcodes
		drop if inlist(zip, "", "A", "B", "C", "F", "H", "M")
		* Drop 3 digit zipcodes
		drop if strlen(zip)==3

		* Drop if no unique patient ID
		drop if visitlink==.

		* reduce from discharge record level to patient level
		keep visitlink zip mdc ahaid year
		duplicates drop
		gen patient=1
			label var patient "Unique patient count"

		* merge on sysid for zipcode-MDC HHI calculation
		merge m:1 ahaid year using `sysids', keep(3) nogen

		* Encode string id variables for ftool functions
		foreach var of varlist zip ahaid sysid {
			encode `var', gen(`var'_cd)
		}

	* Collapse to zipcode-MDC-hospital-level
		fcollapse (sum) patients=patient, by(zip_cd mdc ahaid_cd sysid_cd year) fast
			label var patients "Total unique patients per zipcode-MDC-hospital-year"

	* Commerical patient shares
		bysort zip_cd mdc year: egen patients_zipmdc = total(patients)
			label var patients_zipmdc "Total unique patients per zipcode-MDC-year"
		bysort sysid_cd zip_cd mdc year: egen patients_sys = total(patients)
			label var patients_sys "Total unique patients per zipcode-MDC-system-year"
		gen patient_share = patients_sys / patients_zipmdc
		gen patient_share_sq = patient_share^2
		
		* avoid double counting (since data is at zipcode-MDC-hospital-level)
		bysort sysid_cd zip_cd mdc year: gen sysid_temp = 1 if [_n==1]
		bysort zip_cd mdc year: gen patient_share_sq_temp = patient_share_sq if sysid_temp == 1
		
	* Zipcode x MDC HHI
		bysort zip_cd mdc year: egen hhi_zm = total(patient_share_sq_temp)
			label var hhi_zm "Zipcode-MDC HHI by system commercial patient share"
		drop sysid_temp patient_share_sq_temp


* Hospital-specific HHI
********************************************
	* Hospital-level HHI weights (hospital's commericial patients from zipcode x mdc / hospital's total commericial patients)
		bysort ahaid_cd year: egen patients_hosp = total(patients)
			label var patients_hosp "Total unique patients per hospital-year"
		gen w_hosp = patients / patients_hosp
			label var w_hosp "Hospital zipcode-MDC weight"
		gen hhi_zm_w = hhi_zm * w_hosp
			label var hhi_zm_w "Weighted zipcode-MDC HHI"
		bysort ahaid_cd year: egen hhi_hosp = total(hhi_zm_w)

	* Collapse to hospital-years
		keep ahaid_cd sysid_cd year hhi_hosp
		duplicates drop
		decode ahaid_cd, gen(ahaid)
		decode sysid_cd, gen(sysid)
		drop ahaid_cd sysid_cd


	* Save
	save "$proj_dir/ny_mergers/data_analytic/hhi_hospital.dta", replace
	!chmod g+rw "$proj_dir/ny_mergers/data_analytic/hhi_hospital.dta"
