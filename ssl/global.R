library(tidyverse)

load("full_stats.Rdata")

teams <- full_stats |> select(Player, Team) |> unique()
full_stats <- full_stats |> 
  mutate(across(5:12, as.numeric)) |> 
  mutate("Service Error" = `Serviço Err`*-8,
         "Service Ace" = `Serviço Ace`*12,
         "Attack Kill" = `Ataque Exc.`*8,
         "Attack Error" = (`Ataque Err` + `Ataque Blk`)*-12,
         "Dig" = ifelse(libero_ind == 1, `Recepção Tot`*5,0),
         "Good Pass" = ifelse(libero_ind == 0, `Recepção Tot`*2,0),
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



classificacao_geral <- full_stats |> 
  group_by(Player) |> 
  summarise(jogos = n(),
            Pontos = sum(total, na.rm = T),
            Média = Pontos/jogos)
classificacao_geral <- left_join(classificacao_geral, teams)


## geral 


