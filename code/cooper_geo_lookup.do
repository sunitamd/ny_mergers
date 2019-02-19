********************************************
* Geo-lookup lat/lon coordinates from Cooper data - master script
********************************************

clear
set more off


********************************************
* Macros
local projdir "/gpfs/data/desailab/home/ny_mergers"
local kerberosID "azc211"
local scratch_dir "/gpfs/scratch/`kerberosID'/cooper_geo_lookup"
local api_key "de087621b9f14746b246d1fc1905803a"


********************************************
* Cooper data
use "`projdir'/data_hospclean/HC_ext_mergerdata_public.dta", clear

sort id year

* Drop duplicated id-lat-lon to reduce computation
duplicates drop id lat lon, force

* Divide remaining dataset into 5 chunks
gen n = _n
egen chunk = cut(n), group(5)

* Prepare data for parallelization
cap confirm file `scratch_dir'
if !_rc {
	cap mkdir `scratch_dir'
	* Assert directory made
	assert !_rc
	cap mkdir `scratch_dir'/inputs
	cap mkdir `scratch_dir'/outputs
}

preserve
* Save chunks, launch batch jobs
fovalues of i=0/4 {
	keep if chunk==`i'

	save "`scratch_dir'/inputs/chunk_`i'.dta", replace
	
	* Launch batch jobs
	!sbatch "batch/cooper_geo_lookup.sh" `kerberosID' `api_key' `scratch_dir' `i'

	restore, preserve
}

restore, not



