# NY Mergers

2019

Measuring the impact of hospital mergers in New York State on (1) quality of, (2) access to, and (3) disparities in healthcare for low-income populations.


# Table of contents

[1. Repository structure](#repository-structure)  
[2. Data](#data)


# Repository structure

	REPO
	.
	|-- code
	|   |-- _source_        - subdir for each source
	|   |   |-- prep            - prep clean, analytical data
	|   |   |-- explore         - exploratory data analysis
	|   |-- analysis        - main analyses
	|-- dump            - scp files between Bigpurple & local (ignored)
	|-- mapping	    - mapping scripts
	|-- outputs	    - figures, tables, etc.
	|-- public          - outputs for publication/external audiences
	|-- reports         - reports for internal meetings, communication
	|-- shapefiles      - shapefiles
	|-- slurm 	    - scripts for slurm

	
	DATA
	/gpfs/data/desailab/home/ny_mergers
	|-- data_analytic   - data for analyses
	|-- data_hospclean  - prepped/cleaned data from raw sources
	|-- data_sidclean   - prepped HCUP data
	|   |-- aha_add_delete
	|   |-- sid_work
	|-- inputs          - prepped/cleaned data from external sources
 

# Data

1. **New York State Medicaid enrollment, claims, and encounters** contain detailed demographic and clinical characteristics for all Medicaid beneficiaries and their comprehensive health care claims. It contains complete data on all health care encounters among Medicaid managed care enrollees in the state.  
2. **Hospital Cost Utilization Project (HCUP) New York State inpatient data** contains information on diagnoses, procedures, outcomes, payer, zip code of residence for the patient, demographic and clinical characteristics for all inpatient admissions in New York State.  
3. **The American Hospital Association (AHA) Annual Survey** contains hospital characteristics, such as the number of beds, ownership status, and teaching status, for nearly all short-term acute care hospitals in the United States. It also identifies whether a hospital is a member of a health system and if it is, a unique identifier for the health system.  
4. **Hospital consolidation dataset** ([Cooper et al.](https://healthcarepricingproject.org/)) contains data on hospital mergers that occurred from 2001 to 2014 that have been verified with external sources (Irving-Levin Associates, Factset, SDC Platinum, Becker's Hospital Review, newspaper articles).

