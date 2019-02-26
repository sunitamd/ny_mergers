************************************************************************
* Combining AHA Addition and Deletion Data
* AHA Documentation, 2000-2014
* September 29, 2018
* Sarah Friedman
************************************************************************


/////////////////   2000   /////////////////////////////////

* Registered Additions
clear
import excel "C:\Users\Sarah Friedman\Documents\GitHub\Hospital_Mergers\Data\add_delete\aha_add_del_2000.xlsx", sheet("Reg Add")
rename A id
rename B name
rename C city
rename D state
rename E add_reason
drop in 1
drop if id==""
gen year = 2000
gen registered = 1
gen addition = 1
save "C:\Users\Sarah Friedman\Documents\GitHub\Hospital_Mergers\Data\add_delete\2000_reg_add.dta", replace

* Non-registered Additions
clear
import excel "C:\Users\Sarah Friedman\Documents\GitHub\Hospital_Mergers\Data\add_delete\aha_add_del_2000.xlsx", sheet("Non Reg Add")
rename A id
rename B name
rename C city
rename D state
rename E add_reason
drop in 1
drop if id==""
gen year = 2000
gen registered = 0
gen addition = 1
save "C:\Users\Sarah Friedman\Documents\GitHub\Hospital_Mergers\Data\add_delete\2000_nonreg_add.dta", replace

* Registerd Deletions
clear
import excel "C:\Users\Sarah Friedman\Documents\GitHub\Hospital_Mergers\Data\add_delete\aha_add_del_2000.xlsx", sheet("Reg Del")
rename A id
rename B name
rename C city
rename D state
rename E add_reason
drop in 1
drop if id==""
gen year = 2000
gen registered = 1
gen deletion = 1
save "C:\Users\Sarah Friedman\Documents\GitHub\Hospital_Mergers\Data\add_delete\2000_reg_del.dta", replace

* Non-registered Deletions
clear
import excel "C:\Users\Sarah Friedman\Documents\GitHub\Hospital_Mergers\Data\add_delete\aha_add_del_2000.xlsx", sheet("Non Reg Del")
rename A id
rename B name
rename C city
rename D state
rename E add_reason
drop in 1
drop if id==""
gen year = 2000
gen registered = 0
gen deletion = 1
save "C:\Users\Sarah Friedman\Documents\GitHub\Hospital_Mergers\Data\add_delete\2000_nonreg_del.dta", replace


/////////////////   2001   /////////////////////////////////

* Registered Additions
clear
import excel "C:\Users\Sarah Friedman\Documents\GitHub\Hospital_Mergers\Data\add_delete\2000_vs_2001_Reconcilationi.xls", sheet("2001 reg add")
rename A id
rename B name
rename C city
rename D state
rename E add_reason
drop in 1/4
drop if id==""
gen year = 2001
gen registered = 1
gen addition = 1
save "C:\Users\Sarah Friedman\Documents\GitHub\Hospital_Mergers\Data\add_delete\2001_reg_add.dta", replace

* Non-registered Additions
clear
import excel "C:\Users\Sarah Friedman\Documents\GitHub\Hospital_Mergers\Data\add_delete\2000_vs_2001_Reconcilationi.xls", sheet("2001 non-reg add")
rename A id
rename B name
rename C city
rename D state
rename E add_reason
drop in 1/4
drop if id==""
gen year = 2001
gen registered = 0
gen addition = 1
save "C:\Users\Sarah Friedman\Documents\GitHub\Hospital_Mergers\Data\add_delete\2001_nonreg_add.dta", replace

* Registerd Deletions
clear
import excel "C:\Users\Sarah Friedman\Documents\GitHub\Hospital_Mergers\Data\add_delete\2000_vs_2001_Reconcilationi.xls", sheet("2001 reg del")
rename A id
rename B name
rename C city
rename D state
rename E add_reason
drop in 1/4
drop if id==""
gen year = 2001
gen registered = 1
gen deletion = 1
drop F-IV
save "C:\Users\Sarah Friedman\Documents\GitHub\Hospital_Mergers\Data\add_delete\2001_reg_del.dta", replace

* Non-registered Deletions
clear
import excel "C:\Users\Sarah Friedman\Documents\GitHub\Hospital_Mergers\Data\add_delete\2000_vs_2001_Reconcilationi.xls", sheet("2001 non-reg del")
rename A id
rename B name
rename C city
rename D state
rename E add_reason
drop in 1/2
drop if id==""
drop F-IV
gen year = 2001
gen registered = 0
gen deletion = 1
save "C:\Users\Sarah Friedman\Documents\GitHub\Hospital_Mergers\Data\add_delete\2001_nonreg_del.dta", replace


/////////////////   2002   /////////////////////////////////

* Registered Additions
clear
import excel "C:\Users\Sarah Friedman\Documents\GitHub\Hospital_Mergers\Data\add_delete\2002_additions.xls", sheet("REG ADDITIONS")
drop B
rename A id
rename C name
rename D city
rename E state
rename F add_reason
drop in 1
drop if id==""
gen year = 2002
gen registered = 1
gen addition = 1
save "C:\Users\Sarah Friedman\Documents\GitHub\Hospital_Mergers\Data\add_delete\2002_reg_add.dta", replace

* Non-registered Additions
clear
import excel "C:\Users\Sarah Friedman\Documents\GitHub\Hospital_Mergers\Data\add_delete\2002_additions.xls", sheet("NONREG ADDITIONS")
drop B
rename A id
rename C name
rename D city
rename E state
rename F add_reason
drop in 1
drop if id==""
gen year = 2002
gen registered = 0
gen addition = 1
save "C:\Users\Sarah Friedman\Documents\GitHub\Hospital_Mergers\Data\add_delete\2002_nonreg_add.dta", replace

* Registerd Deletions
clear
import excel "C:\Users\Sarah Friedman\Documents\GitHub\Hospital_Mergers\Data\add_delete\2002_deletions.xls", sheet("REG DELETIONS")
drop B
rename A id
rename C name
rename D city
rename E state
rename F add_reason
drop in 1
drop if id==""
gen year = 2002
gen registered = 1
gen deletion = 1
save "C:\Users\Sarah Friedman\Documents\GitHub\Hospital_Mergers\Data\add_delete\2002_reg_del.dta", replace

* Non-registered Deletions
clear
import excel "C:\Users\Sarah Friedman\Documents\GitHub\Hospital_Mergers\Data\add_delete\2002_deletions.xls", sheet("NONREG DELETIONS")
drop B
rename A id
rename C name
rename D city
rename E state
rename F add_reason
drop in 1
gen year = 2002
gen registered = 0
gen deletion = 1
save "C:\Users\Sarah Friedman\Documents\GitHub\Hospital_Mergers\Data\add_delete\2002_nonreg_del.dta", replace


