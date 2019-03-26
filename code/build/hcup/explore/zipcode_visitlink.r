############################################
# Plot rates of missing zipcodes and visitlink
############################################

library(haven)
library(tidyverse)
library(RColorBrewer)

theme_set(theme_bw())

cols <- rev(brewer.pal(8, 'BuPu'))


############################################

zipcode_visitlink <- read_dta('dump/zipcode_visitlink.dta')

temp <- zipcode_visitlink %>%
    filter(!is.na(ahaid_cd)) %>%
    gather(var, rate, rate_0:rate_v, na.rm=TRUE)

var_labels <- c('rate_0'='Missing Zipcode', 'rate_3'='3-Digit Zipcode', 'rate_v'='Missing VISITLINK')

ggplot(temp, aes(ahaid_cd, rate, col=log(ds))) +
    geom_point() +
    facet_wrap(~var, ncol=1, labeller=labeller(var=var_labels)) +
    scale_color_gradientn('Discharges (log)', colors=cols)
    labs(x='AHAID', y='Rate', title='Rate of discharges for:', caption='Rates & Discharges: total across all years')
