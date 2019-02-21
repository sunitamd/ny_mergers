********************************************
* Split ny_sid_0612.dta into yearly data, and samples
********************************************

clear
set more off


********************************************
* Macros

local scratch_dir "/gpfs/scratch/azc211/ny_sid"
local proj_dir "/gpfs/data/desailab/ny_mergers"

* USER SWITCH
* sample=1 to draw random samples from each year; sample=0 to save each year in whole
local sample 1


********************************************
* Run program

forvalues year=2006/2011 {

	!sbatch "batch/split_sample_ny_sid.sh" "`scratch_dir'" "`proj_dir'" `year' `sample'
}