/////////////////   2003   /////////////////////////////////

* Registered Additions
clear
import excel "C:\Users\Sarah Friedman\Documents\GitHub\Hospital_Mergers\Data\add_delete\tab4regadditions_2003.xls", sheet("Registered Additions")
rename A id
rename B name
rename C city
rename D state
rename E add_reason
drop in 1/3
drop F-H
drop if id==""
gen year = 2003
gen registered = 1
gen addition = 1
save "C:\Users\Sarah Friedman\Documents\GitHub\Hospital_Mergers\Data\add_delete\2003_reg_add.dta", replace

* Non-registered Additions
clear
import excel "C:\Users\Sarah Friedman\Documents\GitHub\Hospital_Mergers\Data\add_delete\tab4regadditions_2003.xls", sheet("Non-registered ")
drop A G H F
rename B id
rename C name
rename D city
rename E state
rename I add_reason
drop in 1/3
drop if id==""
gen year = 2003
gen registered = 0
gen addition = 1
save "C:\Users\Sarah Friedman\Documents\GitHub\Hospital_Mergers\Data\add_delete\2003_nonreg_add.dta", replace

* Registerd Deletions
clear
import excel "C:\Users\Sarah Friedman\Documents\GitHub\Hospital_Mergers\Data\add_delete\tab4regdeletions_2003.xls", sheet("Registered Deletions")
drop A C G-L
rename B id
rename D name
rename E city
rename F state
rename M add_reason
drop in 1/3
drop if id==""
gen year = 2003
gen registered = 1
gen deletion = 1
save "C:\Users\Sarah Friedman\Documents\GitHub\Hospital_Mergers\Data\add_delete\2003_reg_del.dta", replace

* Non-registered Deletions
clear
import excel "C:\Users\Sarah Friedman\Documents\GitHub\Hospital_Mergers\Data\add_delete\tab4regdeletions_2003.xls", sheet("Nonregistered Deletions")
drop A D H
rename B id
rename C name
rename E city
rename F state
rename G add_reason
drop in 1/3
gen year = 2003
gen registered = 0
gen deletion = 1
save "C:\Users\Sarah Friedman\Documents\GitHub\Hospital_Mergers\Data\add_delete\2003_nonreg_del.dta", replace



/////////////////   2004   /////////////////////////////////

* Registered Additions
clear
import excel "C:\Users\Sarah Friedman\Documents\GitHub\Hospital_Mergers\Data\add_delete\2003_VS_2004_ADDITIONS.xls", sheet("2004 Registered Additions")
rename A id
rename B name
rename C city
rename D state
rename E add_reason
drop in 1
drop if id==""
gen year = 2004
gen registered = 1
gen addition = 1
save "C:\Users\Sarah Friedman\Documents\GitHub\Hospital_Mergers\Data\add_delete\2004_reg_add.dta", replace

* Non-registered Additions
clear
import excel "C:\Users\Sarah Friedman\Documents\GitHub\Hospital_Mergers\Data\add_delete\2003_VS_2004_ADDITIONS.xls", sheet("2004 Nonregistered Additions")
rename A id
rename B name
rename C city
rename D state
rename E add_reason
drop in 1
drop if id==""
gen year = 2004
gen registered = 0
gen addition = 1
save "C:\Users\Sarah Friedman\Documents\GitHub\Hospital_Mergers\Data\add_delete\2004_nonreg_add.dta", replace

* Registerd Deletions
clear
import excel "C:\Users\Sarah Friedman\Documents\GitHub\Hospital_Mergers\Data\add_delete\2003_VS_2004_DELETIONS.xls", sheet("2003 Registered Deletions")
rename A id
rename B name
rename C city
rename D state
rename E add_reason
drop in 1
drop if id==""
gen year = 2004
gen registered = 1
gen deletion = 1
save "C:\Users\Sarah Friedman\Documents\GitHub\Hospital_Mergers\Data\add_delete\2004_reg_del.dta", replace

* Non-registered Deletions
clear
import excel "C:\Users\Sarah Friedman\Documents\GitHub\Hospital_Mergers\Data\add_delete\2003_VS_2004_DELETIONS.xls", sheet("2003 Nonregistered Deletions")
rename A id
rename B name
rename C city
rename D state
rename E add_reason
gen year = 2004
gen registered = 0
gen deletion = 1
save "C:\Users\Sarah Friedman\Documents\GitHub\Hospital_Mergers\Data\add_delete\2004_nonreg_del.dta", replace



/////////////////   2005   /////////////////////////////////

* Registered Additions
clear
import excel "C:\Users\Sarah Friedman\Documents\GitHub\Hospital_Mergers\Data\add_delete\FINAL_ADDITIONS_2005.xls", sheet("REG ADDITIONS")
drop A
rename B id
rename C name
rename D city
rename E state
rename F add_reason
drop in 1
drop if id==""
gen year = 2005
gen registered = 1
gen addition = 1
save "C:\Users\Sarah Friedman\Documents\GitHub\Hospital_Mergers\Data\add_delete\2005_reg_add.dta", replace

* Non-registered Additions
clear
import excel "C:\Users\Sarah Friedman\Documents\GitHub\Hospital_Mergers\Data\add_delete\FINAL_ADDITIONS_2005.xls", sheet("NONREG ADDITIONS")
drop A
rename B id
rename C name
rename D city
rename E state
rename F add_reason
drop in 1
drop if id==""
gen year = 2005
gen registered = 0
gen addition = 1
save "C:\Users\Sarah Friedman\Documents\GitHub\Hospital_Mergers\Data\add_delete\2005_nonreg_add.dta", replace

* Registerd Deletions
clear
import excel "C:\Users\Sarah Friedman\Documents\GitHub\Hospital_Mergers\Data\add_delete\FINAL_DELETIONS_2005.xls", sheet("REGISTERED DELETIONS")
drop A
rename B id
rename C name
rename D city
rename E state
rename F add_reason
drop in 1
drop if id==""
gen year = 2005
gen registered = 1
gen deletion = 1
save "C:\Users\Sarah Friedman\Documents\GitHub\Hospital_Mergers\Data\add_delete\2005_reg_del.dta", replace

