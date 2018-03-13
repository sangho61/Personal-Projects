library(shiny)
library(dplyr)
library(ggplot2)

check <- (read.csv("NCAA/DataFiles/RegularSeasonDetailedResults.csv"))
regular_season_raw <- tbl_df(read.csv("NCAA/DataFiles/RegularSeasonDetailedResults.csv"))

regular_season_w <- regular_season_raw %>% 
  group_by(Season, WTeamID) %>% 
  summarize("NumWin" = n(), "WScore1" = sum(WScore), "LScore2" = sum(LScore), "WFGM" = sum(WFGM), 
            "WFGA" = sum(WFGA),"WFGM3" = sum(WFGM3), "WFGA3" = sum(WFGA3), "WFTM" = sum(WFTM), 
            "WFTA" = sum(WFTA), "WOR" = sum(WOR), "WDR" = sum(WDR), "WAst" = sum(WAst), "WTO" = sum(WTO),
            "WSTl" = sum(WStl), "WBlk" = sum(WBlk), "WPF" = sum(WPF))
            
head(regular_season_w)

regular_season_l <- regular_season_raw %>% 
  group_by(Season, LTeamID) %>% 
  summarize("NumLost" = n(), "WScore2" = sum(WScore), "LScore1" = sum(LScore), "LFGM" = sum(LFGM), 
            "LFGA" = sum(LFGA),"LFGM3" = sum(LFGM3), "LFGA3" = sum(LFGA3), "LFTM" = sum(LFTM), 
            "LFTA" = sum(LFTA), "LOR" = sum(LOR), "LDR" = sum(LDR), "LAst" = sum(LAst), "LTO" = sum(LTO),
            "LSTl" = sum(LStl), "LBlk" = sum(LBlk), "LPF" = sum(LPF))

regular_season_tot <- left_join(regular_season_w, regular_season_l,
                                by = c("Season" = "Season", "WTeamID" = "LTeamID"))
head(regular_season_tot)

regular_season_sum <- regular_season_tot %>% 
  mutate("GameT" = NumWin + NumLost, "ScoreT" = WScore1 + LScore1, "FGMT" = WFGM + LFGM, "FGAT" = WFGA + LFGA, 
         "FGM3" = WFGM3 + LFGM3, "FGA3" = WFGA3 + LFGA3, "FTM" = WFTM + LFTM, "FTA" = WFTA + LFTA, "OR" = WOR + LOR, 
         "DR" = WDR + LDR, "Ast" = WAst + LAst,"TO" = WTO + LTO, "Stl" = WSTl + LSTl, "Blk" = WBlk + LBlk, "PF" = WPF + LPF,
         "TO" = WTO + LTO,
         "Win%" = NumWin/GameT*100, "Avg.Score" = ScoreT/GameT, "FG%" = FGMT/FGAT*100, "3PT%"= FGM3/FGA3*100, 
         "FT%" = FTM/FTA*100,
         "Avg.Rebound_Off" = OR/GameT, "Avg.Rebound_Def" = DR/GameT, "Avg.Rebound_Total" = Avg.Rebound_Off + Avg.Rebound_Def,
         "Avg.Stl" = Stl/GameT, "Avg.Blk" = Blk/GameT, "Avg.PF" = PF/GameT, "Avg.TO" = TO/GameT, "Avg.FGM" = FGMT/GameT,
         "Avg.FGM3" = FGM3/GameT, "Avg.FTM"=FTM/GameT, "Avg.Ast" = Ast/GameT) %>% 
  select(Season, WTeamID, NumWin, NumLost, 'Win%', Avg.Score,'FG%', Avg.FGM , '3PT%', Avg.FGM3 , 'FT%', Avg.FTM, 
         Avg.Rebound_Off, Avg.Rebound_Def, 
         Avg.Rebound_Total,
         Avg.Stl, Avg.Blk, Avg.PF, Avg.TO, Avg.Ast)

regular_season_sum <- round(regular_season_sum, 2)

seeds <- tbl_df(read.csv("NCAA/DataFiles/NCAATourneyseeds.csv", stringsAsFactors = FALSE))

regular_season_sum <- regular_season_sum %>% left_join(seeds, by = c("Season"="Season","WTeamID" = "TeamID"))

teams <- tbl_df(read.csv("NCAA/DataFiles/Teams.csv", stringsAsFactors = FALSE))
head(teams)

regular_season_sum <- left_join(regular_season_sum, teams, by = c("WTeamID"="TeamID"))

conference <- tbl_df(read.csv("NCAA/DataFiles/TeamConferences.csv", stringsAsFactors = FALSE))
regular_season_sum <- left_join(regular_season_sum, conference, by = c("Season"="Season", "WTeamID"="TeamID"))

conference_name <- tbl_df(read.csv("NCAA/DataFiles/Conferences.csv", stringsAsFactors = FALSE))
regular_season_sum <- left_join(regular_season_sum, conference_name, by = "ConfAbbrev")

write.csv(regular_season_sum, "regular_sum3.csv")


regular_season_w %>% filter(Season == 2015, WTeamID == 1246)


ready <- tbl_df(read.csv("regular_sum3.csv", stringsAsFactors = FALSE))

ready1 <- ready %>% mutate(Seed = as.integer(Seed))
write.csv(ready1, "regular_db.csv")

glimpse(ready1)
summary(ready$NumWin)

