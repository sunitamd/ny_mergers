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
# Shapefiles downloaded from: https://www.census.gov/geo/maps-data/data/cbf/cbf_counties.html
us <- read_sf("mapping/shapefiles/cb_2017_us_county_20m/cb_2017_us_county_20m.shp")
ny <- us %>% filter(STATEFP=="36")
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
# Treatment: merger in market-year and no merger in +/- 2 years
# Control: no merger in market-year and no merger in +/- 2 years

aha_cnty <- aha %>%
	# Create merger indicator, 3-digit county FIPS
	mutate(merger=case_when(merge %in% 1:3~1, TRUE~0),
		COUNTYFP=sprintf('%03.0f', fcntycd)) %>%
	# Add hospital mergers over county-years
	group_by(aha_year, COUNTYFP) %>%
		summarise(mergers=sum(merger)) %>%
		ungroup() %>%
	arrange(COUNTYFP, aha_year) %>%
	# Create treatment indicator within each county
	group_by(COUNTYFP) %>%
		# If lag/lead does not exists treat as no merger
		mutate(merger_2=lag(mergers,2,0) + lag(mergers,1,0) + lead(mergers,1,0) + lead(mergers,2,0)) %>%
		ungroup() %>%
	mutate(treat=case_when(
		mergers>0 & merger_2==0 ~ 'Treatment',
		mergers==0 & merger_2==0 ~ 'Control',
		TRUE ~ 'Neither'))


############################################
# Merge shapefile and AHA
############################################
assert_that(all(aha_cnty$COUNTYFP %in% unique(ny$COUNTYFP)), msg='COUNTYFIPS DO NOT MATCH BTWN DATA!')
ny_aha <- left_join(ny, aha_cnty[aha_cnty$aha_year>=2006,], by='COUNTYFP')
# # Fill county-years with no hospitals
# temp_fill <- expand.grid(unique(ny_aha$COUNTYFP), seq(2006,2012)) %>%
# 	rename(COUNTYFP=Var1, aha_year_fill=Var2)

# ny_aha <- left_join(temp_fill, ny_aha, by='COUNTYFP')
# ny_aha <- ny_aha %>% replace_na(list(treat='Neither')) %>% as_tibble()


############################################
# Plotting
############################################
ptemp <- ny_aha %>%
	select(geometry, aha_year, treat) %>%
	filter(!is.na(aha_year))

ggplot() +
	geom_sf(data=ptemp, aes(fill=treat)) +
	facet_wrap(~aha_year, nrow=3) +
	scale_fill_manual('Treatment Group', breaks=c('Treatment', 'Control', 'Neither'), values=c('Treatment'='tomato2', 'Control'='wheat3', 'Neither'='lightgrey')) +
	theme_void()
ggsave("mapping/treatment_counties.pdf", device='pdf')