* Non-registered Deletions
clear
import excel "C:\Users\Sarah Friedman\Documents\GitHub\Hospital_Mergers\Data\add_delete\FINAL_DELETIONS_2005.xls", sheet("NONREG DELETIONS")
drop A
rename B id
rename C name
rename D city
rename E state
rename F add_reason
drop in 1
drop if id==""
gen year = 2005
gen registered = 0
gen deletion = 1
save "C:\Users\Sarah Friedman\Documents\GitHub\Hospital_Mergers\Data\add_delete\2005_nonreg_del.dta", replace


/////////////////   2006   /////////////////////////////////

* Registered Additions
clear
import excel "C:\Users\Sarah Friedman\Documents\GitHub\Hospital_Mergers\Data\add_delete\2006Reconciliation.xls", sheet("RegAdditions")
rename A id
rename B name
rename C city
rename D state
rename E add_reason
drop in 1
drop if id==""
gen year = 2006
gen registered = 1
gen addition = 1
save "C:\Users\Sarah Friedman\Documents\GitHub\Hospital_Mergers\Data\add_delete\2006_reg_add.dta", replace

* Non-registered Additions
clear
import excel "C:\Users\Sarah Friedman\Documents\GitHub\Hospital_Mergers\Data\add_delete\2006Reconciliation.xls", sheet("NonReg Additions")
rename A id
rename B name
rename C city
rename D state
rename E add_reason
drop in 1
drop if id==""
gen year = 2006
gen registered = 0
gen addition = 1
save "C:\Users\Sarah Friedman\Documents\GitHub\Hospital_Mergers\Data\add_delete\2006_nonreg_add.dta", replace

* Registered Deletions
clear
import excel "C:\Users\Sarah Friedman\Documents\GitHub\Hospital_Mergers\Data\add_delete\2006Reconciliation.xls", sheet("RegDeletions")
rename A id
rename B name
rename C city
rename D state
rename E add_reason
drop in 1
drop if id==""
gen year = 2006
gen registered = 1
gen deletion = 1
save "C:\Users\Sarah Friedman\Documents\GitHub\Hospital_Mergers\Data\add_delete\2006_reg_del.dta", replace

* Non - registered Deletions
clear
import excel "C:\Users\Sarah Friedman\Documents\GitHub\Hospital_Mergers\Data\add_delete\2006Reconciliation.xls", sheet("NonRegDel")
rename A id
rename B name
rename C city
rename D state
rename E add_reason
drop in 1
drop if id==""
gen year = 2006
gen registered = 0
gen deletion = 1
save "C:\Users\Sarah Friedman\Documents\GitHub\Hospital_Mergers\Data\add_delete\2006_nonreg_del.dta", replace


/////////////////   2007   /////////////////////////////////

***** DOUBLE CHECK THIS IS THE RIGHT DATA  ******
* Registered Additions
clear
import excel "C:\Users\Sarah Friedman\Documents\GitHub\Hospital_Mergers\Data\add_delete\2007Summaries.xls", sheet("2007REG ADDITIONS")
rename A id
rename B name
rename C city
rename D state
rename E add_reason
drop in 1
drop if id==""
gen year = 2007
gen registered = 1
gen addition = 1
save "C:\Users\Sarah Friedman\Documents\GitHub\Hospital_Mergers\Data\add_delete\2007_reg_add.dta", replace


* Non-registered Additions
clear
import excel "C:\Users\Sarah Friedman\Documents\GitHub\Hospital_Mergers\Data\add_delete\2007Summaries.xls", sheet("2007 NONREGISTERED ADDITIONS")
rename A id
rename B name
rename C city
rename D state
rename E add_reason
drop in 1
drop if id==""
gen year = 2007
gen registered = 0
gen addition = 1
save "C:\Users\Sarah Friedman\Documents\GitHub\Hospital_Mergers\Data\add_delete\2007_nonreg_add.dta", replace

* Registered Deletions
clear
import excel "C:\Users\Sarah Friedman\Documents\GitHub\Hospital_Mergers\Data\add_delete\2007Summaries.xls", sheet("2007REG DELETIONS")
rename A id
rename B name
rename C city
rename D state
rename E add_reason
drop in 1
drop if id==""
gen year = 2007
gen registered = 1
gen deletion = 1
save "C:\Users\Sarah Friedman\Documents\GitHub\Hospital_Mergers\Data\add_delete\2007_reg_del.dta", replace

* Non - registered Deletions
clear
import excel "C:\Users\Sarah Friedman\Documents\GitHub\Hospital_Mergers\Data\add_delete\2007Summaries.xls", sheet("2007 NONREGISTERED DELETIONS")
rename A id
rename B name
rename C city
rename D state
rename E add_reason
drop in 1
drop if id==""
gen year = 2007
gen registered = 0
gen deletion = 1
save "C:\Users\Sarah Friedman\Documents\GitHub\Hospital_Mergers\Data\add_delete\2007_nonreg_del.dta", replace


/////////////////   2008   /////////////////////////////////

* Registered Additions
clear
import excel "C:\Users\Sarah Friedman\Documents\GitHub\Hospital_Mergers\Data\add_delete\2007vs2008Final.xls", sheet("Registered Additions")
rename A id
rename B name
rename C city
rename D state
rename E add_reason
drop in 1
drop if id==""
gen year = 2008
gen registered = 1
gen addition = 1
save "C:\Users\Sarah Friedman\Documents\GitHub\Hospital_Mergers\Data\add_delete\2008_reg_add.dta", replace

* Non-registered Additions
clear
import excel "C:\Users\Sarah Friedman\Documents\GitHub\Hospital_Mergers\Data\add_delete\2007vs2008Final.xls", sheet("Nonregistered Additions")
rename A id
rename B name
rename C city
rename D state
rename E add_reason
drop in 1
drop if id==""
gen year = 2008
gen registered = 0
gen addition = 1
save "C:\Users\Sarah Friedman\Documents\GitHub\Hospital_Mergers\Data\add_delete\2008_nonreg_add.dta", replace

* Registered Deletions
clear
import excel "C:\Users\Sarah Friedman\Documents\GitHub\Hospital_Mergers\Data\add_delete\2007vs2008Final.xls", sheet("Registered Deletions")
rename A id
rename B name
rename C city
rename D state
rename E add_reason
drop in 1
drop if id==""
gen year = 2008
gen registered = 1
gen deletion = 1
save "C:\Users\Sarah Friedman\Documents\GitHub\Hospital_Mergers\Data\add_delete\2008_reg_del.dta", replace

* Non - registered Deletions
clear
import excel "C:\Users\Sarah Friedman\Documents\GitHub\Hospital_Mergers\Data\add_delete\2007vs2008Final.xls", sheet("Nonregistered Deletions")
rename A id
rename B name
rename C city
rename D state
rename E add_reason
drop in 1
drop if id==""
gen year = 2008
gen registered = 0
gen deletion = 1
save "C:\Users\Sarah Friedman\Documents\GitHub\Hospital_Mergers\Data\add_delete\2008_nonreg_del.dta", replace


