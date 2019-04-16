/*This counts readmissions as own idx if diagnosis is ami or chf, since it goes through each index value for a given
visitlink*/
cd "/gpfs/data/desailab/home/ny_mergers/data_sidclean
use "/gpfs/data/desailab/home/ny_mergers/data_sidclean/sid_work/ny_sid_0612.dta", clear
/*dropping exclusionary criteria*/
drop if amonth==1 | amonth==12 | missing(age) | missing(female) | tran_in==1 | tran_out==1
sort visitlink
/*indexing hospital stays*/
by visitlink: gen idx=_n
/* foreach index, count readmissions if diagnosis is ami and daystoevent less 30 days
flags for payer type*/
foreach x in idx {

	by visitlink: gen readm= 1 if dxccs1==100 & (daystoevent - daystoevent[_n-1])- los < 30
	by visitlink: gen readm_mcaid=.
	by visitlink: replace readm_mcaid= readm if pay_mcaid==1
	by visitlink: gen readm_pvt=.
	by visitlink: replace readm_pvt= readm if pay_pvt==1
	}
