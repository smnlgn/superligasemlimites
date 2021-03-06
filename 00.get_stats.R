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
      select(`SET 1`, `SET 2`, `SET 3`, `SET 4`, `SET 5`,
             Player, Team, Match, Winner, 
             `Serviço Err`, `Serviço Ace`,
             `Recepção Tot`, `Recepção Err`,
             `Ataque Exc.`,  `Ataque Err`, `Ataque Blk`,
             `Bloqueio Pts`) |> 
      mutate(winner_ind = ifelse(Winner == Team, 1, 0)) |> 
      mutate(Fase = dict$fase[dict$ids == id],
             Cat = dict$cat[dict$ids == id],
             Jogo = i,
             id = id)  |> 
      mutate(`SET 1` = as.character(`SET 1`), 
             `SET 2` = as.character(`SET 2`),  
             `SET 3` = as.character(`SET 3`), 
             `SET 4` = as.character(`SET 4`), 
             `SET 5` = as.character(`SET 5`))
    full_stats_list[[i]] <- full_stats
  }
}
end <- Sys.time()

full_stats <- bind_rows(full_stats_list)
full_stats[full_stats == ""] = NA
full_stats[full_stats == "-"] <- NA


full_stats_ <- full_stats |> 
  filter(if_any(c(`SET 1`:`SET 5`),  ~ !is.na(.))) ## sem reservas que nao jogaram 
full_stats_ <- full_stats_ |> 
  mutate(libero_ind = ifelse(grepl("\\(L\\)", Player), 1, 0),
         Team = gsub("SAUDE", "SAÚDE", Team))

full_stats_$Player <- stringi::stri_replace_all_fixed(
  full_stats_$Player,
  pattern = c("CEREM KAPUCU",
              "KAPACU CEREN",
              "KAPUCU CEREM",
              "KAPUCU CEREN",
              "CUSTODIO THAIS",
              "DANIELA LEAL", 
              "FERNANDA GUIMARAES SANTOS (L)",
              "FERNANDA GUIMARAES SANTOS",
              "FERNANDA GUIMARAESDOS SANTOS",
              "ivina ivina",
              "IVNA MARRA",
              "JOYCE GOMES",
              "joycinha J",
              "JOYCE SILVA",
              "JULIA MOREIRA",
              "KEYLA RAMALHO (L)",
              "LAIS ZURLY VASQUES",
              "LETICIA GOMES",
              "MARCELLE SILVA",
              "MELISSA  RANGEL PAEZ",
              "PAMELLA  OLIVEIRA",
              "PAULA PANNO",
              "PAULINA  DE SOUZA",
              "VITORIA PARISE",
              "REED NIA",
              "MARYS DA SILVA LORRAYNA",
              "SOUZA THAISINHA",
              "AMANDA RODRIGUES",
              "CLAUDIA  BUENO",
              "STEFANIE TARRAGA",
              "OLIVEIRA PAMELA",
              "NASCIMENTO IVNA",
              "(L) (L)"),
  replacement = c("CEREN KAPUCU", 
                  "CEREN KAPUCU", 
                  "CEREN KAPUCU", 
                  "CEREN KAPUCU", 
                  "THAISINHA SOUZA",
                  "DANIELA LEAL (L)", 
                  "FERNANDA GUIMARÃES",
                  "FERNANDA GUIMARÃES",
                  "FERNANDA GUIMARÃES",
                  "IVNA COLOMBO",
                  "IVNA COLOMBO",
                  "JOYCYNHA SILVA",
                  "JOYCYNHA SILVA",
                  "JOYCYNHA SILVA",
                  "JULIA MOREIRA (L)",
                  "KEYLA RAMALHO",
                  "LAIS ZURLY VASQUES (L)",
                  "LETICIA GOMES (L)",
                  "MARCELLE SILVA (L)",
                  "MELISSA RANGEL PAEZ",
                  "PAMELLA OLIVEIRA",
                  "PAULA PANNO (L)",
                  "PAULINA  DE SOUZA (L)",
                  "VITORIA PARISE (L)",
                  "NIA REED",
                  "LORRAYNA MARYS DA SILVA",
                  "THAISINHA SOUZA",
                  "AMANDA RODRIGUES SEHN",
                  "CLAUDIA BUENO",
                  "STEFANIE TARRAGA (L)",
                  "PAMELLA OLIVEIRA",
                  "IVNA COLOMBO",
                  "(L)"),
  vectorize=FALSE)
  
players <- full_stats_ |> group_by(Player, Team) |> count()


writexl::write_xlsx(full_stats, "full_stats_clean.xlsx")
save(full_stats_, file = "full_stats.RData")