/////////////////   2009   /////////////////////////////////

/* Pulled from 2009ASDBSummaryofChangessearchable.pdf */

* Registered Additions
clear
import excel "C:\Users\Sarah Friedman\Documents\GitHub\Hospital_Mergers\Data\add_delete\aha_2009_add_del_sf.xlsx", sheet("reg add")
rename A id
rename B name
rename C city
rename D state
rename E add_reason
drop F-M
drop in 1
drop if id==""
gen year = 2009
gen registered = 1
gen addition = 1
save "C:\Users\Sarah Friedman\Documents\GitHub\Hospital_Mergers\Data\add_delete\2009_reg_add.dta", replace

* Non-registered Additions
clear
import excel "C:\Users\Sarah Friedman\Documents\GitHub\Hospital_Mergers\Data\add_delete\aha_2009_add_del_sf.xlsx", sheet("nonreg add")
rename A id
rename B name
rename C city
rename D state
rename E add_reason
drop in 1
drop if id==""
gen year = 2009
gen registered = 0
gen addition = 1
save "C:\Users\Sarah Friedman\Documents\GitHub\Hospital_Mergers\Data\add_delete\2009_nonreg_add.dta", replace

* Registered Deletions
clear
import excel "C:\Users\Sarah Friedman\Documents\GitHub\Hospital_Mergers\Data\add_delete\aha_2009_add_del_sf.xlsx", sheet("reg del")
rename A id
rename B name
rename C city
rename D state
rename E add_reason
drop in 1
drop if id==""
gen year = 2009
gen registered = 1
gen deletion = 1
save "C:\Users\Sarah Friedman\Documents\GitHub\Hospital_Mergers\Data\add_delete\2009_reg_del.dta", replace

* Non - registered Deletions
clear
import excel "C:\Users\Sarah Friedman\Documents\GitHub\Hospital_Mergers\Data\add_delete\aha_2009_add_del_sf.xlsx", sheet("nonreg del")
rename A id
rename B name
rename C city
rename D state
rename E add_reason
drop F-N
drop in 1
drop if id==""
gen year = 2009
gen registered = 0
gen deletion = 1
save "C:\Users\Sarah Friedman\Documents\GitHub\Hospital_Mergers\Data\add_delete\2009_nonreg_del.dta", replace


/////////////////   2010   /////////////////////////////////

* Registered Additions
clear
import excel "C:\Users\Sarah Friedman\Documents\GitHub\Hospital_Mergers\Data\add_delete\adds_dels_merges_2010.xlsx", sheet("Reg Add")
rename A id
rename B name
rename C city
rename D state
rename E add_reason
drop in 1
drop if id==""
gen year = 2010
gen registered = 1
gen addition = 1
save "C:\Users\Sarah Friedman\Documents\GitHub\Hospital_Mergers\Data\add_delete\2010_reg_add.dta", replace

* Non-registered Additions
clear
import excel "C:\Users\Sarah Friedman\Documents\GitHub\Hospital_Mergers\Data\add_delete\adds_dels_merges_2010.xlsx", sheet("non Add")
rename A id
rename B name
rename C city
rename D state
rename E add_reason
drop in 1
drop if id==""
gen year = 2010
gen registered = 0
gen addition = 1
save "C:\Users\Sarah Friedman\Documents\GitHub\Hospital_Mergers\Data\add_delete\2010_nonreg_add.dta", replace

* Registered Deletions
clear
import excel "C:\Users\Sarah Friedman\Documents\GitHub\Hospital_Mergers\Data\add_delete\adds_dels_merges_2010.xlsx", sheet("Reg Del")
rename A id
rename B name
rename C city
rename D state
rename E add_reason
drop in 1
drop if id==""
gen year = 2010
gen registered = 1
gen deletion = 1
save "C:\Users\Sarah Friedman\Documents\GitHub\Hospital_Mergers\Data\add_delete\2010_reg_del.dta", replace

* Non - registered Deletions
clear
import excel "C:\Users\Sarah Friedman\Documents\GitHub\Hospital_Mergers\Data\add_delete\adds_dels_merges_2010.xlsx", sheet("non Del ")
rename A id
rename B name
rename C city
rename D state
rename E add_reason
drop in 1
drop if id==""
gen year = 2010
gen registered = 0
gen deletion = 1
save "C:\Users\Sarah Friedman\Documents\GitHub\Hospital_Mergers\Data\add_delete\2010_nonreg_del.dta", replace


/////////////////   2011  /////////////////////////////////

* Taken from AHAAnnualSurveyDatabaseFY2011SOC.docx

* Registered Additions
clear
import excel "C:\Users\Sarah Friedman\Documents\GitHub\Hospital_Mergers\Data\add_delete\aha_add_del_2011.xlsx", sheet("Reg Add")
rename A id
rename B name
rename C city
rename D state
rename E add_reason
drop in 1
drop if id==""
gen year = 2011
gen registered = 1
gen addition = 1
save "C:\Users\Sarah Friedman\Documents\GitHub\Hospital_Mergers\Data\add_delete\2011_reg_add.dta", replace

* Non-registered Additions
clear
import excel "C:\Users\Sarah Friedman\Documents\GitHub\Hospital_Mergers\Data\add_delete\aha_add_del_2011.xlsx", sheet("Non Reg Add")
rename A id
rename B name
rename C city
rename D state
rename E add_reason
drop in 1
drop if id==""
gen year = 2011
gen registered = 0
gen addition = 1
save "C:\Users\Sarah Friedman\Documents\GitHub\Hospital_Mergers\Data\add_delete\2011_nonreg_add.dta", replace

* Registered Deletions
clear
import excel "C:\Users\Sarah Friedman\Documents\GitHub\Hospital_Mergers\Data\add_delete\aha_add_del_2011.xlsx", sheet("Reg Del")

rename A id
rename B name
rename C city
rename D state
rename E add_reason
drop in 1
drop if id==""
gen year = 2011
gen registered = 1
gen deletion = 1
save "C:\Users\Sarah Friedman\Documents\GitHub\Hospital_Mergers\Data\add_delete\2011_reg_del.dta", replace

* Non - registered Deletions
clear
import excel "C:\Users\Sarah Friedman\Documents\GitHub\Hospital_Mergers\Data\add_delete\aha_add_del_2011.xlsx", sheet("Non Reg Del")
rename A id
rename B name
rename C city
rename D state
rename E add_reason
drop in 1
drop if id==""
gen year = 2011
gen registered = 0
gen deletion = 1
save "C:\Users\Sarah Friedman\Documents\GitHub\Hospital_Mergers\Data\add_delete\2011_nonreg_del.dta", replace


