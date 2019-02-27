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
  
 	
%MACRO merge_suppfiles(st, yr);
	PROC SQL; 
		CREATE TABLE sid.core_ahal_&yr.&samp._wsupp
		AS SELECT
		a.*, b.*, c.* 
		FROM 
		sid.core_ahal_&yr.&samp._wrevisit a 
		LEFT JOIN 
		orig&yr..&st._sid_&yr._severity b on a.KEY=b.KEY 
		LEFT JOIN
		orig&yr..&st._sid_&yr._dx_pr_grps c on a.KEY=c.KEY;
		QUIT;
		


%MEND; 

%merge_suppfiles(NY, 2006); 
%merge_suppfiles(NY, 2007);
%merge_suppfiles(NY, 2008);

%MACRO merge_suppfiles0912(st, yr);
	PROC SQL; 
		CREATE TABLE sid.core_ahal_&yr.&samp._wsupp
		AS SELECT
		a.*, b.*, c.* 
		FROM 
		sid.core_ahal_&yr.&samp. a 
		LEFT JOIN 
		orig&yr..&st._sid_&yr._severity b on a.KEY=b.KEY 
		LEFT JOIN
		orig&yr..&st._sid_&yr._dx_pr_grps c on a.KEY=c.KEY;
		QUIT;
		
		
  
%MEND; 

%merge_suppfiles0912(NY, 2009);
%merge_suppfiles0912(NY, 2010);
%merge_suppfiles0912(NY, 2011);
%merge_suppfiles0912(NY, 2012);

		
	DATA sid.ny_sid_0612&samp._supp;
	SET	sid.core_ahal_2006&samp._wsupp
		sid.core_ahal_2007&samp._wsupp
		sid.core_ahal_2008&samp._wsupp
		sid.core_ahal_2009&samp._wsupp
		sid.core_ahal_2010&samp._wsupp
		sid.core_ahal_2011&samp._wsupp
		sid.core_ahal_2012&samp._wsupp;
	RUN;

		
