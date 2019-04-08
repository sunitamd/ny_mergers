############################################

library(shiny)
library(plotly)
library(tidyverse)
library(ggrepel)
library(gridExtra)

# source('code/shiny/mdc_drg/library.r')


############################################
# Data

drg <- readRDS('../../../dump/drg.rds')
drg_spread <- spread(drg, pay1, ds, fill=0)
mdc_drg <- readRDS('../../../dump/mdc_drg.rds')

mdc_names <- c('Pre-MDC', 'Diseases and Disorders of the Nervous System', 'Diseases and Disorders of the Eye', 'Diseases and Disorders of the Ear, Nose, Mouth And Throat', 'Diseases and Disorders of the Respiratory System', 'Diseases and Disorders of the Circulatory System', 'Diseases and Disorders of the Digestive System', 'Diseases and Disorders of the Hepatobiliary System And Pancreas', 'Diseases and Disorders of the Musculoskeletal System And Connective Tissue', 'Diseases and Disorders of the Skin, Subcutaneous Tissue And Breast', 'Diseases and Disorders of the Endocrine, Nutritional And Metabolic System', 'Diseases and Disorders of the Kidney And Urinary Tract', 'Diseases and Disorders of the Male Reproductive System', 'Diseases and Disorders of the Female Reproductive System', 'Pregnancy, Childbirth And Puerperium', 'Newborn And Other Neonates (Perinatal Period)', 'Diseases and Disorders of the Blood and Blood Forming Organs and Immunological Disorders', 'Myeloproliferative DDs (Poorly Differentiated Neoplasms)', 'Infectious and Parasitic DDs (Systemic or unspecified sites)', 'Mental Diseases and Disorders', 'Alcohol/Drug Use or Induced Mental Disorders', 'Injuries, Poison And Toxic Effect of Drugs', 'Burns', 'Factors Influencing Health Status and Other Contacts with Health Services', 'Multiple Significant Trauma', 'Human Immunodeficiency Virus Infection')
mdc_names <- paste0(0:25, ': ', mdc_names)
mdc_choices <- 0:25
names(mdc_choices) <- mdc_names


# scatter DRGs by specific MDCs
scatter_drg <- function(mdc, .mdc_drg=mdc_drg, .drg_spread=drg_spread, .mdc_names=mdc_names) {
    # kmeans for DRGs of specific MDC

    # MDC name
    print(.mdc_names[mdc])
    mdc_name <- paste0('MDC: (', mdc, ')  ', .mdc_names[mdc])

    # Pull DRGs
    drgs <- .mdc_drg %>%
        filter(mdc==!!mdc) %>%
        pull(drg)

    df <- filter(drg_spread, drg %in% !!drgs) %>%
        rowwise() %>%
        mutate(Total=sum(Medicare, Medicaid, Private, NoCharge, Other))

    p <- ggplot(df, aes(Medicaid, Private, alpha=Total, text=paste0('DRG: ', drg))) +
            geom_point(pch=20) +
            geom_abline(intercept=0, slope=1, color='tomato4', linetype='dashed', alpha=0.6) +
            scale_alpha(name='Total discharges', range=c(0.4,1)) +
            labs(title=mdc_name) +
            theme_minimal()
    ggplotly(p)

}



############################################
# UI

ui <- fluidPage(

    titlePanel('DRG Codes'),

    sidebarPanel(

        # Input: Selector for MDC group
        selectInput('mdc', 'MDC Group:', mdc_choices)

    ),

    mainPanel(

        # Output: DRG scatterplot
        plotlyOutput('drg_scatter')



    )
)


############################################
# SERVER

server <- function(input, output) {
    
    # Scatterplot of DRG codes
    output$drg_scatter <- renderPlotly({
        scatter_drg(input$mdc)
    })

    # Debug mdc_name
    output$mdc_name <- renderText({
        mdc_names[input$mdc]
    })
}


############################################
# APP

shinyApp(ui, server)