/////////////////   2012  /////////////////////////////////


* Registered Additions
clear
import excel "C:\Users\Sarah Friedman\Documents\GitHub\Hospital_Mergers\Data\add_delete\Landscape_Changes_in_US_Hospitals_FY2012.pdf.xlsx", sheet("Reg Add")
rename A id
rename B name
rename C city
rename D state
rename E add_reason
drop in 1
drop if id==""
gen year = 2012
gen registered = 1
gen addition = 1
save "C:\Users\Sarah Friedman\Documents\GitHub\Hospital_Mergers\Data\add_delete\2012_reg_add.dta", replace

* Non-registered Additions
clear
import excel "C:\Users\Sarah Friedman\Documents\GitHub\Hospital_Mergers\Data\add_delete\Landscape_Changes_in_US_Hospitals_FY2012.pdf.xlsx", sheet("Non Reg Add")
rename A id
rename B name
rename C city
rename D state
rename E add_reason
drop in 1
drop if id==""
gen year = 2012
gen registered = 0
gen addition = 1
save "C:\Users\Sarah Friedman\Documents\GitHub\Hospital_Mergers\Data\add_delete\2012_nonreg_add.dta", replace

* Registered Deletions
clear
import excel "C:\Users\Sarah Friedman\Documents\GitHub\Hospital_Mergers\Data\add_delete\Landscape_Changes_in_US_Hospitals_FY2012.pdf.xlsx", sheet("Reg Del")
rename A id
rename B name
rename C city
rename D state
rename E add_reason
drop in 1
drop if id==""
gen year = 2012
gen registered = 1
gen deletion = 1
save "C:\Users\Sarah Friedman\Documents\GitHub\Hospital_Mergers\Data\add_delete\2012_reg_del.dta", replace

* Non - registered Deletions
clear
import excel "C:\Users\Sarah Friedman\Documents\GitHub\Hospital_Mergers\Data\add_delete\Landscape_Changes_in_US_Hospitals_FY2012.pdf.xlsx", sheet("Non Reg Del")
rename A id
rename B name
rename C city
rename D state
rename E add_reason
drop in 1
drop if id==""
gen year = 2012
gen registered = 0
gen deletion = 1
save "C:\Users\Sarah Friedman\Documents\GitHub\Hospital_Mergers\Data\add_delete\2012_nonreg_del.dta", replace


/////////////////   2013  /////////////////////////////////


* Registered Additions
clear
import excel "C:\Users\Sarah Friedman\Documents\GitHub\Hospital_Mergers\Data\add_delete\Landscape_Changes_in_U_S_Hospitals_2013.xlsx", sheet("Reg Add")
rename A id
rename B name
rename C city
rename D state
rename E add_reason
drop in 1
drop if id==""
gen year = 2013
gen registered = 1
gen addition = 1
save "C:\Users\Sarah Friedman\Documents\GitHub\Hospital_Mergers\Data\add_delete\2013_reg_add.dta", replace

* Non-registered Additions
clear
import excel "C:\Users\Sarah Friedman\Documents\GitHub\Hospital_Mergers\Data\add_delete\Landscape_Changes_in_U_S_Hospitals_2013.xlsx", sheet("Non Reg Add")
rename A id
rename B name
rename C city
rename D state
rename E add_reason
drop in 1
drop if id==""
gen year = 2013
gen registered = 0
gen addition = 1
save "C:\Users\Sarah Friedman\Documents\GitHub\Hospital_Mergers\Data\add_delete\2013_nonreg_add.dta", replace

* Registered Deletions
clear
import excel "C:\Users\Sarah Friedman\Documents\GitHub\Hospital_Mergers\Data\add_delete\Landscape_Changes_in_U_S_Hospitals_2013.xlsx", sheet("Reg Del")
rename A id
rename B name
rename C city
rename D state
rename E add_reason
drop in 1
drop if id==""
gen year = 2013
gen registered = 1
gen deletion = 1
save "C:\Users\Sarah Friedman\Documents\GitHub\Hospital_Mergers\Data\add_delete\2013_reg_del.dta", replace

* Non - registered Deletions
clear
import excel "C:\Users\Sarah Friedman\Documents\GitHub\Hospital_Mergers\Data\add_delete\Landscape_Changes_in_U_S_Hospitals_2013.xlsx", sheet("Non Reg Del")
rename A id
rename B name
rename C city
rename D state
rename E add_reason
drop in 1
drop if id==""
gen year = 2013
gen registered = 0
gen deletion = 1
save "C:\Users\Sarah Friedman\Documents\GitHub\Hospital_Mergers\Data\add_delete\2013_nonreg_del.dta", replace


/////////////////   2014  /////////////////////////////////


* Registered Additions
clear
import excel "C:\Users\Sarah Friedman\Documents\GitHub\Hospital_Mergers\Data\add_delete\Landscape_Changes_in_U_S__Hospitals_FY2014.xlsx", sheet("Reg Add")
rename A id
rename B name
rename C city
rename D state
rename E add_reason
drop in 1
drop if id==""
gen year = 2014
gen registered = 1
gen addition = 1
save "C:\Users\Sarah Friedman\Documents\GitHub\Hospital_Mergers\Data\add_delete\2014_reg_add.dta", replace

* Non-registered Additions
clear
import excel "C:\Users\Sarah Friedman\Documents\GitHub\Hospital_Mergers\Data\add_delete\Landscape_Changes_in_U_S__Hospitals_FY2014.xlsx", sheet("Non Reg Add")
rename A id
rename B name
rename C city
rename D state
rename E add_reason
drop in 1
drop if id==""
gen year = 2014
gen registered = 0
gen addition = 1
save "C:\Users\Sarah Friedman\Documents\GitHub\Hospital_Mergers\Data\add_delete\2014_nonreg_add.dta", replace

* Registered Deletions
clear
import excel "C:\Users\Sarah Friedman\Documents\GitHub\Hospital_Mergers\Data\add_delete\Landscape_Changes_in_U_S__Hospitals_FY2014.xlsx", sheet("Reg Del")
rename A id
rename B name
rename C city
rename D state
rename E add_reason
drop in 1
drop if id==""
gen year = 2014
gen registered = 1
gen deletion = 1
save "C:\Users\Sarah Friedman\Documents\GitHub\Hospital_Mergers\Data\add_delete\2014_reg_del.dta", replace

