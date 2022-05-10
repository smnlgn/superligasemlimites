library(shiny)
library(shinydashboard)
library(shinyWidgets)
library(dashboardthemes)
library(markdown)




sidebar <- dashboardSidebar(
    sidebarMenu(
        menuItem("Resultados", icon = icon("volleyball-ball"), tabName = "results"),
        menuItem("Sobre", icon = icon("info-circle"), tabName = "about"),
        shinyWidgets::pickerInput(inputId = "teams",
                                label = "Times",
                                choices = unique(teams$Team),
                                multiple = T,
                                selected =unique(teams$Team),
                                options = list(
                                    `actions-box` = TRUE))
        )
    )

body <- dashboardBody(
    customTheme,
    tabItems(
        tabItem(tabName = "results",
                fluidRow(
                    tabBox(width = 12,
                    tabPanel("Geral",
                        reactable::reactableOutput("resultGeral")),
                    tabPanel("Classificatória",
                             reactable::reactableOutput("resultClass")),
                    tabPanel("Playoffs",
                             reactable::reactableOutput("resultPlay"))
                ))
        ),
        tabItem(tabName = "about",
                fluidRow(
                    column(width = 2),
                    column(width = 10,
                           align="left",
                           box(width = 10,
                           includeMarkdown("readme.md"))),
                    column(width = 2)
                ))
        )
 )

# Put them together into a dashboardPage
dashboardPage(
    dashboardHeader(title = "Superliga Sem Limites"),
    sidebar,
    body
)