library(shiny)

# Define server logic required to draw a histogram
shinyServer(function(input, output) {
  
  teams_selected <- reactive(input$teams)
  
  classificacao_geral <- reactive({
    
    classificacao_geral <- full_stats |> 
      filter(Team %in% teams_selected()) |> 
      group_by(Player) |> 
      summarise(jogos = n(),
                Pontos = sum(total, na.rm = T),
                Média = round(Pontos/jogos,2),
                ServiceErro = sum(`Service Error`, na.rm = T),
                ServiceAce = sum(`Service Ace`, na.rm = T),
                AttackKill = sum(`Attack Kill`, na.rm = T),
                AttackError = sum(`Attack Error`, na.rm = T),
                Dig = sum(`Dig`, na.rm = T),
                GoodPass = sum(`Good Pass`, na.rm = T),
                PassError = sum(`Pass Error`, na.rm = T),
                BlockStuff = sum(`Block Stuff`, na.rm = T),
                MatchWin = sum(`Match Win`, na.rm = T),
                MVP = sum(MVP, na.rm = T)
      )
    
    classificacao_geral <- left_join(classificacao_geral, teams)
    classificacao_geral <- left_join(classificacao_geral, logo, 
                                     by = c("Team" = "TEAM"))
    
    classificacao_geral <- classificacao_geral |> 
      select(Player, Team, LOGO, jogos, Pontos, Média,
             ServiceErro, ServiceAce, AttackKill, AttackError,
             Dig, GoodPass, PassError, BlockStuff, MatchWin, MVP) 
  })
  
  classificacao_fases <- reactive({
    
    classificatoria <- full_stats |> 
      filter(Fase == "classificatoria") |> 
      filter(Team %in% teams_selected()) |> 
      group_by(Player) |> 
      summarise(jogos = n(),
                Pontos = sum(total, na.rm = T),
                Média = round(Pontos/jogos,2),
                ServiceErro = sum(`Service Error`, na.rm = T),
                ServiceAce = sum(`Service Ace`, na.rm = T),
                AttackKill = sum(`Attack Kill`, na.rm = T),
                AttackError = sum(`Attack Error`, na.rm = T),
                Dig = sum(`Dig`, na.rm = T),
                GoodPass = sum(`Good Pass`, na.rm = T),
                PassError = sum(`Pass Error`, na.rm = T),
                BlockStuff = sum(`Block Stuff`, na.rm = T),
                MatchWin = sum(`Match Win`, na.rm = T),
                MVP = sum(MVP, na.rm = T)
                )
                
                
    classificatoria <- left_join(classificatoria, teams)
    classificatoria <- left_join(classificatoria, logo, 
                                     by = c("Team" = "TEAM"))
    
    classificatoria <- classificatoria |> 
      select(Player, Team, LOGO, jogos, Pontos, Média,
             ServiceErro, ServiceAce, AttackKill, AttackError,
             Dig, GoodPass, PassError, BlockStuff, MatchWin, MVP) 
    
    playoffs <- full_stats |> 
      filter(Fase == "playoffs") |> 
      filter(Team %in% teams_selected()) |> 
      group_by(Player) |> 
      summarise(jogos = n(),
                Pontos = sum(total, na.rm = T),
                Média = round(Pontos/jogos,2),
                ServiceErro = sum(`Service Error`, na.rm = T),
                ServiceAce = sum(`Service Ace`, na.rm = T),
                AttackKill = sum(`Attack Kill`, na.rm = T),
                AttackError = sum(`Attack Error`, na.rm = T),
                Dig = sum(`Dig`, na.rm = T),
                GoodPass = sum(`Good Pass`, na.rm = T),
                PassError = sum(`Pass Error`, na.rm = T),
                BlockStuff = sum(`Block Stuff`, na.rm = T),
                MatchWin = sum(`Match Win`, na.rm = T),
                MVP = sum(MVP, na.rm = T)
      )
    
    playoffs <- left_join(playoffs, teams)
    playoffs <- left_join(playoffs, logo, 
                                 by = c("Team" = "TEAM"))
    
    playoffs <- playoffs |> 
      select(Player, Team, LOGO, jogos, Pontos, Média,
             ServiceErro, ServiceAce, AttackKill, AttackError,
             Dig, GoodPass, PassError, BlockStuff, MatchWin, MVP) 
    
    return(list(classificatoria = classificatoria,
                playoffs = playoffs))
    
    
  })
    
  output$resultGeral <- reactable::renderReactable({
    
    classificacao_geral() |> 
      select(-Team) |> 
      arrange(desc(Pontos)) |> 
      reactable(searchable = TRUE,
                rownames = TRUE,
                columnGroups = list(
                  colGroup(name = "Pontuação", columns = c("Pontos","Média")),
                  colGroup(name = "Saque", columns = c("ServiceErro","ServiceAce")),
                  colGroup(name = "Ataque", columns = c("AttackKill","AttackError")),
                  colGroup(name = "Recepção", columns = c("Dig","GoodPass", "PassError"))
                ),
                columns = list(
                  LOGO = colDef(
                    cell = embed_img(
                      height = "50", width = "50"),
                    width = 60,
                    name = "Time",
                    align = "center"),
                  Player = colDef(#width = 200,
                                  name = "Nome",
                                  align = "center"),
                  jogos = colDef(width = 60,
                                 name = "Jogos",
                                 align = "center",
                                 style = list(
                                   borderLeft = "1px dashed rgba(0, 0, 0, 0.3)")),
                  Pontos = colDef(#width = 70,
                                  name = "Total",
                                  align = "center",
                                  cell = color_tiles(
                                    classificacao_geral(),
                                    colors = viridis::viridis(3, direction = -1))
                  ),
                  Média = colDef(#width = 70,
                                 name = "Média",
                                 align = "center",
                                 cell = color_tiles(
                                   classificacao_geral(),
                                   colors = viridis::viridis(3, direction = -1))
                  ),
                  ServiceErro = colDef(#width = 200,
                    name = "Erro",
                    align = "center"),
                  ServiceAce = colDef(#width = 200,
                    name = "Ace",
                    align = "center"),
                  AttackKill = colDef(#width = 200,
                    name = "Executado",
                    align = "center"),
                  AttackError = colDef(#width = 200,
                    name = "Erro",
                    align = "center"),
                  Dig = colDef(#width = 200,
                    name = "Dig",
                    align = "center"),
                  GoodPass = colDef(#width = 200,
                    name = "Recepção",
                    align = "center"),
                  PassError = colDef(#width = 200,
                    name = "Erro",
                    align = "center"),
                  BlockStuff = colDef(#width = 200,
                    name = "Bloqueios",
                    align = "center"),
                  MatchWin = colDef(#width = 200,
                    name = "Partidas Vencidas",
                    align = "center"),
                  MVP = colDef(#width = 200,
                    name = "Viva Volêi",
                    align = "center"),
                  .rownames  = colDef(width = 20)
                ),
                theme = fivethirtyeight(centered = TRUE, header_font_size = 11),
                language = reactableLang(
                  searchPlaceholder = "...",
                  noData = "No entries found",
                  pageInfo = "{rowStart}\u2013{rowEnd} de {rows}",
                  pagePrevious = "\u276e",
                  pageNext = "\u276f")
      )
    
  })
  
  output$resultClass <- reactable::renderReactable({
    
    classificacao_fases()$classificatoria |> 
      select(-Team) |> 
      arrange(desc(Pontos)) |> 
      reactable(searchable = TRUE,
                rownames = TRUE,
                columnGroups = list(
                  colGroup(name = "Pontuação", columns = c("Pontos","Média")),
                  colGroup(name = "Saque", columns = c("ServiceErro","ServiceAce")),
                  colGroup(name = "Ataque", columns = c("AttackKill","AttackError")),
                  colGroup(name = "Recepção", columns = c("Dig","GoodPass", "PassError"))
                ),
                columns = list(
                  LOGO = colDef(
                    cell = embed_img(
                      height = "50", width = "50"),
                    width = 60,
                    name = "Time",
                    align = "center"),
                  Player = colDef(#width = 200,
                    name = "Nome",
                    align = "center"),
                  jogos = colDef(width = 60,
                                 name = "Jogos",
                                 align = "center",
                                 style = list(
                                   borderLeft = "1px dashed rgba(0, 0, 0, 0.3)")),
                  Pontos = colDef(#width = 70,
                    name = "Total",
                    align = "center",
                    cell = color_tiles(
                      classificacao_fases()$classificatoria,
                      colors = viridis::viridis(3, direction = -1))
                  ),
                  Média = colDef(#width = 70,
                    name = "Média",
                    align = "center",
                    cell = color_tiles(
                      classificacao_fases()$classificatoria,
                      colors = viridis::viridis(3, direction = -1)),
                  ),
                  ServiceErro = colDef(#width = 200,
                    name = "Erro",
                    align = "center"),
                  ServiceAce = colDef(#width = 200,
                    name = "Ace",
                    align = "center"),
                  AttackKill = colDef(#width = 200,
                    name = "Executado",
                    align = "center"),
                  AttackError = colDef(#width = 200,
                    name = "Erro",
                    align = "center"),
                  Dig = colDef(#width = 200,
                    name = "Dig",
                    align = "center"),
                  GoodPass = colDef(#width = 200,
                    name = "Recepção",
                    align = "center"),
                  PassError = colDef(#width = 200,
                    name = "Erro",
                    align = "center"),
                  BlockStuff = colDef(#width = 200,
                    name = "Bloqueios",
                    align = "center"),
                  MatchWin = colDef(#width = 200,
                    name = "Partidas Vencidas",
                    align = "center"),
                  MVP = colDef(#width = 200,
                    name = "Viva Volêi",
                    align = "center"),
                  .rownames  = colDef(width = 20)
                ),
                theme = fivethirtyeight(centered = TRUE, header_font_size = 11),
                language = reactableLang(
                  searchPlaceholder = "...",
                  noData = "No entries found",
                  pageInfo = "{rowStart}\u2013{rowEnd} de {rows}",
                  pagePrevious = "\u276e",
                  pageNext = "\u276f")
      )
    
  })
  
  output$resultPlay <- reactable::renderReactable({
    
    classificacao_fases()$playoffs |> 
      select(-Team) |> 
      arrange(desc(Pontos)) |> 
      reactable(searchable = TRUE,
                rownames = TRUE,
                columnGroups = list(
                  colGroup(name = "Pontuação", columns = c("Pontos","Média")),
                  colGroup(name = "Saque", columns = c("ServiceErro","ServiceAce")),
                  colGroup(name = "Ataque", columns = c("AttackKill","AttackError")),
                  colGroup(name = "Recepção", columns = c("Dig","GoodPass", "PassError"))
                ),
                columns = list(
                  LOGO = colDef(
                    cell = embed_img(
                      height = "50", width = "50"),
                    width = 60,
                    name = "Time",
                    align = "center"),
                  Player = colDef(#width = 200,
                    name = "Nome",
                    align = "center"),
                  jogos = colDef(width = 60,
                                 name = "Jogos",
                                 align = "center",
                                 style = list(
                                   borderLeft = "1px dashed rgba(0, 0, 0, 0.3)")),
                  Pontos = colDef(#width = 70,
                    name = "Total",
                    align = "center",
                    cell = color_tiles(
                      classificacao_fases()$playoffs,
                      colors = viridis::viridis(3, direction = -1))
                  ),
                  Média = colDef(#width = 70,
                    name = "Média",
                    align = "center",
                    cell = color_tiles(
                      classificacao_fases()$playoffs,
                      colors = viridis::viridis(3, direction = -1))
                  ),
                  ServiceErro = colDef(#width = 200,
                    name = "Erro",
                    align = "center"),
                  ServiceAce = colDef(#width = 200,
                    name = "Ace",
                    align = "center"),
                  AttackKill = colDef(#width = 200,
                    name = "Executado",
                    align = "center"),
                  AttackError = colDef(#width = 200,
                    name = "Erro",
                    align = "center"),
                  Dig = colDef(#width = 200,
                    name = "Dig",
                    align = "center"),
                  GoodPass = colDef(#width = 200,
                    name = "Recepção",
                    align = "center"),
                  PassError = colDef(#width = 200,
                    name = "Erro",
                    align = "center"),
                  BlockStuff = colDef(#width = 200,
                    name = "Bloqueios",
                    align = "center"),
                  MatchWin = colDef(#width = 200,
                    name = "Partidas Vencidas",
                    align = "center"),
                  MVP = colDef(#width = 200,
                    name = "Viva Volêi",
                    align = "center"),
                  .rownames  = colDef(width = 20)
                ),
                theme = fivethirtyeight(centered = TRUE, header_font_size = 11),
                language = reactableLang(
                  searchPlaceholder = "...",
                  noData = "No entries found",
                  pageInfo = "{rowStart}\u2013{rowEnd} de {rows}",
                  pagePrevious = "\u276e",
                  pageNext = "\u276f")
      )
      
    
  })


})
