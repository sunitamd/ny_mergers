#!/bin/bash
#SBATCH --partition=fn_medium
#SBATCH --time=1-0
#SBATCH --mem=129GBGB
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=1


# MODULES
############################################
module purge
module load sas/9.4
module load stata/15

# REPO - Users must have this folder in their user directory
############################################
REPO=/gpfs/home/$USER/ny_mergers
cd $REPO


############################################
# AHA
############################################

# Clean up AHA (Previously cleaned by Sarah) and Cooper mergers data
    stata -q do code/build/aha/prep/merge_ahacoop_sd.do

# Construct merger, system-HHI, event-study, and market-exposure measures
    stata -q do code/build/aha/prep/construct_mergers_sd.do


############################################
# HCUP
############################################

# Unzip HCUP supplemental files (?)
    run code/build/hcup/import/unzip_hcupfiles

# SAS: Read in supplemental HCUP files for merging
    sas code/build/hcup/prep/NY_SID_2006_CHGS.sas 
    sas code/build/hcup/prep/NY_SID_2006_DX_PR_GRPS.sas
    sas code/build/hcup/prep/NY_SID_2006_SEVERITY.sas

    sas code/build/hcup/prep/NY_SID_2007_CHGS.sas 
    sas code/build/hcup/prep/NY_SID_2007_DX_PR_GRPS.sas
    sas code/build/hcup/prep/NY_SID_2007_SEVERITY.sas

    sas code/build/hcup/prep/NY_SID_2008_CHGS.sas 
    sas code/build/hcup/prep/NY_SID_2008_DX_PR_GRPS.sas
    sas code/build/hcup/prep/NY_SID_2008_SEVERITY.sas

    sas code/build/hcup/prep/NY_SID_2009_CHGS.sas 
    sas code/build/hcup/prep/NY_SID_2009_DX_PR_GRPS.sas
    sas code/build/hcup/prep/NY_SID_2009_SEVERITY.sas
    sas code/build/hcup/prep/NY_SID_2009_AHAL.sas 

    sas code/build/hcup/prep/NY_SID_2010_CHGS.sas 
    sas code/build/hcup/prep/NY_SID_2010_DX_PR_GRPS.sas
    sas code/build/hcup/prep/NY_SID_2010_SEVERITY.sas

    sas code/build/hcup/prep/NY_SID_2011_CHGS.sas 
    sas code/build/hcup/prep/NY_SID_2011_DX_PR_GRPS.sas
    sas code/build/hcup/prep/NY_SID_2011_SEVERITY.sas
    sas code/build/hcup/prep/NY_SID_2011_AHAL.sas 

    sas code/build/hcup/prep/NY_SID_2012_CHGS.sas 
    sas code/build/hcup/prep/NY_SID_2012_DX_PR_GRPS.sas
    sas code/build/hcup/prep/NY_SID_2012_SEVERITY.sas

# Merge supplemental files to original HCUP data
    # Merge AHA files 2009-2011 to HCUP files (early years already merged)
        sas code/build/hcup/prep/merge_aha_core0911.sas

    # Merge Revisit variables to HCUP-AHA for 2006-2008 (later years already merged)
        sas code/build/hcup/prep/merge_aha_core0911.sas

    # Merge other supplemental files  and append all years
        sas code/build/hcup/prep/merge_supp_hcup.sas

    # Export HCUP data to stata
        sas code/build/hcup/merge/export_stata_hcup.sas

# Construct working/analytical datasets
    # Merge AHA merger/HHI (bed-based) with HCUP
        stata -q do codebuild/hcup/prep/merge_hhi_ny_sid_supp.do

    # Collapse AHA x HCUP data to hospital-level
       stata -q do code/build/hcup/prep/collapse_hhi_ny_sid_sup.do

    # Construct HCUP outcomes
       stata -q do code/build/hcup/prep/construct_outcomes.do

    # Construct system-HHI terciles
       stata -q do code/build/hcup/prep/construct_hhisys_terciles.do

    # Construct hospital-varying patient-based HHI
       stata -q do code/build/hcup/prep/construct_hhi_hospital.do


############################################
# MMC
############################################
# Import and append monthly county-level Medicaid enrollment (Orin)
   stata -q do code/build/mmc/prep/combine_mmc.do
