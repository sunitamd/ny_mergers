log using mergstat, replace
cd "/gpfs/data/desailab/home/ny_mergers/data_sidclean"

foreach x in "ami_index.dta" "chf_index.dta" {
use `x', clear

*merging the hcup with hosp data
merge m:1 ahaid year using  "/gpfs/data/desailab/home/ny_mergers/data_analytic/hospital.dta", generate(merge2)
*tagging all the hospital id's that have more than one value for merge2, indicating they at some years were match or unmatched
egen tag = tag(merge2 ahaid)
egen distinct = total(tag), by(ahaid)
*noisily tabdisp ahaid, cell(distinct)
*create variable marking if it is generally unmatched
gen unm= 1 if merge2==1 | merge2==2
*per hospital, per year what was the total unmatched obs
bys ahaid year: egen totunm= total(unm)
*per hospital, per year what was to total number of admissions (observations)
by ahaid year: gen numadm= _N
*per hospital, per year what was the rate of unmatched and matched observations
by ahaid year: gen percunm= totunm/numadm
*table for the matched status, with the freq for a hosp in a given year being unmatched or matched; 
*then the total # of admissions and the perc of unmatched for total admission
table year merge2 ahaid if distinct > 1 | merge2==1 | merge2==2, contents(freq mean numadm mean percunm )
*for any of the values missing from this value, this is dictated by the ahaid having no entries for the year as opposed to being unmatched 
}
log close
