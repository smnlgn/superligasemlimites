library(shiny)
library(shinydashboard)
library(shinyWidgets)



sidebar <- dashboardSidebar(
    sidebarMenu(
        menuItem("Resultados", icon = icon("volleyball-ball"), tabName = "results"),
        menuItem("Sobre", icon = icon("info-circle"), tabName = "about"),
        shinyWidgets::pickerInput(inputId = "teams",
                                label = "Times",
                                choices = teams$Team,
                                multiple = T,
                                selected = teams$Team,
                                options = list(
                                    `actions-box` = TRUE))
        
        
    )
)

body <- dashboardBody(
    tabItems(
        tabItem(tabName = "results",
                fluidRow(
                    box("Geral"),
                    box("Por fase")
                )
        ),
        tabItem(tabName = "about"
                )
        )
 )

# Put them together into a dashboardPage
dashboardPage(
    dashboardHeader(title = "Superliga Sem Limites"),
    sidebar,
    body
)