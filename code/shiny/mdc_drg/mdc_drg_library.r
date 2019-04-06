############################################
# FUNCTIONS
############################################

library(tidyverse)


############################################

mdc_drg <- readRDS('dump/mdc_drg.rds')

############################################


kmean_drg <- function(mdc, .mdc_drg=mdc_drg, .drg_spread=drg_spread) {
    # kmeans for DRGs of specific MDC

    # Pull DRGs
    drgs <- .mdc_drg %>%
        filter(mdc==!!mdc) %>%
        pull(drg)

    .df <- filter(drg_spread, drg %in% !!drgs)
    rownames(.df) <- .df[,1][[1]]
    .df[,1] <- NULL

    # k-means clustering
    set.seed(8)

    kmeans <- lapply(2:15, function(k, data=.df) {
        kmeans(data, k, iter.max=100, nstart=25)
    })

    # cluster plots
    plots <- lapply(2:9, function(k, .kmeans=kmeans, data=.df) {
        temp <- as.data.frame(data)
        temp$cluster <- factor(.kmeans[[k-1]]$cluster)
        temp$drg <- rownames(temp)
        temp <- arrange(temp, Medicaid, Private)
        temp_chull <- temp %>%
            group_by(cluster) %>%
                slice(chull(Medicaid, Private)) %>%
                ungroup()

        ggplot(temp, aes(Medicaid, Private), color=cluster) +
            geom_text_repel(aes(label=drg), size=2, segment.size=0.2) +
            geom_point(pch=4, size=0.8, alpha=0.8) +
            geom_polygon(data=temp_chull, aes(color=cluster, group=cluster, fill=cluster), alpha=0.2) +
            guides(color=FALSE, fill=FALSE) +
            labs(title=paste0('k = ', k))
    })
    
    plot.grid <- grid.arrange(grobs=plots, nrow=2)

    # Scree plot
    wss <- lapply(kmeans, function(kmean) kmean$tot.withinss)
    scree <- plot(2:15, wss,
        type='b', pch=19, frame=FALSE,
        xlab='Number of clusters k', ylab='Total within-cluster sum of squares')

    return(list(kmeans=kmeans, plots=plots, plot.grid=plot.grid, scree=scree))

}


# scatter DRGs by specific MDCs
scatter_drg <- function(mdc, .mdc_drg=mdc_drg, .drg_spread=drg_spread, mdcs=mdc_labels) {
    # kmeans for DRGs of specific MDC

    # Pull DRGs
    drgs <- .mdc_drg %>%
        filter(mdc==!!mdc) %>%
        pull(drg)

    df <- filter(drg_spread, drg %in% !!drgs) %>%
        rowwise() %>%
        mutate(tot=sum(Medicare, Medicaid, Private, NoCharge, Other))

    ggplot(df, aes(Medicaid, Private, alpha=tot)) +
        geom_text_repel(aes(label=drg), size=2, segment.size=0.2) +
        geom_point(pch=20) +
        geom_abline(intercept=0, slope=1, color='tomato4', linetype='dashed', alpha=0.4) +
        scale_alpha_continuous(name='Total discharges') +
        labs(title=paste0('MDC: (', mdc, ') ', mdc_labels[mdc]))

    }
