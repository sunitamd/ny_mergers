**********************************************************************
* NY HCUP DATA 
* Creator / Last updated by : Sunita / Sunita
* Date created - updated: 01/31/19 - 02/01/19
********************************************************************** 
* Set directory
********************************************************************** 
	cd "/gpfs/data/desailab/home/ny_mergers/"
	
	use "data_hosp/aha_cooper_combined.dta", clear
	gen merge_cooper = cond(target==1 | acquirer == 1, 1, 0)
	duplicates id year, force
	
	* Keep NY and GAC
		keep if mlocstcd == "21"
		keep if serv == 10
		save "data_hosp/ahacoop.dta", replace

********************************************************************** 
* Set locals
********************************************************************** 
	use "data/sid_work/sid_aha_020119.dta", clear
	rename ahaid id 
	
	merge 1:1 id year using "data_hosp/ahacoop.dta", gen(_mrgcoop)
	drop if year < 2006
	