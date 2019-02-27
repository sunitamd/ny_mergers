/*******************************************************************            
*   Explore SID Data
* Owner: Sunita
* Dates: 02/11/19-02/11-19                                  
*******************************************************************/            
  
  libname sid "/gpfs/data/desailab/home/ny_mergers/data_sidclean/sid_work";   
  libname orig2006 "/gpfs/data/desailab/home/orig_data/SID/NY_SID/2006/";       
  libname orig2007 "/gpfs/data/desailab/home/orig_data/SID/NY_SID/2007/";     
  libname orig2008 "/gpfs/data/desailab/home/orig_data/SID/NY_SID/2008/";                                                                                    
  libname orig2009 "/gpfs/data/desailab/home/orig_data/SID/NY_SID/2009/";
  libname orig2010 "/gpfs/data/desailab/home/orig_data/SID/NY_SID/2010/";
  libname orig2011 "/gpfs/data/desailab/home/orig_data/SID/NY_SID/2011/";
  libname orig2012 "/gpfs/data/desailab/home/orig_data/SID/NY_SID/2012/";
  
  %LET samp = ;  
  
*****************************************;
*Import revisit variables ;
* Submit to app;
******************************************;
* Examine what proportion of the time the revisit variable is missing by year; 
	PROC SQL; 
		CREATE TABLE sid.ny_sid_revisitvar 
		AS SELECT UNIQUE
		year, 
		SUM(CASE WHEN VisitLink is Missing then 1 else 0 end) as visitlink_miss, count(*) as numadm, 
		SUM(CASE WHEN VisitLink is Missing then 1 else 0 end)/count(*) as pct_miss 
		FROM sid.ny_sid_0612 
		GROUP BY (year);
		QUIT;
		
* read in days to events data sets;
	%MACRO read_daystoevent(st, yr);
		proc import datafile="/gpfs/data/desailab/home/orig_data/SID/&st._SID/&yr./&st._&yr._daystoevent.csv" 
		out=&st._&yr._daystoevent_temp dbms=csv replace; getnames = yes;
		run;
	
	PROC SQL; 
		CREATE TABLE orig&yr..&st._&yr._daystoevent
		AS SELECT 
		KEY, _visitlink as visitlink, 
		_daystoevent as daystoevent
		FROM &st._&yr._daystoevent_temp;
		QUIT;	
		
	PROC SQL; 
		CREATE TABLE sid.core_ahal_&yr.&samp._wrevisit
		AS SELECT
		a.*, b.* 
		FROM 
		sid.core_ahal_&yr.&samp. a 
		LEFT JOIN 
		orig&yr..&st._&yr._daystoevent b on a.KEY=b.KEY ;
		QUIT;
		
	%MEND; 
	
	%read_daystoevent(NY, 2006);
	%read_daystoevent(NY, 2007);
	%read_daystoevent(NY, 2008);
	


* Create files payer indicators; 
	PROC SQL; 
		CREATE TABLE sid.ny_sid_0612 
		AS SELECT 
		*, 
		CASE WHEN PAY1 = 2   THEN 1 ELSE 0 END AS pay_mcaid,
		CASE WHEN (PAY1 = 1 AND PAY2 = 2) OR (PAY1 = 2 AND PAY2 = 1 ) THEN 1 ELSE 0 END AS pay_dual,
		CASE WHEN PAY1 = 1   THEN 1 ELSE 0 END AS pay_mcare,
		CASE WHEN PAY1 = 3   THEN 1 ELSE 0 END AS pay_pvt,
		CASE WHEN PAY1 = 4 THEN 1 ELSE 0 END AS pay_self,
		CASE WHEN PAY1 = 5 THEN 1 ELSE 0 END AS pay_nochrg
		FROM sid.ny_sid_0612; 
		QUIT; 
	
  sid.ny_sid_0612&samp