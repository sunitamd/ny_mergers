/*******************************************************************            
*   Merge 2009 and 2011 data sets - AHA to hospital                                  
*******************************************************************/            
  
  libname sid "/gpfs/data/desailab/home/ny_mergers/data_sidclean/sid_work";                 
  libname orig09 "/gpfs/data/desailab/home/orig_data/SID/NY_SID/2009/";     
  libname orig11 "/gpfs/data/desailab/home/orig_data/SID/NY_SID/2011/";                                                                                    

%LET samp = ;  
* Merge 2009 and 2011 data sets 

%MACRO aha_core(yr);
PROC SQL; 
	CREATE TABLE sid.core_ahal_20&yr.
	AS SELECT 
		a.*,
		b.*
	FROM 
		orig&yr..ny_sidc_20&yr._core a LEFT JOIN 
		orig&yr..ny_sidc_20&yr._ahal b on a.dshospid = b.dshospid;
	QUIT;
	
%MEND; 

%aha_core(09);
%aha_core(11);