* Non - registered Deletions
clear
import excel "C:\Users\Sarah Friedman\Documents\GitHub\Hospital_Mergers\Data\add_delete\Landscape_Changes_in_U_S__Hospitals_FY2014.xlsx", sheet("Non Reg Del")
rename A id
rename B name
rename C city
rename D state
rename E add_reason
drop in 1
drop if id==""
gen year = 2014
gen registered = 0
gen deletion = 1
save "C:\Users\Sarah Friedman\Documents\GitHub\Hospital_Mergers\Data\add_delete\2014_nonreg_del.dta", replace


/////////////////   2015 - DO NOT HAVE  /////////////////////////////////
/////////////////   2016 - DO NOT HAVE  /////////////////////////////////



///////////// APPEND ADDITIONS //////////////////
clear
use "C:\Users\Sarah Friedman\Dropbox\Sarah-Sunita mergers project\Hospital_Mergers\Data\add_delete\2000_reg_add.dta", replace
append using "C:\Users\Sarah Friedman\Dropbox\Sarah-Sunita mergers project\Hospital_Mergers\Data\add_delete\2001_reg_add.dta"
append using "C:\Users\Sarah Friedman\Dropbox\Sarah-Sunita mergers project\Hospital_Mergers\Data\add_delete\2002_reg_add.dta"
append using "C:\Users\Sarah Friedman\Dropbox\Sarah-Sunita mergers project\Hospital_Mergers\Data\add_delete\2003_reg_add.dta"
append using "C:\Users\Sarah Friedman\Dropbox\Sarah-Sunita mergers project\Hospital_Mergers\Data\add_delete\2004_reg_add.dta"
append using "C:\Users\Sarah Friedman\Dropbox\Sarah-Sunita mergers project\Hospital_Mergers\Data\add_delete\2005_reg_add.dta"
append using "C:\Users\Sarah Friedman\Dropbox\Sarah-Sunita mergers project\Hospital_Mergers\Data\add_delete\2006_reg_add.dta"
append using "C:\Users\Sarah Friedman\Dropbox\Sarah-Sunita mergers project\Hospital_Mergers\Data\add_delete\2007_reg_add.dta"
append using "C:\Users\Sarah Friedman\Dropbox\Sarah-Sunita mergers project\Hospital_Mergers\Data\add_delete\2008_reg_add.dta"
append using "C:\Users\Sarah Friedman\Dropbox\Sarah-Sunita mergers project\Hospital_Mergers\Data\add_delete\2009_reg_add.dta"
append using "C:\Users\Sarah Friedman\Dropbox\Sarah-Sunita mergers project\Hospital_Mergers\Data\add_delete\2010_reg_add.dta"
append using "C:\Users\Sarah Friedman\Dropbox\Sarah-Sunita mergers project\Hospital_Mergers\Data\add_delete\2011_reg_add.dta"
append using "C:\Users\Sarah Friedman\Dropbox\Sarah-Sunita mergers project\Hospital_Mergers\Data\add_delete\2012_reg_add.dta"
append using "C:\Users\Sarah Friedman\Dropbox\Sarah-Sunita mergers project\Hospital_Mergers\Data\add_delete\2013_reg_add.dta"
append using "C:\Users\Sarah Friedman\Dropbox\Sarah-Sunita mergers project\Hospital_Mergers\Data\add_delete\2014_reg_add.dta"
//Add in non-registered
append using "C:\Users\Sarah Friedman\Dropbox\Sarah-Sunita mergers project\Hospital_Mergers\Data\add_delete\2000_nonreg_add.dta"
append using "C:\Users\Sarah Friedman\Dropbox\Sarah-Sunita mergers project\Hospital_Mergers\Data\add_delete\2001_nonreg_add.dta"
append using "C:\Users\Sarah Friedman\Dropbox\Sarah-Sunita mergers project\Hospital_Mergers\Data\add_delete\2002_nonreg_add.dta"
append using "C:\Users\Sarah Friedman\Dropbox\Sarah-Sunita mergers project\Hospital_Mergers\Data\add_delete\2003_nonreg_add.dta"
append using "C:\Users\Sarah Friedman\Dropbox\Sarah-Sunita mergers project\Hospital_Mergers\Data\add_delete\2004_nonreg_add.dta"
append using "C:\Users\Sarah Friedman\Dropbox\Sarah-Sunita mergers project\Hospital_Mergers\Data\add_delete\2005_nonreg_add.dta"
append using "C:\Users\Sarah Friedman\Dropbox\Sarah-Sunita mergers project\Hospital_Mergers\Data\add_delete\2006_nonreg_add.dta"
append using "C:\Users\Sarah Friedman\Dropbox\Sarah-Sunita mergers project\Hospital_Mergers\Data\add_delete\2007_nonreg_add.dta"
append using "C:\Users\Sarah Friedman\Dropbox\Sarah-Sunita mergers project\Hospital_Mergers\Data\add_delete\2008_nonreg_add.dta"
append using "C:\Users\Sarah Friedman\Dropbox\Sarah-Sunita mergers project\Hospital_Mergers\Data\add_delete\2009_nonreg_add.dta"
append using "C:\Users\Sarah Friedman\Dropbox\Sarah-Sunita mergers project\Hospital_Mergers\Data\add_delete\2010_nonreg_add.dta"
append using "C:\Users\Sarah Friedman\Dropbox\Sarah-Sunita mergers project\Hospital_Mergers\Data\add_delete\2011_nonreg_add.dta"
append using "C:\Users\Sarah Friedman\Dropbox\Sarah-Sunita mergers project\Hospital_Mergers\Data\add_delete\2012_nonreg_add.dta"
append using "C:\Users\Sarah Friedman\Dropbox\Sarah-Sunita mergers project\Hospital_Mergers\Data\add_delete\2013_nonreg_add.dta"
append using "C:\Users\Sarah Friedman\Dropbox\Sarah-Sunita mergers project\Hospital_Mergers\Data\add_delete\2014_nonreg_add.dta"


* Trim string variables
foreach var in id name city state add_reason {
gen `var'_2 = strtrim(`var')
drop `var'
rename `var'_2 `var'
}

*Standardize capitalization and spelling of addition reasons
gen reas = proper(add_reason)
drop add_reason
rename reas add_reason

replace add_reason = "Previously Listed as Nonregistered" if add_reason=="Previously Listed As Nomegistered" | add_reason=="Previously Listed As Nonregist Ered" | add_reason=="Previously Listed As Nonregiste Red" | add_reason=="Previously Listed As Nonregister Ed"


* Create key of reasons 
gen reason_cat = ""

