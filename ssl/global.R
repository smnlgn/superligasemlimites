library(tidyverse)
library(reactablefmtr)

load("full_stats.Rdata")
full_stats <- full_stats_
logo <- read_csv2("logos.csv")
teams <- full_stats |> select(Player, Team) |> distinct()

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
         "Match Win" = ifelse(winner_ind == 1, 60,0)) |> 
  select(Player, Team, Match, Winner, 
         Fase, Cat, Jogo, id,
         `Service Error`, `Service Ace`,
         `Attack Kill`, `Attack Error`,
         Dig, `Good Pass`, `Pass Error`,
         `Block Stuff`, `Match Win`) 
full_stats$total <- rowSums(full_stats[,9:17], na.rm = T)

full_stats <- full_stats |> 
  filter(!(Player == "ODINA ALRYEVA"))

# classificacao_geral <- full_stats |> 
#   group_by(Player) |> 
#   summarise(jogos = n(),
#             Pontos = sum(total, na.rm = T),
#             Média = round(Pontos/jogos,2))
# classificacao_geral <- left_join(classificacao_geral, teams)
# classificacao_geral <- left_join(classificacao_geral, logo, 
#                                  by = c("Team" = "TEAM"))
# 
# classificacao_geral <- classificacao_geral |> 
#   select(Player, Team, LOGO, jogos, Pontos, Média) 



## geral 

# classificacao_geral |> 
#   select(-Team) |> 
#   arrange(desc(Média)) |> 
#   reactable(searchable = TRUE,
#             rownames = TRUE,
#             columnGroups = list(
#               colGroup(name = "Pontuação", columns = c("Pontos","Média"))
#             ),
#             columns = list(
#               LOGO = colDef(
#                 cell = embed_img(
#                 height = "50", width = "50"),
#                 width = 60,
#                 name = "Time",
#                 align = "center"),
#               Player = colDef(width = 200,
#                      name = "Nome",
#                      align = "center"),
#               jogos = colDef(width = 60,
#                               name = "Jogos",
#                               align = "center",
#                              style = list(
#                                borderLeft = "1px dashed rgba(0, 0, 0, 0.3)")),
#               Pontos = colDef(width = 70,
#                               name = "Total",
#                               align = "center"),
#               Média = colDef(width = 70,
#                               name = "Média",
#                               align = "center")
#             ),
#           theme = fivethirtyeight(centered = TRUE, header_font_size = 11),
#           language = reactableLang(
#             searchPlaceholder = "...",
#             noData = "No entries found",
#             pageInfo = "{rowStart}\u2013{rowEnd} de {rows}",
#             pagePrevious = "\u276e",
#             pageNext = "\u276f")
#           )

