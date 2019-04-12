/*current simple version*/
keep if dxccs1==100 | dxccs1==108
drop if amonth==1 | amonth==12

if dxccs1==100 | dxccs1==108{


sort visitlink daystoevent


by visitlink: gen idx = _n == 1


gen daysfrom_disch= los - daystoevent


gen readmit =.

by visitlink: replace readmit=1 if daysfrom_disch < 30
}




/*narrows dataset to AMI and and CHF*/
keep if dxccs1==100 | dxccs1==108


if dxccs1==100 | dxccs1==108{


by visitlink: replace readmit=1 if daysfrom_disch < 31
/* order events by date, check that data is fully sorted;*/
sort visitlink daystoevent

/* the first obs is always an index*/
by visitlink: gen idx = _n == 1

/* look for the next index case, i.e. more than 30 days from previous case*/
local more 1
while `more' {

    /* this is what we start from*/
    clonevar idx0 = idx
    
    /* carry over daystoevent from previous index case(s)*/
    gen idx_days = daystoevent * idx
    by visitlink: replace idx_days = idx_days[_n-1] if idx_days == 0
    
    /* number of days since last index case*/
    gen delta = daystoevent - idx_days
    
    /* add a new index case*/
    by visitlink: replace idx = 1 if delta > 30 & delta[_n-1] <= 30
    
    /* if we did not find a new case, we are done*/
    count if idx0 != idx
    local more = r(N)
    
    drop idx0 delta idx_days
    
}