replace reason_cat = "Newly added, New Hospital ID" if add_reason== "Newly Added" | add_reason == "Newly Registered" | add_reason == "Newly Added To The Registered File" | reason_cat=="Newly Added To The Nonregistered File" | add_reason=="Newly Registered Hospital" | add_reason=="Newly Added Hospital" | add_reason=="Formerly Ambulatory Care Facility" | add_reason=="Formerly A Nursing Home"

replace reason_cat = "Change Reg Status, Same ID" if add_reason=="Status Changed From Nonregistered To Registered" | add_reason=="Previously Listed As Nonregistered" | add_reason=="Change From Registered To Non-registered" | add_reason=="Change From Non-registered To Registered" | add_reason=="Previously Nonregistered" | add_reason=="Previously Listed As Registered" | add_reason=="Previously nonregistered" | add_reason=="Status Changed From Nonreg To Reg" | add_reason=="Status Changed From Registered To Nonregistered" | add_reason=="Status Changed To Nonregistered" | add_reason=="Status Changed To Registered" | add_reason=="Change From Registered To Non-Registered" | add_reason=="Change From Non-Registered To Registered" | add_reason=="Previously Listed as Nonregistered"

replace reason_cat = "Demerged, new Hospital ID" if strpos(add_reason, "Demerge")

replace reason_cat = "Merger result, New Hospital ID" if strpos(add_reason, "Merger Result") | strpos(add_reason, "Result Of Merger") 

replace reason_cat = "Merged into existing hospital, New Hospital ID" if strpos(add_reason, "Merged Into")

replace reason_cat = "System ID Change - New Hospital ID" if strpos(add_reason, "System Id Change-Formerly") | strpos(add_reason, "Id System Change-Formerly")
 
replace reason_cat = "System ID Change - Same Hospital ID, Last Year" if strpos(add_reason, "System Id Change-Now")

replace reason_cat = "Outpatient - Same Hospital ID, Last Year" if add_reason=="Outpatient"

replace reason_cat = "Closed - Same Hospital ID, Last Year" if add_reason=="Closed"

replace reason_cat = "Reopened, Same ID as Before Temp Closure" if strpos(add_reason, "Reopened")

replace reason_cat = "Unclear if newly added, only in 2000" if add_reason=="Newly Added To The Nonregistered File"


* Create year variable to match main AHA data set
gen dsname = ""
replace dsname = "AHA00" if year == 2000
replace dsname = "AHA01" if year == 2001
replace dsname = "AHA02" if year == 2002
replace dsname = "AHA03" if year == 2003
replace dsname = "AHA04" if year == 2004
replace dsname = "AHA05" if year == 2005
replace dsname = "AHA06" if year == 2006
replace dsname = "AHA07" if year == 2007
replace dsname = "AHA2008" if year == 2008
replace dsname = "AHA2009" if year == 2009
replace dsname = "AHA2010" if year == 2010
replace dsname = "AHA2011" if year == 2011
replace dsname = "AHA2012" if year == 2012


* Add indicator variable of certainty an addition is actually an addition
gen add_lik = 1 if add_reason!=""
replace add_lik = 2 if reason_cat=="Change Reg Status, Same ID" | reason_cat=="Closed - Same Hospital ID, Last Year" | reason_cat=="Outpatient - Same Hospital ID, Last Year" | reason_cat=="Reopened, Same ID as Before Temp Closure" | reason_cat=="System ID Change - Same Hospital ID, Last Year"
la var add_lik "Likelihood that addition represents a new hospital"
la def add_lik 1 "1 Likely a true addition" 2 "2 Unlikely a true addition"
la val add_lik add_lik

* Save 
save "C:\Users\Sarah Friedman\Dropbox\Sarah-Sunita mergers project\Hospital_Mergers\Data\add_delete\alladds_2000_2014.dta", replace




////////////// APPEND DELETIONS  ///////////////////////
clear
* Registered 
use "C:\Users\Sarah Friedman\Dropbox\Sarah-Sunita mergers project\Hospital_Mergers\Data\add_delete\2000_reg_del.dta"
append using "C:\Users\Sarah Friedman\Dropbox\Sarah-Sunita mergers project\Hospital_Mergers\Data\add_delete\2001_reg_del.dta"
append using "C:\Users\Sarah Friedman\Dropbox\Sarah-Sunita mergers project\Hospital_Mergers\Data\add_delete\2002_reg_del.dta"
append using "C:\Users\Sarah Friedman\Dropbox\Sarah-Sunita mergers project\Hospital_Mergers\Data\add_delete\2003_reg_del.dta"
append using "C:\Users\Sarah Friedman\Dropbox\Sarah-Sunita mergers project\Hospital_Mergers\Data\add_delete\2004_reg_del.dta"
append using "C:\Users\Sarah Friedman\Dropbox\Sarah-Sunita mergers project\Hospital_Mergers\Data\add_delete\2005_reg_del.dta"
append using "C:\Users\Sarah Friedman\Dropbox\Sarah-Sunita mergers project\Hospital_Mergers\Data\add_delete\2006_reg_del.dta"
append using "C:\Users\Sarah Friedman\Dropbox\Sarah-Sunita mergers project\Hospital_Mergers\Data\add_delete\2007_reg_del.dta"
append using "C:\Users\Sarah Friedman\Dropbox\Sarah-Sunita mergers project\Hospital_Mergers\Data\add_delete\2008_reg_del.dta"
append using "C:\Users\Sarah Friedman\Dropbox\Sarah-Sunita mergers project\Hospital_Mergers\Data\add_delete\2009_reg_del.dta"
append using "C:\Users\Sarah Friedman\Dropbox\Sarah-Sunita mergers project\Hospital_Mergers\Data\add_delete\2010_reg_del.dta"
append using "C:\Users\Sarah Friedman\Dropbox\Sarah-Sunita mergers project\Hospital_Mergers\Data\add_delete\2011_reg_del.dta"
append using "C:\Users\Sarah Friedman\Dropbox\Sarah-Sunita mergers project\Hospital_Mergers\Data\add_delete\2012_reg_del.dta"
append using "C:\Users\Sarah Friedman\Dropbox\Sarah-Sunita mergers project\Hospital_Mergers\Data\add_delete\2013_reg_del.dta"
append using "C:\Users\Sarah Friedman\Dropbox\Sarah-Sunita mergers project\Hospital_Mergers\Data\add_delete\2014_reg_del.dta"
* Non-registered
append using "C:\Users\Sarah Friedman\Dropbox\Sarah-Sunita mergers project\Hospital_Mergers\Data\add_delete\2000_nonreg_del.dta"
append using "C:\Users\Sarah Friedman\Dropbox\Sarah-Sunita mergers project\Hospital_Mergers\Data\add_delete\2001_nonreg_del.dta"
append using "C:\Users\Sarah Friedman\Dropbox\Sarah-Sunita mergers project\Hospital_Mergers\Data\add_delete\2002_nonreg_del.dta"
append using "C:\Users\Sarah Friedman\Dropbox\Sarah-Sunita mergers project\Hospital_Mergers\Data\add_delete\2003_nonreg_del.dta"
append using "C:\Users\Sarah Friedman\Dropbox\Sarah-Sunita mergers project\Hospital_Mergers\Data\add_delete\2004_nonreg_del.dta"
append using "C:\Users\Sarah Friedman\Dropbox\Sarah-Sunita mergers project\Hospital_Mergers\Data\add_delete\2005_nonreg_del.dta"
append using "C:\Users\Sarah Friedman\Dropbox\Sarah-Sunita mergers project\Hospital_Mergers\Data\add_delete\2006_nonreg_del.dta"
append using "C:\Users\Sarah Friedman\Dropbox\Sarah-Sunita mergers project\Hospital_Mergers\Data\add_delete\2007_nonreg_del.dta"
append using "C:\Users\Sarah Friedman\Dropbox\Sarah-Sunita mergers project\Hospital_Mergers\Data\add_delete\2008_nonreg_del.dta"
append using "C:\Users\Sarah Friedman\Dropbox\Sarah-Sunita mergers project\Hospital_Mergers\Data\add_delete\2009_nonreg_del.dta"
append using "C:\Users\Sarah Friedman\Dropbox\Sarah-Sunita mergers project\Hospital_Mergers\Data\add_delete\2010_nonreg_del.dta"
append using "C:\Users\Sarah Friedman\Dropbox\Sarah-Sunita mergers project\Hospital_Mergers\Data\add_delete\2011_nonreg_del.dta"
append using "C:\Users\Sarah Friedman\Dropbox\Sarah-Sunita mergers project\Hospital_Mergers\Data\add_delete\2012_nonreg_del.dta"
append using "C:\Users\Sarah Friedman\Dropbox\Sarah-Sunita mergers project\Hospital_Mergers\Data\add_delete\2013_nonreg_del.dta"
append using "C:\Users\Sarah Friedman\Dropbox\Sarah-Sunita mergers project\Hospital_Mergers\Data\add_delete\2014_nonreg_del.dta"


