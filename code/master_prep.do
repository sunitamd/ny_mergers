********************************************
* MASTER PREP
* Imports, cleans, and preps all raw data sources for analysis
********************************************

clear
set more off


********************************************
* GLOBALS
********************************************

global today: di  %tdccyynndd date(c(current_date), "DMY")

global user "`c(username)'"
global os "`c(os)'"

global proj_dir "/gpfs/data/desailab/home"
global scratch_dir "/gpfs/scratch/$user/ny_mergers"


********************************************
* RUN PROGRAM
********************************************
