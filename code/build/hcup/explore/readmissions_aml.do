cd "/gpfs/data/desailab/home/ny_mergers/data_sidclean
use "/gpfs/data/desailab/home/ny_mergers/data_sidclean/sid_work/ny_sid_0612.dta", clear
sort visitlink daystoevent
/*create daystoevent variables specific for diagnosis*/
by visitlink: gen dte_ami= daystoevent if dxccs1==100
by visitlink: gen dte_chf= daystoevent if dxccs1==108
/*indexes all hospitalizations*/
by visitlink: gen idx=_n
/*For each indexed ami and chf hospitalization, create 30 day readmission*/
foreach x in idx {
  /*create index for cases after admission*/
	by visitlink: gen next_idx_a= `x'+1 if dxccs1==100
  /*daystoevents for these next cases*/
	by visitlink: gen dte_next_a=daystoevent if next_idx_a>1
  /*counting readmission cases when differences between daystoevent accounting for los is less than 30*/
	by visitlink: gen readm_aft_ami= 1 if (dte_next_a - dte_ami)- los < 30
	}
foreach x in idx {
	by visitlink: gen next_idx_chf= `x'+1 if dxccs1==108
	by visitlink: gen dte_next_c=daystoevent if next_idx_c>1
	by visitlink: gen readm_aft_chf= 1 if (dte_next_c - dte_chf)- los < 30
	}
