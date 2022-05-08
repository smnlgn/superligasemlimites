library(tidyverse)
library(rvest)
library(progress)
dict <- tibble( ids = c(## turno
  1245:1250, ## 1
  1311:1349, ## nao tem o 1350
    1351:1371, ## 2 a 11
  ## returno
  1435:1500, ## 1 a 11
  #quartas
  1507:1514, ## jogos 1 e 2
  1516, ## jogo 3
  ## semi,
  1531:1534, ## jogos 1 e 2,
  1535, #jogo 3,
  ## final
  1543, 1544),
  cat = c(rep("turno",66),rep("returno",66),rep("quartas",9), rep("semi",5), rep("final",2)),
  fase = c(rep("classificatoria", 132), rep("playoffs", 16)),
  ok = NA)
n <- nrow(dict)

get_home_info <- function(html) {
  stats <- html_nodes(html, xpath = '//*[@id="Content_Main_ctl17_RP_MatchStats_RPL_MatchStats_0"]/div[3]') |> 
    html_table(fill = TRUE)
  
  name <- html_nodes(html, xpath = '//*[@id="Content_Main_ctl17_RP_MatchStats_TeamName_Home_0"]') |> 
    html_text()
 
  if (length(stats) == 0) {
    stats <- tibble()
  } else {
    stats <- stats[[1]]
    n <- nrow(stats)-1 ## line with total
    m <- ncol(stats)
    names(stats) <- paste(names(stats), stats[1,])
    stats <- stats[2:n,2:m]
    names(stats)[1] <- "Player"
    stats$Team <- name
  }
  return(list(name = name, stats = stats))
}
get_guest_info <- function(html) {
  
  stats <- html_nodes(html, xpath = '//*[@id="Content_Main_ctl17_RP_MatchStats_RPL_MatchStats_0"]/div[5]') |> 
    html_table(fill = TRUE)
  name <- html_nodes(html, xpath = '//*[@id="Content_Main_ctl17_RP_MatchStats_TeamName_Guest_0"]') |> 
    html_text()

  if (length(stats) == 0 ) {
    stats <- tibble()
  } else {
    stats <- stats[[1]]
    n <- nrow(stats)-1 ## line with total
    m <- ncol(stats)
    names(stats) <- paste(names(stats), stats[1,])
    stats <- stats[2:n,2:m]
    names(stats)[1] <- "Player"
    stats$Team <- name
  }
  return(list(name = name, stats = stats))
}
find_winner <- function(home, guest, html) {

  score1 <- html_nodes(html, xpath = '//*[@id="Content_Main_LBL_WonSetHome"]') |> 
    html_text()
  score2 <- html_nodes(html, xpath = '//*[@id="Content_Main_LBL_WonSetGuest"]') |> 
    html_text()
  
  if (score1 > score2) {
    return(home)
  } else {
    return(guest)
  }
}

full_stats_list <- list()

pb <- progress::progress_bar$new(
  format = "[:bar] :percent eta: :eta",
  total = n)

start <- Sys.time()
for (i in 1:n) {
  pb$tick()
  
  id <- dict$ids[i]
  
  url <- paste0("https://cbv-web.dataproject.com/MatchStatistics.aspx?mID=",id, "&ID=14")
  html <- read_html(url)
  home <- get_home_info(html)
  guest <- get_guest_info(html)
  
  if (nrow(home$stats) == 0) {
    dict$ok[dict$ids == id] <- 0 ## no data available
  } else {
    dict$ok[dict$ids == id] <- 1
    match <- paste(home$name, "x", guest$name)
    winner <- find_winner(home$name, guest$name, html)
    
    
    full_stats <- rbind(home$stats, guest$stats) |> 
      mutate(Match = match,
             Winner = winner) |> 
      select(Player, Team, Match, Winner, 
             `Serviço Err`, `Serviço Ace`,
             `Recepção Tot`, `Recepção Err`,
             `Ataque Exc.`,  `Ataque Err`, `Ataque Blk`,
             `Bloqueio Pts`) |> 
      mutate(winner_ind = ifelse(Winner == Team, 1, 0),
             libero_ind = ifelse(grepl("\\(L\\)", Player), 1, 0)) |> 
      mutate(Fase = dict$fase[dict$ids == id],
             Cat = dict$cat[dict$ids == id],
             Jogo = i,
             id = id) 
    full_stats_list[[i]] <- full_stats
  }
}

end <- Sys.time()

full_stats <- bind_rows(full_stats_list)
full_stats[full_stats == "-"] <- NA

#writexl::write_xlsx(full_stats, "full_stats.xlsx")
save(full_stats, file = "full_stats.RData")
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



#####  geral #####

classificacao_geral <- full_stats |> 
  group_by(Player) |> 
  summarise(jogos = n(),
            Pontos = sum(total, na.rm = T),
            Média = Pontos/jogos)

#### fase ####

classificacao_fase <- full_stats |> 
  group_by(Fase, Player) |> 
  summarise(jogos = n(),
            Pontos = sum(total, na.rm = T),
            Média = Pontos/jogos) |> 
  arrange(Fase, desc(Média))


get_viva_volei <- function(page, x) {
  home <- page |> 
    html_nodes(xpath = paste0("/html/body/div[", x, "]/a[1]/h3[1]")) |> 
    html_text() ## home team
  guest <-page |> 
    html_nodes(xpath = paste0("/html/body/div[", x, "]/a[1]/h3[3]")) |> 
    html_text() ##guest team
  
  match <- paste(home, "x", guest)
  
  results <- page |> 
    html_nodes(xpath = paste0("/html/body/div[", x, "]/a[2]")) |>
    html_attr("href") ## link to results page
  url2 <- paste0('https://melhordojogo.cbv.com.br/', results)
  vv <- read_html(url2) |> 
    html_nodes(xpath = "/html/body/div[1]/h3/span[1]") |> 
    html_text() 
  vv <- sub(".*? ", "", vv)
  
  df <- tibble(match = match, viva_volei = vv)
  return(df)
}
  
  
vv_list <-list()
url <- 'https://melhordojogo.cbv.com.br/resultados.php'
page <- read_html(url)
i_ <- 1
for (i in seq(2,326,by=2)) {
  vv_list[[i_]] <- get_viva_volei(page, i)
  i_ <- i_+ 1
}
vv_df <-  bind_rows(vv_list)



partida <- full_stats |> 
  select(Match) |> 
  rename(match = Match) |> 
  distinct()

partida <- left_join(partida, vv_df)

