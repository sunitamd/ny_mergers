############################################
# Investigate distribution of DRG & MDC codes in HCUP
############################################

library(haven)
library(tidyverse)
library(RColorBrewer)

############################################
# ARGS
############################################

args <- commandArgs(trailingOnly=TRUE)

if (args[[1]] == '--sample') {
    sample <- TRUE
} else {
    sample <- FALSE
}

############################################
# SETTINGS
############################################

proj_dir <- '/gpfs/data/desailab/home/'

theme_set(theme_bw())
pay_cols <- brewer.pal(6, 'Paired')

############################################
# DATA
############################################

if (sample) {
    hcup <- read_dta(paste0(proj_dir, 'ny_mergers/data_sidclean/sid_work/ny_sid_0612_supp_sample.dta'))
} else {
    hcup <- read_dta(paste0(proj_dir, 'ny_mergers/data_sidclean/sid_work/ny_sid_0612_supp_sample.dta'))
}

############################################
# RUN PROGRAM
############################################

# Collapse mdc codes by payer
mdc <- hcup %>%
    group_by(pay1, mdc) %>%
        summarise(ds=n()) %>%
        ungroup() %>%
    mutate(pay1=factor(pay1, levels=1:6, labels=c('Medicare', 'Medicaid', 'Private', 'SelfPay', 'NoCharge', 'Other'), ordered=FALSE))
mdc_spread <- spread(mdc, pay1, ds, fill=0)
mdc <- left_join(mdc, mdc_spread, by='mdc')

ptemp <- ggplot(mdc, aes(reorder(mdc, -Medicaid), ds, fill=pay1)) +
    geom_col() +
    scale_fill_manual('Payer', values=pay_cols) +
    labs(x='MDC', y='Discharges', caption='Discharges for all HCUP years')
ggsave(filename='outputs/mdc_drg/mdc.pdf', plot=ptemp, device='pdf')

# Collapse drg codes by payer
drg <- hcup %>%
    group_by(pay1, drg) %>%
        summarise(ds=n()) %>%
        ungroup() %>%
    mutate(
        pay1=factor(pay1, levels=1:6, labels=c('Medicare', 'Medicaid', 'Private', 'SelfPay', 'NoCharge', 'Other'), ordered=FALSE),
        drg=factor(drg, levels=unique(hcup$drg), ordered=FALSE))
drg_spread <- spread(drg, pay1, ds, fill=0)
drg <- left_join(drg, drg_spread, by='drg')

medicaid_top10 <- quantile(drg$Medicaid, 0.90)

ptemp <- ggplot(drg %>% filter(Medicaid>medicaid_top10), aes(reorder(drg, -Medicaid), ds, fill=pay1)) +
    geom_col() +
    scale_fill_manual('Payer', values=pay_cols) +
    labs(x='DRG Codes', y='Discharges', caption='Discharges for all HCUP years') +
    theme(axis.ticks.x=element_blank(), axis.text.x=element_blank())
ggsave(filename='outputs/mdc_drg/drg.pdf', plot=ptemp, device='pdf')

