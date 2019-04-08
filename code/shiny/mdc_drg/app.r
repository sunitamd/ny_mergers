############################################

library(shiny)
library(tidyverse)

source('code/shiny/mdc_drg/mdc_drg_library.r')


############################################
# Data

drg <- readRDS('dump/drg.rds')
drg_spread <- spread(drg, pay1, ds, fill=0)

mdc_names <- c('Pre-MDC', 'Diseases and Disorders of the Nervous System', 'Diseases and Disorders of the Eye', 'Diseases and Disorders of the Ear, Nose, Mouth And Throat', 'Diseases and Disorders of the Respiratory System', 'Diseases and Disorders of the Circulatory System', 'Diseases and Disorders of the Digestive System', 'Diseases and Disorders of the Hepatobiliary System And Pancreas', 'Diseases and Disorders of the Musculoskeletal System And Connective Tissue', 'Diseases and Disorders of the Skin, Subcutaneous Tissue And Breast', 'Diseases and Disorders of the Endocrine, Nutritional And Metabolic System', 'Diseases and Disorders of the Kidney And Urinary Tract', 'Diseases and Disorders of the Male Reproductive System', 'Diseases and Disorders of the Female Reproductive System', 'Pregnancy, Childbirth And Puerperium', 'Newborn And Other Neonates (Perinatal Period)', 'Diseases and Disorders of the Blood and Blood Forming Organs and Immunological Disorders', 'Myeloproliferative DDs (Poorly Differentiated Neoplasms)', 'Infectious and Parasitic DDs (Systemic or unspecified sites)', 'Mental Diseases and Disorders', 'Alcohol/Drug Use or Induced Mental Disorders', 'Injuries, Poison And Toxic Effect of Drugs', 'Burns', 'Factors Influencing Health Status and Other Contacts with Health Services', 'Multiple Significant Trauma', 'Human Immunodeficiency Virus Infection')
mdc_names <- paste0(0:25, ': ', mdc_names)


############################################
# UI

ui <- pageWithSidebar(

    headerPanel('DRG Codes'),

    sidebarPanel(

        # Selector for MDC group
        selectInput('mdc', 'MDC Group:', mdc_names, selectize=TRUE)
    ),

    mainPanel()
)


############################################
# SERVER

server <- function(input, output) {
    
}


############################################
# APP

shinyApp(ui, server)
