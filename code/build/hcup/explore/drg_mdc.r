############################################
# Investigate distribution of DRG & MDC codes in HCUP
############################################

library(tidyverse)
library(ggrepel)
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
        library(haven)
        hcup <- read_dta(paste0(proj_dir, 'ny_mergers/data_sidclean/sid_work/ny_sid_0612_supp_sample.dta'))
    } else {
        hcup <- readRDS(paste0(proj_dir, 'ny_mergers/data_sidclean/sid_work/ny_sid_0612_supp_sample.rds'))
    }
} else {
    hcup <- readRDS('dump/ny_sid_0612_supp.rds')
}

mdc_labels <- c('Pre-MDC', 'Nervous', 'Eye', 'Ear,Nose,Mouth,Throat', 'Respiratory', 'Circulatory', 'Digestive', 'Hepatobiliary & Pancreas', 'Musculoskeletal', 'Skin', 'Endocrine', 'Kidney/UT', 'Male Reprod.', 'Female Reprod.', 'Pregnancy', 'Newborn', 'Blood/Immunological', 'Myeloproliferative', 'Infections/Parasitic', 'Mental', 'Alcohol/Drug', 'Injuries/Poision', 'Burns', 'Health Status/Services', 'Trauma', 'HIV')
names(mdc_labels) <- 0:25

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

ggplot(mdc, aes(reorder(mdc, -Medicaid), ds, fill=pay1)) +
    geom_col() +
    scale_fill_manual('Payer', values=pay_cols) +
    labs(x='MDC', y='Discharges', caption='Discharges for all HCUP years')

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

ggplot(drg %>% filter(Medicaid>medicaid_top10), aes(reorder(drg, -Medicaid), ds, fill=pay1)) +
    geom_col() +
    scale_fill_manual('Payer', values=pay_cols) +
    labs(x='DRG Codes', y='Discharges', caption='Discharges for all HCUP years') +
    theme(axis.ticks.x=element_blank(), axis.text.x=element_blank())


############################################
# K-means clustering
############################################

# 1. select features
# 2. scale & standardize features
# 3. calculate distance matrix / decide which type of distance metric to use
# 4. kmeans clustering

# MDC
############################################
df <- as.data.frame(mdc_spread[,-1])
rownames(df) <- mdc_labels

set.seed(8)

mdc_kmeans <- lapply(2:15, function(k, .df=df) {
    kmeans(.df, k, iter.max=100, nstart=25)
})

# plot kmeans clusters
mdc_plots <- lapply(2:7, function(k, .kmeans=mdc_kmeans, .df=df) {
    fviz_cluster(.kmeans[[k-1]], geom='text', data=.df, repel=TRUE, labelsize=8) + ggtitle(paste0('k=',k))
})
grid.arrange(grobs=mdc_plots, ncol=3)

# custom cluster plot
mdc_gplots <- lapply(2:7, function(k, .kmeans=mdc_kmeans, .df=df) {
    temp <- .df
    temp$cluster <- factor(.kmeans[[k-1]]$cluster)
    temp$mdc <- rownames(temp)
    temp <- arrange(temp, Medicaid, Private)
    temp_chull <- temp %>%
        group_by(cluster) %>%
            slice(chull(Medicaid, Private))

    ggplot(temp, aes(Medicaid, Private, color=cluster)) +
        geom_point(pch=8) +
        geom_text_repel(aes(label=mdc), size=3, segment.size=0.2, segment.alpha=0.4) +
        geom_polygon(data=temp_chull, aes(color=cluster, group=cluster, fill=cluster), alpha=0.3) +
        guides(color=FALSE, fill=FALSE) +
        labs(title=paste0('k=',k))
})
grid.arrange(grobs=mdc_gplots, ncol=3)


# elbow plot
mdc_wss <- lapply(mdc_kmeans, function(kmean) kmean$tot.withinss)
plot(2:15, mdc_wss,
       type="b", pch = 19, frame = FALSE, 
       xlab="Number of clusters K",
       ylab="Total within-clusters sum of squares")

# silhouelette plot
mdc_sils <- lapply(mdc_kmeans, function(kmean, .df=df) {
    ss <- silhouette(kmean$cluster, dist(.df))
    mean(ss[,3])
})
plot(2:15, mdc_sils,
       type = "b", pch = 19, frame = FALSE, 
       xlab = "Number of clusters K",
       ylab = "Average Silhouettes")


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
