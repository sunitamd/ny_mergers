********************************************
* Construct average county system HHI terciles
********************************************

clear
set more off

********************************************
* MACROS
********************************************

* Directories
global proj_dir "/gpfs/data/desailab/home"
local scratch_dir "/gpfs/scratch/azc211/ny_mergers"

* Date
local today: di %tdCCYYNNDD date(c(current_date), "DMY")

********************************************
* RUN PROGRAM
********************************************

* Data
use "$proj_dir/ny_mergers/data_hospclean/hhi_ny_sid_supp_hosp.dta", clear

    * Cnty fix for Lewis County General Hospital
    replace cnty="3636049" if ahaid=="6212320" & cnty=="3636043"

    * Bin average county system HHI into terciles
    ********************************************
    _pctile avg_hhisys_cnty if year == 2006, nquantiles(3)
    local q1 = `r(r1)'
    local q2 = `r(r2)'

    assert avg_hhisys_cnty != .
    gen avg_hhisys_cnty_T = 1 if avg_hhisys_cnty <= `q1'
    replace avg_hhisys_cnty_T = 2 if avg_hhisys_cnty > `q1' & avg_hhisys_cnty <= `q2'
    replace avg_hhisys_cnty_T = 3 if avg_hhisys_cnty > `q2'
    assert avg_hhisys_cnty_T != .
    label var avg_hhisys_cnty_T "Cnty avg. HHI sys tercile (2006)"

********************************************
* SAVE
********************************************
    
    keep ahaid cnty year avg_hhisys_cnty_T

save "$proj_dir/ny_mergers/data_analytic/hhisys_terciles.dta"
