/*******************************************************************            
*   Export appended SID data to 
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

PROC EXPORT DATA =sid.ny_sid_0612&samp._supp 
		OUTFILE = "/gpfs/data/desailab/home/ny_mergers/data_sidclean/sid_work/ny_sid_0612&samp._supp.dta"; 
		RUN;