********************************************
* Split ny_sid_0612.dta into yearly data, and samples
********************************************

clear
set more off


********************************************
* Command line arguments
args scratch_dir proj_dir year sample


********************************************
* Macros
local log_file "`scratch_dir'/logs/ny_sid_`year'"

* Variables and obsverations to read in
local vars "pstco hospstco ahaid year ayear pay1 zipinc_qrtl u_blood u_cath u_ccu u_chestxray u_ctscan u_dialysis u_echo u_ed u_eeg u_ekg u_epo u_icu u_lithotripsy u_mhsa u_mrt u_newbn2l u_newbn3l u_newbn4l u_nucmed u_observation u_occtherapy u_organacq u_othimplants u_pacemaker u_phytherapy u_radtherapy u_resptherapy u_speechtherapy u_stress u_ultrasound"

/* Data should be sorted by year
 Calendar |
       year |      Freq.     Percent        Cum.
------------+-----------------------------------
       2006 | 31,755,736       16.04       16.04
       2007 | 31,848,613       16.08       32.12
       2008 | 32,771,341       16.55       48.67
       2009 | 32,971,607       16.65       65.32
       2010 | 32,755,998       16.54       81.86
       2011 |  2,578,680        1.30       83.16
       2012 | 33,343,259       16.84      100.00
------------+-----------------------------------
      Total |198,025,234      100.00
*/

local start2006 1
local end2006 31755736
local start2007 31755737
local end2007 63604349
local start2008 63604350
local end2008 96375690
local start2009 96375690
local end2009 129347297
local start2010 129347298
local end2010 162103295
local start2011 162103296
local end2011 164681975
local start2012 164681976
local end2012 198025234


********************************************
* Start log
cap log close
log using "`log_file'.smcl"


********************************************
* Read in subset of data

use in `start`year''/`end`year'' using "`proj_dir'/data_sidclean/sid_work/ny_sid_0612_supp.dta", clear

keep `vars'

if `sample' {
	sample 25
	compress

	save "`proj_dir'/data_sidclean/ny_sid_supp/samples/ny_sid_sample_`year'.dta", replace
}
else {
	compress

	save "`proj_dir'/data_sidclean/ny_sid_supp/ny_sid_`year'.dta", replace
}


* Close log
log close "`log_file'.smcl"
translate "`log_file'.smcl" "`log_file'.log"
