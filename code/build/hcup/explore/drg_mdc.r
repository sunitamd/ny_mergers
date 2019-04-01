############################################
# Investigate distribution of DRG & MDC codes in HCUP
############################################

library(haven)
library(tidyverse)
library(factoextra)
library(gridExtra)
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

if (Sys.info()['sysname'] == 'unix') {
    if (sample) {
        hcup <- read_dta(paste0(proj_dir, 'ny_mergers/data_sidclean/sid_work/ny_sid_0612_supp_sample.dta'))
    } else {
        hcup <- readRDS(paste0(proj_dir, 'ny_mergers/data_sidclean/sid_work/ny_sid_0612_supp_sample.rds'))
    }
} else {
    hcup <- readRDS('dump/ny_sid_0612_supp.rds')
}

############################################
# RUN PROGRAM
############################################

plot.list <- list(length=2)

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
plot.list[[1]] <- ptemp

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
plot.list[[2]] <- ptemp

plots <- do.call(marrangeGrob, c(plot.list, list(nrow=1, ncol=1)))
ggsave("outputs/mdc_drg/plots.pdf", plots, device='pdf')


############################################
# K-means clustering
############################################

# 1. select features
# 2. scale & standardize features
# 3. calculate distance matrix / decide which type of distance metric to use
# 4. kmeans clustering

# MDC
############################################
df <- scale(mdc_spread)

set.seed(8)

mdc_ks <- lapply(2:15, function(k, .df=df) {
    kmeans(.df[,-1], k, nstart=25)
})
mdc_wss <- lapply(mdc_ks, function(kmean) kmean$tot.withinss)

mdc_plots <- lapply(1:5, function(i, .kmeans=mdc_ks, .df=df) {
    fviz_cluster(.kmeans[[i]], geom='point', data=.df) + ggtitle(paste0('k=',i+1))
})
grid.arrange(mdc_plots[[1]], mdc_plots[[2]], mdc_plots[[3]], mdc_plots[[4]], mdc_plots[[5]], nrow=3)

plot(2:15, mdc_wss,
       type="b", pch = 19, frame = FALSE, 
       xlab="Number of clusters K",
       ylab="Total within-clusters sum of squares")


# DRG Codes
############################################

df <- scale(drg_spread[,-1])
rownames(df) <- drg_spread[,1][[1]]

set.seed(8)

drg_ks <- lapply(2:15, function(k, .df=df) {
    kmeans(.df, k, nstart=25)
})
drg_wss <- lapply(drg_ks, function(kmean) kmean$tot.withinss)

drg_plots <- lapply(1:5, function(i, .kmeans=drg_ks, .df=df) {
    fviz_cluster(.kmeans[[i]], geom='point', data=.df) + ggtitle(paste0('k=',i+1))
})
grid.arrange(drg_plots[[1]], drg_plots[[2]], drg_plots[[3]], drg_plots[[4]], drg_plots[[5]], nrow=3)

plot(2:15, drg_wss,
       type="b", pch = 19, frame = FALSE, 
       xlab="Number of clusters K",
       ylab="Total within-clusters sum of squares")
