********************************************
* Geo-lookup lat/lon coordinates from Cooper data - helper script
********************************************

clear
set more off


********************************************
* Name command line args
args scratch_dir api_key i


********************************************
* Read in chunk
use `scratch_dir'/inputs/chunk_`i'.dta, clear

opengeocage, key(`api_key') lat(lat) lon(lon)

save `scratch_dir'/outputs/chunk_`i'.dta, replace
