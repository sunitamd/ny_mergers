library(haven)
library(tidyverse)

theme_set(theme_bw())

hhi <- read_dta('dump/hhi_hospital.dta')

ptemp <- hhi %>%
	filter(year %in% c(2006, 2012)) %>%
	spread(key=year, value=hhi_hosp, sep='_')

na_2006 <- nrow(filter(ptemp, is.na(year_2006)))
na_2012 <- nrow(filter(ptemp, is.na(year_2012)))
caption_na <- paste0('Note: ', na_2006, ', ', na_2012, ' hospitals not observed in 2006, 2012, respectively.')

ggplot(ptemp, aes(year_2006, year_2012)) +
	geom_point() +
	geom_abline(slope=1, intercept=0, linetype='dashed', col='grey40') +
	xlim(c(0,1.0)) +
	ylim(c(0,1.0)) +
	labs(title="Hospital-level HHI", x="HHI (2006)", y="HHI (2012)", caption=caption_na)

