# Create New York state county maps of treatment, control, N/A units


############################################
# Libraries
############################################
library(tidyverse)
library(haven)
library(sf)
library(assertthat)


############################################
# Settings
############################################
proj_dir <- '/gpfs/data/desailab/home/ny_mergers'

theme_set(theme_bw())


############################################
# NY Counties Shapefile
############################################
# Shapefiles downloaded from: gis.ny.gov/civil-boundaries/ß
ny <- read_sf("mapping/shapefiles/NYS_Civil_Boundaries_SHP/Counties_Shoreline.shp")
# Set CRS to mercator
ny <- st_transform(ny, crs=3857)


############################################
# AHA Data
############################################
# Detect if on cluster
if (Sys.info()[['sysname']] == 'Linux') {
	aha <- read_dta(paste0(proj_dir, '/data_hosp/aha_combined_final_v2.dta'))
} else {
	aha <- read_dta('data/aha_combined_final_v2.dta')
}

# New York, GAC Hospitals
aha <- aha %>% filter(fstcd==36, serv==10)

# Generate treatment/control/na groups
aha_cnty <- aha %>%
	mutate(merger=case_when(merge %in% 1:3~1, TRUE~0), COUNTYFIPS=sprintf('%03.0f', fcntycd)) %>%
	group_by(aha_year, COUNTYFIPS) %>%
		summarise(mergers=sum(merger)) %>%
		ungroup() %>%
	arrange(COUNTYFIPS, aha_year) %>%
	group_by(COUNTYFIPS) %>%
		mutate(merger_2=lag(mergers,2) + lag(mergers,1) + lead(mergers,1) + lead(mergers,2)) %>%
		ungroup() %>%
	mutate(treat=case_when(
		mergers>0 & merger_2==0 ~ 'Treatment',
		mergers==0 & merger_2==0 ~ 'Control',
		TRUE ~ 'Neither'))


############################################
# Merge shapefile and AHA
############################################
assert_that(all(aha_cnty$COUNTYFIPS %in% unique(ny$COUNTYFIPS)), msg='COUNTYFIPS DO NOT MATCH BTWN DATA!')
ny_aha <- left_join(ny, aha_cnty[aha_cnty$aha_year>=2006,], by='COUNTYFIPS')
# Fill county-years with no hospitals
temp_fill <- expand.grid(unique(ny_aha$COUNTYFIPS), unique(ny_aha$aha_year)) %>%
	filter(Var2!='NA') %>%
	rename(COUNTYFIPS=Var1, aha_year_fill=Var2)

ny_aha <- left_join(temp_fill, ny_aha, by='COUNTYFIPS')
ny_aha <- ny_aha %>% replace_na(list(treat='Neither'))


############################################
# Plotting
############################################
cnty_treat_map <- ggplot() +
	geom_sf(data=ny_aha, aes(fill=treat)) +
	facet_wrap(~aha_year_fill, ncol=2) +
	scale_fill_manual('Treatment Group', breaks=c('Treatment', 'Control', 'Neither'), values=c('Treatment'='salmon4', 'Control'='black', 'Neither'='grey30')) +
	theme_void()
