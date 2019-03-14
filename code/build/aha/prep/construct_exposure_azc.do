********************************************
* Construct market-level exposure indicator for hospitals
* Using cooper data for all states
********************************************

clear
set more off

********************************************
* Macros

* Directories, filepaths
local proj_dir "/gpfs/data/desailab/home/ny_mergers"

* Market variables
local mkts cnty

********************************************
* Run program

use "`proj_dir'/data_hospclean/ahacooperall_cleaned.dta", clear

	* Drop some AHA variables
	drop add_reason_cat add_reason dup sys_merge merge mergect mergert sys_wi_merge sys_cm_merge merger add_del_merge

	* Drop non-merges
	drop if _merge==2

	* rename some variables
	rename sysid sysid_orig
	rename sysid2 sysid_coop
	rename merger2 merger

	gen sysid = sysid_coop

	* If market is county, some Cooper data do not have county info
	if inlist("`mkts'", "cnty") {
		drop if inlist(cnty, ".", "..")
	}

	* Create market-level merger indicator
	local mkt_merger_vars
	foreach mkt of local mkts {
		bysort `mkt' year: egen `mkt'_merger = max(merger)
		local mkt_merger_vars `mkt_merger_vars' `mkt'_merger
	}

	* Keep relevant variables, save
	keep id sysid year `mkts' `mkt_merger_vars'

	save "`proj_dir'/data_analytic/market_exposure.dta", replace
	!chmod g+rw "`proj_dir'/data_analytic/market_exposure.dta"
