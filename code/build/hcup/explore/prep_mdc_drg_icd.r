############################################
# Prep NY SID SUPP data for R use reports on MDC, DRG, & ICD Code analyses
############################################

library(haven)
library(data.table)

############################################
# SETTINGS
############################################

proj_dir <- '/gpfs/data/desailab/home/'


############################################
# DATA
############################################

# Check if RDS of full HCUP data already exists
if (!file.exists(paste0(proj_dir, 'data_sidclean/sid_work/ny_sid_0612_supp.rds'))) {
    hcup <- read_dta(paste0(proj_dir, 'data_sidclean/sid_work/ny_sid_0612_supp.dta'))
    hcup <- as.data.table(hcup)
    saveRDS(hcup, paste0(proj_dir, 'data_sidclean/sid_work/ny_sid_0612_supp.rds'))
} else {
    hcup <- readRDS(paste0(proj_dir, 'data_sidclean/sid_work/ny_sid_0612_supp.rds'))
}


############################################
# RUN PROGRAM
############################################

# Create aggregated datasets for export
test[, .(n=.N), keyby=c('pay1', 'mdc')]

mdcs <- hcup %>%
    group_by(pay1, mdc) %>%
        summarise(ds=n()) %>%
        ungroup() %>%
    mutate(
        pay1=factor(pay1, levels=1:6, labels=c('Medicare', 'Medicaid', 'Private', 'SelfPay', 'NoCharge', 'Other'), ordered=FALSE))

drgs <- hcup %>%
    group_by(pay1, mdc, drg) %>%
        summarise(ds=n()) %>%
        ungroup() %>%
    mutate(
        pay1=factor(pay1, levels=1:6, labels=c('Medicare', 'Medicaid', 'Private', 'SelfPay', 'NoCharge', 'Other'), ordered=FALSE),
        drg=factor(drg, levels=unique(hcup$drg), ordered=FALSE))

icds <- hcup %>%
    group_by(pay1, mdc, dx1) %>%
        summarise(dx=n()) %>%
        ungroup() %>%
    mutate(
        pay1=factor(pay1, levels=1:6, labels=c('Medicare', 'Medicaid', 'Private', 'SelfPay', 'NoCharge', 'Other'), ordered=FALSE))

saveRDS('dump/mdcs.rds')
saveRDS('dump/drgs.rds')
saveRDS('dump/icds.rds')

