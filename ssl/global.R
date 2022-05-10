library(tidyverse)
library(reactablefmtr)
library(dashboardthemes)
library(markdown)


load("full_stats.RData")
full_stats <- full_stats_
logo <- read_csv2("logos.csv")
vv <- read_csv2("vivavolei.csv")

full_stats$Player <- stringi::stri_replace_all_fixed(
  full_stats$Player,
  pattern = c("MARYS DA SILVA LORRAYNA",
              "SOUZA THAISINHA",
              "AMANDA RODRIGUES",
              "CLAUDIA  BUENO",
              "STEFANIE TARRAGA",
              "OLIVEIRA PAMELA",
              "NASCIMENTO IVNA",
              '(L) (L)'),
  replacement = c("LORRAYNA MARYS DA SILVA",
                  "THAISINHA SOUZA",
                  "AMANDA RODRIGUES SEHN",
                  "CLAUDIA BUENO",
                  "STEFANIE TARRAGA (L)",
                  "PAMELLA OLIVEIRA",
                  "IVNA COLOMBO",
                  "(L)"),
  vectorize=FALSE)

teams <- full_stats |> select(Player, Team) |> distinct()


full_stats <- left_join(full_stats, vv) |> 
  mutate(VV = ifelse(VV == Player, 1, 0))

full_stats <- full_stats |> 
  select(-c(1:5)) |> ## sets
  mutate(libero_ind = ifelse(grepl("\\(L\\)", Player), 1, 0)) |> 
  mutate(across(5:12, as.numeric)) |> 
  mutate("Service Error" = `Serviço Err`*-8,
         "Service Ace" = `Serviço Ace`*12,
         "Attack Kill" = `Ataque Exc.`*8,
         "Attack Error" = (`Ataque Err` + `Ataque Blk`)*-12,
         "Dig" = ifelse(libero_ind == 1, (`Recepção Tot`- `Recepção Err`) *5,0),
         "Good Pass" = ifelse(libero_ind == 0, (`Recepção Tot` - `Recepção Err`) *2,0),
         "Pass Error" = `Recepção Err`*-12,
         "Block Stuff" = `Bloqueio Pts`*12,
         "Match Win" = ifelse(winner_ind == 1, 60,0),
         "MVP" = VV*60) |> 
  select(Player, Team, Match, Winner, 
         Fase, Cat, Jogo, id,
         `Service Error`, `Service Ace`,
         `Attack Kill`, `Attack Error`,
         Dig, `Good Pass`, `Pass Error`,
         `Block Stuff`, `Match Win`, MVP) 
full_stats$total <- rowSums(full_stats[,9:18], na.rm = T)

full_stats <- full_stats |> 
  filter(!(Player == "ODINA ALRYEVA"))

### creating custom theme object
customTheme <- shinyDashboardThemeDIY(
  
  ### general
  appFontFamily = "Arial"
  ,appFontColor = "rgb(45,45,45)"
  ,primaryFontColor = "rgb(15,15,15)"
  ,infoFontColor = "rgb(15,15,15)"
  ,successFontColor = "rgb(15,15,15)"
  ,warningFontColor = "rgb(15,15,15)"
  ,dangerFontColor = "rgb(15,15,15)"
  ,bodyBackColor = "rgb(240,240,240)"
  
  ### header
  ,logoBackColor = "#5d2b80"
  
  ,headerButtonBackColor = "#5d2b80"
  ,headerButtonIconColor = "rgb(220,220,220)"
  ,headerButtonBackColorHover = "rgb(100,100,100)"
  ,headerButtonIconColorHover = "rgb(60,60,60)"
  
  ,headerBackColor = "#5d2b80"
  ,headerBoxShadowColor = "#dfdfdf"
  ,headerBoxShadowSize = "3px 5px 5px"
  
  ### sidebar
  ,sidebarBackColor = "rgb(255,255,255)"
  ,sidebarPadding = 0
  
  ,sidebarMenuBackColor = "transparent"
  ,sidebarMenuPadding = 0
  ,sidebarMenuBorderRadius = 0
  
  ,sidebarShadowRadius = "3px 5px 5px"
  ,sidebarShadowColor = "#dfdfdf"
  
  ,sidebarUserTextColor = "rgb(115,115,115)"
  
  ,sidebarSearchBackColor = "rgb(240,240,240)"
  ,sidebarSearchIconColor = "rgb(100,100,100)"
  ,sidebarSearchBorderColor = "rgb(220,220,220)"
  
  ,sidebarTabTextColor = "rgb(100,100,100)"
  ,sidebarTabTextSize = 14
  ,sidebarTabBorderStyle = "none"
  ,sidebarTabBorderColor = "none"
  ,sidebarTabBorderWidth = 0
  
  ,sidebarTabBackColorSelected = "rgb(230,230,230)"
  ,sidebarTabTextColorSelected = "rgb(0,0,0)"
  ,sidebarTabRadiusSelected = "0px"
  
  ,sidebarTabBackColorHover = "rgb(245,245,245)"
  ,sidebarTabTextColorHover = "rgb(0,0,0)"
  ,sidebarTabBorderStyleHover = "none solid none none"
  ,sidebarTabBorderColorHover = "rgb(200,200,200)"
  ,sidebarTabBorderWidthHover = 4
  ,sidebarTabRadiusHover = "0px"
  
  ,boxBackColor = "rgb(248,248,248)"
  ,boxBorderRadius = 5
  ,boxShadowSize = "none"
  ,boxShadowColor = ""
  ,boxTitleSize = 18
  ,boxDefaultColor = "rgb(225,225,225)"
  ,boxPrimaryColor = "rgb(95,155,213)"
  ,boxInfoColor = "rgb(180,180,180)"
  ,boxSuccessColor = "rgb(112,173,71)"
  ,boxWarningColor = "rgb(237,125,49)"
  ,boxDangerColor = "rgb(232,76,34)"
  
  ,tabBoxTabColor = "rgb(248,248,248)"
  ,tabBoxTabTextSize = 14
  ,tabBoxTabTextColor = "rgb(100,100,100)"
  ,tabBoxTabTextColorSelected = "rgb(45,45,45)"
  ,tabBoxBackColor = "rgb(248,248,248)"
  ,tabBoxHighlightColor = "rgb(200,200,200)"
  ,tabBoxBorderRadius = 5
  
  ### inputs
  ,buttonBackColor = "rgb(215,215,215)"
  ,buttonTextColor = "rgb(45,45,45)"
  ,buttonBorderColor = "rgb(150,150,150)"
  ,buttonBorderRadius = 5
  
  ,buttonBackColorHover = "rgb(190,190,190)"
  ,buttonTextColorHover = "rgb(0,0,0)"
  ,buttonBorderColorHover = "rgb(150,150,150)"
  
  ,textboxBackColor = "rgb(255,255,255)"
  ,textboxBorderColor = "rgb(118,118,118)"
  ,textboxBorderRadius = 5
  ,textboxBackColorSelect = "rgb(245,245,245)"
  ,textboxBorderColorSelect = "rgb(108,108,108)"
  
  ### tables
  ,tableBackColor = "rgb(248,248,248)"
  ,tableBorderColor = "rgb(238,238,238)"
  ,tableBorderTopSize = 1
  ,tableBorderRowSize = 1
  
)