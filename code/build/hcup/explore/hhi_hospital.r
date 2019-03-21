############################################
# Scatter hospital-HHIs
############################################

library(haven)
library(tidyverse)


############################################
theme_set(theme_bw())


############################################
hhi <- read_dta('dump/hhi_hospital.dta')


# Scatter HHI in 2006 vs HHI in 2012
############################################
ptemp <- hhi %>%
	filter(year %in% c(2006, 2012)) %>%
	spread(key=year, value=hhi_hosp, sep='_')

na_2006 <- nrow(filter(ptemp, is.na(year_2006)))
na_2012 <- nrow(filter(ptemp, is.na(year_2012)))
caption_na <- paste0('Note: ', na_2006, ', ', na_2012, ' hospitals not observed in 2006, 2012, respectively.')

ggplot(ptemp, aes(x=year_2006, y=year_2012)) +
	geom_point(alpha=0.7) +
	geom_abline(slope=1, intercept=0, linetype='dashed', col='grey40') +
	xlim(c(0,1.0)) +
	ylim(c(0,1.0)) +
	labs(title="Hospital-level HHI", x="HHI (2006)", y="HHI (2012)", caption=caption_na)
ggsave('outputs/hhi_hospital_scatter1.pdf', device='pdf')

# Scatter HHI in first observered year vs HHI in last observed year
############################################
ptemp <- hhi %>%
	group_by(ahaid) %>%
		mutate(hhi1=first(hhi_hosp, order_by=year), hhi2=last(hhi_hosp, order_by=year)) %>%
		ungroup() %>%
	select(ahaid, hhi1, hhi2) %>%
	distinct()

ggplot(ptemp, aes(x=hhi1, y=hhi2)) +
	geom_point(alpha=0.7) +
	geom_abline(slope=1, intercept=0, linetype='dashed', col='grey40') +
	xlim(c(0,1.0)) +
	ylim(c(0,1.0)) +
	labs(title="Hospital-level HHI", x="HHI (first year)", y="HHI (last year)", caption='First & last year represent first and last year of observed data')
ggsave('outputs/hhi_hospital_scatter2.pdf', device='pdf')