* Trim string variables
foreach var in id name city state add_reason {
gen `var'_2 = strtrim(`var')
drop `var'
rename `var'_2 `var'
}

gen del_reason = proper(add_reason)
drop add_reason
drop if id=="" | id=="Id" | id=="ID" | del_reason=="Reason"


* Create key of reasons 
gen del_reason_cat = ""

replace del_reason_cat = "Became non-hospital facility" if strpos(del_reason, "Ambulatory") | strpos(del_reason, "Behaviorial Health Center") | del_reason=="Developmental & Disability Center" | strpos(del_reason, "Not A Hosp") | strpos(del_reason, "Nursing") | strpos(del_reason, "Outpatient") | del_reason=="Outpatien T" | del_reason=="Inpatient" | strpos(del_reason, "Psychiatric") | strpos(del_reason, "Rehabilitation") | strpos(del_reason, "Urgent Care") | strpos(del_reason, "Behavioral") | strpos(del_reason, "Hospice") | strpos(del_reason, "Inpatient") | strpos(del_reason, "Residential") | strpos(del_reason, "Not Operating As A Hospital")

replace del_reason_cat = "Reg Status Change, No Deletion" if strpos(del_reason, "Non-Registered To Registered") | strpos(del_reason, "Nonregistered To Registered") | del_reason=="Status Changed From Nonreg To Reg" | strpos(del_reason, "Nonregistered To Registered") | strpos(del_reason, "Registered To Nonregistered") | strpos(del_reason, "Changed To Nonregistered") | strpos(del_reason, "Changed To Registered") | strpos(del_reason, "Registered To Non-Registered")

replace del_reason_cat = "Closed" if del_reason=="Closed"

replace del_reason_cat = "Merged into existing hospital" if strpos(del_reason, "Merged Into") | strpos(del_reason, "Merged/Closed Into") | strpos(del_reason, "Merged To Form") | strpos(del_reason, "Merged Closed Into") | strpos(del_reason, "Merged  Into") | strpos(del_reason, "Merged & Closed Into")

replace del_reason_cat = "Merged with existing hospital to form new hospital" if strpos(del_reason, "Merged With")

replace del_reason_cat = "Demerged/Dissolution" if strpos(del_reason, "Dissolution") | strpos(del_reason, "Demerged")
 
replace del_reason_cat = "System ID Change and Hospital ID Change" if strpos(del_reason, "System Id Change-Now")

replace del_reason_cat = "Error entry" if strpos(del_reason, "Duplicate Record") | strpos(del_reason, "Inactive Record")

replace del_reason_cat = "No Reason Given" if del_reason=="" & id!=""

replace del_reason_cat = "Temporarily Closed" if strpos(del_reason, "Temporarily Closed") | strpos(del_reason, "Under Construction")


gen dsname = ""
replace dsname = "AHA00" if year == 2001
replace dsname = "AHA01" if year == 2002
replace dsname = "AHA02" if year == 2003
replace dsname = "AHA03" if year == 2004
replace dsname = "AHA04" if year == 2005
replace dsname = "AHA05" if year == 2006
replace dsname = "AHA06" if year == 2007
replace dsname = "AHA07" if year == 2008
replace dsname = "AHA2008" if year == 2009
replace dsname = "AHA2009" if year == 2010
replace dsname = "AHA2010" if year == 2011
replace dsname = "AHA2011" if year == 2012
replace dsname = "AHA2012" if year == 2013


* Add indicator variable of certainty a deletion is actually a deletion
gen del_lik = 1 if del_reason!=""
replace del_lik = 2 if del_reason_cat=="Temporarily Closed"
replace del_lik = 3 if del_reason_cat=="Reg Status Change, No Deletion" | del_reason_cat=="Error entry"
la var del_lik "Likelihood that deletion represents a deleted hospital"
la def del_lik 1 "1 Likely a true deletion" 2 "2 Unclear if a true deletion" 3 "3 Unlikely a true deletion"
la val del_lik del_lik


save "C:\Users\Sarah Friedman\Dropbox\Sarah-Sunita mergers project\Hospital_Mergers\Data\add_delete\alldel_2000_2014.dta", replace


