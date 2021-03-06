
library(shiny)
library(shinydashboard)
library(tidyverse)
library(viridis)
library(plotly)

library(ggplot2)
library(htmlwidgets)
library(shinyWidgets)
library(dplyr)
library(readr)
library(ggthemes)

library(kableExtra)
library(ggdendro)
library(maps)

library(DT)

#reading in the data
medals <- read.csv("olympic_medals.csv")

#eliminating irrelevant variables, combing for entry errors
medals2 <- subset(medals, select = c(1, 2, 4, 5, 7))
medals3 <- medals2[-c(156, 158, 160, 320, 322, 324, 1664, 1666, 1668, 1793, 1795, 1797),]

#fixing 2016 10k from USA to GBR
medals3[1,]$Nationality <- "GBR"

medals4 <- medals3
#changing USSR competitors to Russia
medals4[medals4$Nationality == "URS",]$Nationality <- "RUS"
#changing all iterations of German teams to GER
medals4[medals4$Nationality == "EUA",]$Nationality <- "GER"
medals4[medals4$Nationality == "GDR",]$Nationality <- "GER"
medals4[medals4$Nationality == "FRG",]$Nationality <- "GER"
#sort(table(medals4$Nationality), decreasing = TRUE)

#pulling top 5 medal countries
top5 <- sort(c(which(medals4$Nationality == "USA"), which(medals4$Nationality == "GER"), which(medals4$Nationality == "RUS"), which(medals4$Nationality == "GBR"), which(medals4$Nationality == "KEN")))
medals5 <- medals4[top5, ]
medals5 <- medals5[order(medals5$Year),]
rownames(medals5) <- NULL
medals6 <- subset(medals5, select = c(3, 4, 5))

#creating new dataframe that considers number of medals per Games
years <- rep(unique(medals6$Year), times = 5)
nats <- sort(rep(unique(medals6$Nationality), times = length(unique(medals6$Year))))
count <- numeric(length = length(nats))
cumul <- numeric(length = length(nats))
g_count <- numeric(length = length(nats))
g_cumul <- numeric(length = length(nats))

medals7 <- data.frame(years, nats, count, cumul, g_count, g_cumul)
oly_years <- years[1:28]
i <- 1896; j <- 1
for(i in oly_years){
  medals7$count[j] <- length(which((medals6$Year == i) & (medals6$Nationality == "GBR")))
  medals7$cumul[j] <- sum(medals7$count[1:j])
  medals7$g_count[j] <- length(which((medals6$Year == i) & (medals6$Nationality == "GBR") & medals6$Medal == "G"))
  medals7$g_cumul[j] <- sum(medals7$g_count[1:j])     
  j <- j + 1
}

for(i in oly_years){
  medals7$count[j] <- length(which((medals6$Year == i) & (medals6$Nationality == "GER")))
  medals7$cumul[j] <- sum(medals7$count[29:j])
  medals7$g_count[j] <- length(which((medals6$Year == i) & (medals6$Nationality == "GER") & medals6$Medal == "G"))
  medals7$g_cumul[j] <- sum(medals7$g_count[29:j])   
  j <- j + 1
}
for(i in oly_years){
  medals7$count[j] <- length(which((medals6$Year == i) & (medals6$Nationality == "KEN")))
  medals7$cumul[j] <- sum(medals7$count[57:j])
  medals7$g_count[j] <- length(which((medals6$Year == i) & (medals6$Nationality == "KEN") & medals6$Medal == "G"))
  medals7$g_cumul[j] <- sum(medals7$g_count[57:j])   
  j <- j + 1
}
for(i in oly_years){
  medals7$count[j] <- length(which((medals6$Year == i) & (medals6$Nationality == "RUS")))
  medals7$cumul[j] <- sum(medals7$count[85:j])
  medals7$g_count[j] <- length(which((medals6$Year == i) & (medals6$Nationality == "RUS") & medals6$Medal == "G"))
  medals7$g_cumul[j] <- sum(medals7$g_count[85:j])   
  j <- j + 1
}
for(i in oly_years){
  medals7$count[j] <- length(which((medals6$Year == i) & (medals6$Nationality == "USA")))
  medals7$cumul[j] <- sum(medals7$count[113:j])
  medals7$g_count[j] <- length(which((medals6$Year == i) & (medals6$Nationality == "USA") & medals6$Medal == "G"))
  medals7$g_cumul[j] <- sum(medals7$g_count[113:j])   
  j <- j + 1
}


#font size etc to use for subplot titles
f <- list(
  family = "Courier New, monospace",
  size = 18,
  color = "black")

#all medal plots
ply_cumul <- plot_ly(medals7, 
                     x = ~years,
                     y = ~cumul,
                     color = nats,
                     type = 'scatter',
                     mode = 'lines',
                     width = 650, height = 600
) %>%
  layout(yaxis = list(title = "Cumulative Medals"))

ply_count <- plot_ly(medals7,
                     x = ~years,
                     y = ~count,
                     color = nats,
                     type = 'scatter',
                     mode = 'markers',
                     width = 650, height = 600
) %>%
  layout(yaxis = list(title = "Medals per Games"))

a <- list(
  text = "All Medals",
  font = f,
  xref = "paper",
  yref = "paper",
  yanchor = "bottom",
  xanchor = "center",
  align = "center",
  x = 0.5,
  y = 1,
  showarrow = FALSE)

ply_stack <- subplot(list(ply_cumul, ply_count),
                     nrows = 2,
                     shareX = TRUE,
                     titleY = TRUE) %>%
  layout(annotations = a,
         showlegend = FALSE) %>%
  rangeslider()

#Gold medal plots
ply_cumul_g <- plot_ly(medals7, 
                       x = ~years,
                       y = ~g_cumul,
                       color = nats,
                       type = 'scatter',
                       mode = 'lines',
                       width = 650, height = 600
)

ply_count_g <- plot_ly(medals7,
                       x = ~years,
                       y = ~g_count,
                       color = nats,
                       type = 'scatter',
                       mode = 'markers',
                       width = 650, height = 600
)
b <- list(
  text = "Gold Medals",
  font = f,
  xref = "paper",
  yref = "paper",
  yanchor = "bottom",
  xanchor = "center",
  align = "center",
  x = 0.5,
  y = 1,
  showarrow = FALSE)

ply_stack_g <- subplot(list(ply_cumul_g, ply_count_g),
                       nrows = 2,
                       shareX = TRUE,
                       titleY = FALSE)%>%
  layout(annotations = b,
         showlegend = FALSE) %>%
  rangeslider()

#combining both vertical stacks
all_ply_stack <- subplot(list(ply_stack, ply_stack_g),
                         titleY = TRUE) %>%
  layout(showlegend = FALSE)
#all_ply_stack

#adding full country name to match worldmap data
Country <- rep(NA, times = length(medals4$Nationality))
medals5 <- cbind(medals4, Country)
medals5[medals5$Nationality == "GBR",]$Country <- "Great Britain"
medals5[medals5$Nationality == "KEN",]$Country <- "Kenya"
medals5[medals5$Nationality == "ETH",]$Country <- "Ethiopia"
medals5[medals5$Nationality == "MAR",]$Country <- "Morocco"
medals5[medals5$Nationality == "ITA",]$Country <- "Italy"
medals5[medals5$Nationality == "FIN",]$Country <- "Finland"
medals5[medals5$Nationality == "POR",]$Country <- "Portugal"
medals5[medals5$Nationality == "TUN",]$Country <- "Tunisia"
medals5[medals5$Nationality == "RUS",]$Country <- "Russia"
medals5[medals5$Nationality == "GER",]$Country <- "Germany"
medals5[medals5$Nationality == "AUS",]$Country <- "Australia"
medals5[medals5$Nationality == "TCH",]$Country <- NA
medals5[medals5$Nationality == "FRA",]$Country <- "France"
medals5[medals5$Nationality == "SWE",]$Country <- "Sweden"
medals5[medals5$Nationality == "USA",]$Country <- "USA"
medals5[medals5$Nationality == "ERI",]$Country <- "Eritrea"
medals5[medals5$Nationality == "BEL",]$Country <- "Belgium"
medals5[medals5$Nationality == "HUN",]$Country <- "Hungary"
medals5[medals5$Nationality == "POL",]$Country <- "Poland"
medals5[medals5$Nationality == "JAM",]$Country <- "Jamaica"
medals5[medals5$Nationality == "CAN",]$Country <- "Canada"
medals5[medals5$Nationality == "TTO",]$Country <- "Trinidad and Tobago"
medals5[medals5$Nationality == "BAR",]$Country <- "Barbados"
medals5[medals5$Nationality == "NAM",]$Country <- "Namibia"
medals5[medals5$Nationality == "NED",]$Country <- "Netherlands"
medals5[medals5$Nationality == "RSA",]$Country <- "South Africa"
medals5[medals5$Nationality == "CUB",]$Country <- "Cuba"
medals5[medals5$Nationality == "BUL",]$Country <- "Bulgaria"
medals5[medals5$Nationality == "PAN",]$Country <- "Panama"
medals5[medals5$Nationality == "NZL",]$Country <- "New Zealand"
medals5[medals5$Nationality == "ESP",]$Country <- "Spain"
medals5[medals5$Nationality == "CHN",]$Country <- "China"
medals5[medals5$Nationality == "ALG",]$Country <- "Algeria"
medals5[medals5$Nationality == "QAT",]$Country <- "Qatar"
medals5[medals5$Nationality == "LUX",]$Country <- "Luxembourg"
medals5[medals5$Nationality == "IRL",]$Country <- "Ireland"
medals5[medals5$Nationality == "SUI",]$Country <- "Switzerland"
medals5[medals5$Nationality == "GRE",]$Country <- "Greece"
medals5[medals5$Nationality == "IND",]$Country <- "India"
medals5[medals5$Nationality == "ECU",]$Country <- "Ecuador"
medals5[medals5$Nationality == "MEX",]$Country <- "Mexico"
medals5[medals5$Nationality == "GUA",]$Country <- "Guatemala"
medals5[medals5$Nationality == "TAN",]$Country <- "Tanzania"
medals5[medals5$Nationality == "NOR",]$Country <- "Norway"
medals5[medals5$Nationality == "TUR",]$Country <- "Turkey"
medals5[medals5$Nationality == "KSA",]$Country <- "Saudi Arabia"
medals5[medals5$Nationality == "PHI",]$Country <- "Philippines"
medals5[medals5$Nationality == "DOM",]$Country <- "Dominican Republic"
medals5[medals5$Nationality == "PUR",]$Country <- "Puerto Rico"
medals5[medals5$Nationality == "ZAM",]$Country <- "Zambia"
medals5[medals5$Nationality == "UGA",]$Country <- "Uganda"
medals5[medals5$Nationality == "SRI",]$Country <- "Sri Lanka"
medals5[medals5$Nationality == "GRN",]$Country <- "Grenada"
medals5[medals5$Nationality == "CIV",]$Country <- "Ivory Coast"
medals5[medals5$Nationality == "DEN",]$Country <- "Denmark"
medals5[medals5$Nationality == "JPN",]$Country <- "Japan"
medals5[medals5$Nationality == "BRA",]$Country <- "Brazil"
medals5[medals5$Nationality == "NGR",]$Country <- "Niger"
medals5[medals5$Nationality == "BWI",]$Country <- NA
medals5[medals5$Nationality == "BDI",]$Country <- "Burundi"
medals5[medals5$Nationality == "SVK",]$Country <- "Slovakia"
medals5[medals5$Nationality == "LAT",]$Country <- "Latvia"
medals5[medals5$Nationality == "EUN",]$Country <- NA
medals5[medals5$Nationality == "SUD",]$Country <- "Sudan"
medals5[medals5$Nationality == "BOT",]$Country <- "Botswana"
medals5[medals5$Nationality == "BLR",]$Country <- "Belarus"
medals5[medals5$Nationality == "EST",]$Country <- "Estonia"
medals5[medals5$Nationality == "CZE",]$Country <- "Czech Republic"
medals5[medals5$Nationality == "TPE",]$Country <- "Taiwan"
medals5[medals5$Nationality == "KAZ",]$Country <- "Kazakhstan"
medals5[medals5$Nationality == "LTU",]$Country <- "Lithuania"
medals5[medals5$Nationality == "IRI",]$Country <- "Iran"
medals5[medals5$Nationality == "TJK",]$Country <- "Tajikistan"
medals5[medals5$Nationality == "SLO",]$Country <- "Slovenia"
medals5[medals5$Nationality == "UKR",]$Country <- "Ukraine"
medals5[medals5$Nationality == "ROU",]$Country <- "Romania"
medals5[medals5$Nationality == "HAI",]$Country <- "Haiti"
medals5[medals5$Nationality == "KOR",]$Country <- "South Korea"
medals5[medals5$Nationality == "ARG",]$Country <- "Argentina"
medals5[medals5$Nationality == "CHI",]$Country <- "Chile"
medals5[medals5$Nationality == "DJI",]$Country <- "Djibouti"
medals5[medals5$Nationality == "YUG",]$Country <- NA
medals5[medals5$Nationality == "VEN",]$Country <- "Venezuela"
medals5[medals5$Nationality == "BRN",]$Country <- "Bahrain"
medals5[medals5$Nationality == "AUT",]$Country <- "Austria"
medals5[medals5$Nationality == "COL",]$Country <- "Columbia"
medals5[medals5$Nationality == "MOZ",]$Country <- "Mozambique"
medals5[medals5$Nationality == "CRO",]$Country <- "Croatia"
medals5[medals5$Nationality == "SYR",]$Country <- "Syria"
medals5[medals5$Nationality == "SRB",]$Country <- "Serbia"
medals5[medals5$Nationality == "ISL",]$Country <- "Iceland"
medals5[medals5$Nationality == "CMR",]$Country <- "Cameroon"
medals5[medals5$Nationality == "BAH",]$Country <- "Bahamas"

medals6 <- medals5[-which(is.na(medals5$Country)),]


medals_dist <- medals6[(medals6$Event == "800M Women" | medals6$Event == "800M Men" |
                          medals6$Event == "1500M Women" | medals6$Event == "1500M Men" |
                          medals6$Event == "5000M Women" | medals6$Event == "5000M Men" |
                          medals6$Event == "10000M Women" | medals6$Event == "10000M Men" |
                          medals6$Event == "Marathon Women" | medals6$Event == "Marathon Men" |
                          medals6$Event == "3000M Steeplechase Women" | medals6$Event == "3000M Steeplechase Men" |
                          medals6$Event == "20Km Race Walk Women" | medals6$Event == "20Km Race Walk Men" |
                          medals6$Event == "50Km Race Walk Men"),]

medals_sprint <- medals6[(medals6$Event == "100M Women" | medals6$Event == "100M Men" |
                            medals6$Event == "200M Women" | medals6$Event == "200M Men" |
                            medals6$Event == "400M Women" | medals6$Event == "400M Men" |
                            medals6$Event == "100M Hurdles Women" | medals6$Event == "110M Hurdles Men" |
                            medals6$Event == "400M Hurdles Women" | medals6$Event == "400M Hurdles Men" |
                            medals6$Event == "4x100M Relay Women" | medals6$Event == "4x100M Relay Men" |
                            medals6$Event == "4x400M Relay Women" | medals6$Event == "4x400M Relay Men"),]

medals_field <- medals6[(medals6$Event == "Hammer Throw Women" | medals6$Event == "Hammer Throw Men" |
                           medals6$Event == "Discus Throw Women" | medals6$Event == "Discus Throw Men" |
                           medals6$Event == "Shot Put Women" | medals6$Event == "Shot Put Men" |
                           medals6$Event == "Javelin Throw Women" | medals6$Event == "Javelin Throw Men" |
                           medals6$Event == "Long Jump Women" | medals6$Event == "Long Jump Men" |
                           medals6$Event == "Triple Jump Women" | medals6$Event == "Triple Jump Men" |
                           medals6$Event == "Pole Vault Women" | medals6$Event == "Pole Vault Men" |
                           medals6$Event == "High Jump Women" | medals6$Event == "High Jump Men" |
                           medals6$Event == "Heptathlon Women" | medals6$Event == "Decathlon Men"),]

frame_dist <- data.frame(sort(table(medals_dist$Country), decreasing = TRUE))
frame_dist$Perc <- round(frame_dist$Freq / sum(frame_dist$Freq) * 100, 1)

frame_sprint <- data.frame(sort(table(medals_sprint$Country), decreasing = TRUE))
frame_sprint$Perc <- round(frame_sprint$Freq / sum(frame_sprint$Freq) * 100, 1)

frame_field <- data.frame(sort(table(medals_field$Country), decreasing = TRUE))
frame_field$Perc <- round(frame_field$Freq / sum(frame_field$Freq) * 100, 1)

frame_all <- data.frame(sort(table(medals6$Country), decreasing = TRUE))
frame_all$Perc <- round(frame_all$Freq / sum(frame_all$Freq) * 100, 1)

frame_nous <- data.frame(sort(table(medals6$Country), decreasing = TRUE))
frame_nous <- frame_nous[-1,]
frame_nous$Perc <- round(frame_nous$Freq / sum(frame_nous$Freq) * 100, 1)


#ALL MEDALS
worldmap  <- map_data("world")
result_all <- left_join(x = worldmap, y = frame_all, by = c("region" = "Var1"))
result_all$Perc[is.na(result_all$Perc)] <- 0
#plot
plot_all <- ggplot(data = result_all, aes(long, lat, group = group, fill = Perc))
plot_all <- plot_all + geom_polygon(color = "black", size = 0.1) + theme_dendro() +
  scale_fill_viridis(option = "magma", direction = -1, limits = c(0, 50)) +
  guides(fill=guide_colorbar(title="Percentage")) +
  ggtitle("Distributation of All Olympic Track and Field Medals")

#DISTANCE
result_dist <- left_join(x = worldmap, y = frame_dist, by = c("region" = "Var1"))
result_dist$Perc[is.na(result_dist$Perc)] <- 0
#plot
plot_dist <- ggplot(data = result_dist, aes(long, lat, group = group, fill = Perc))
plot_dist <- plot_dist + geom_polygon(color = "black", size = 0.1) + theme_dendro() +
  scale_fill_viridis(option = "magma", direction = -1, limits = c(0, 50)) +
  guides(fill=guide_colorbar(title="Percentage")) +
  ggtitle("Distributation of Olympic Track and Field Distance Event Medals")

#SPRINTS
result_sprint <- left_join(x = worldmap, y = frame_sprint, by = c("region" = "Var1"))
result_sprint$Perc[is.na(result_sprint$Perc)] <- 0
#plot
plot_sprint <- ggplot(data = result_sprint, aes(long, lat, group = group, fill = Perc))
plot_sprint<- plot_sprint + geom_polygon(color = "black", size = 0.1) + theme_dendro() +
  scale_fill_viridis(option = "magma", direction = -1, limits = c(0, 50)) +
  guides(fill=guide_colorbar(title="Percentage")) +
  ggtitle("Distributation of Olympic Track and Field Sprint Event Medals")

#FIELD
result_field <- left_join(x = worldmap, y = frame_field, by = c("region" = "Var1"))
result_field$Perc[is.na(result_field$Perc)] <- 0
plot_field <- ggplot(data = result_field, aes(long, lat, group = group, fill = Perc))
#plot
plot_field <- plot_field + geom_polygon(color = "black", size = 0.1) + theme_dendro() +
  scale_fill_viridis(option = "magma", direction = -1, limits = c(0, 50)) +
  guides(fill=guide_colorbar(title="Percentage")) +
  ggtitle("Distributation of Olympic Track and Field Field Event Medals")

result_nous <- left_join(x = worldmap, y = frame_nous, by = c("region" = "Var1"))
result_nous$Perc[is.na(result_nous$Perc)] <- 0
#plot
plot_nous <- ggplot(data = result_nous, aes(long, lat, group = group, fill = Perc))
plot_nous <- plot_nous + geom_polygon(color = "black", size = 0.1) + theme_dendro() +
  scale_fill_viridis(option = "magma", direction = -1, limits = c(0, 50)) +
  guides(fill=guide_colorbar(title="Percentage")) +
  ggtitle("Distributation of Non-U.S. Olympic Track and Field Medals")


medals8 <- medals[-c(156, 158, 160, 320, 322, 324, 1664, 1666, 1668, 1793, 1795, 1797),]
medals8 <- subset(medals8, select = c(1, 2, 4, 5, 6, 7))
medals8[1,]$Nationality <- "GBR"

Country <- rep(NA, times = length(medals8$Nationality))
medals8 <- cbind(medals8, Country)

#adding full country name for easier search
medals8[medals8$Nationality == "EUA",]$Country <- "United Team of Germany"
medals8[medals8$Nationality == "GDR",]$Country <- "East Germany"
medals8[medals8$Nationality == "FRG",]$Country <- "West Germany"
medals8[medals8$Nationality == "URS",]$Country <- "USSR"
medals8[medals8$Nationality == "GBR",]$Country <- "Great Britain"
medals8[medals8$Nationality == "KEN",]$Country <- "Kenya"
medals8[medals8$Nationality == "ETH",]$Country <- "Ethiopia"
medals8[medals8$Nationality == "MAR",]$Country <- "Morocco"
medals8[medals8$Nationality == "ITA",]$Country <- "Italy"
medals8[medals8$Nationality == "FIN",]$Country <- "Finland"
medals8[medals8$Nationality == "POR",]$Country <- "Portugal"
medals8[medals8$Nationality == "TUN",]$Country <- "Tunisia"
medals8[medals8$Nationality == "RUS",]$Country <- "Russia"
medals8[medals8$Nationality == "GER",]$Country <- "Germany"
medals8[medals8$Nationality == "AUS",]$Country <- "Australia"
medals8[medals8$Nationality == "TCH",]$Country <- "Czechoslovakia"
medals8[medals8$Nationality == "FRA",]$Country <- "France"
medals8[medals8$Nationality == "SWE",]$Country <- "Sweden"
medals8[medals8$Nationality == "USA",]$Country <- "USA"
medals8[medals8$Nationality == "ERI",]$Country <- "Eritrea"
medals8[medals8$Nationality == "BEL",]$Country <- "Belgium"
medals8[medals8$Nationality == "HUN",]$Country <- "Hungary"
medals8[medals8$Nationality == "POL",]$Country <- "Poland"
medals8[medals8$Nationality == "JAM",]$Country <- "Jamaica"
medals8[medals8$Nationality == "CAN",]$Country <- "Canada"
medals8[medals8$Nationality == "TTO",]$Country <- "Trinidad and Tobago"
medals8[medals8$Nationality == "BAR",]$Country <- "Barbados"
medals8[medals8$Nationality == "NAM",]$Country <- "Namibia"
medals8[medals8$Nationality == "NED",]$Country <- "Netherlands"
medals8[medals8$Nationality == "RSA",]$Country <- "South Africa"
medals8[medals8$Nationality == "CUB",]$Country <- "Cuba"
medals8[medals8$Nationality == "BUL",]$Country <- "Bulgaria"
medals8[medals8$Nationality == "PAN",]$Country <- "Panama"
medals8[medals8$Nationality == "NZL",]$Country <- "New Zealand"
medals8[medals8$Nationality == "ESP",]$Country <- "Spain"
medals8[medals8$Nationality == "CHN",]$Country <- "China"
medals8[medals8$Nationality == "ALG",]$Country <- "Algeria"
medals8[medals8$Nationality == "QAT",]$Country <- "Qatar"
medals8[medals8$Nationality == "LUX",]$Country <- "Luxembourg"
medals8[medals8$Nationality == "IRL",]$Country <- "Ireland"
medals8[medals8$Nationality == "SUI",]$Country <- "Switzerland"
medals8[medals8$Nationality == "GRE",]$Country <- "Greece"
medals8[medals8$Nationality == "IND",]$Country <- "India"
medals8[medals8$Nationality == "ECU",]$Country <- "Ecuador"
medals8[medals8$Nationality == "MEX",]$Country <- "Mexico"
medals8[medals8$Nationality == "GUA",]$Country <- "Guatemala"
medals8[medals8$Nationality == "TAN",]$Country <- "Tanzania"
medals8[medals8$Nationality == "NOR",]$Country <- "Norway"
medals8[medals8$Nationality == "TUR",]$Country <- "Turkey"
medals8[medals8$Nationality == "KSA",]$Country <- "Saudi Arabia"
medals8[medals8$Nationality == "PHI",]$Country <- "Philippines"
medals8[medals8$Nationality == "DOM",]$Country <- "Dominican Republic"
medals8[medals8$Nationality == "PUR",]$Country <- "Puerto Rico"
medals8[medals8$Nationality == "ZAM",]$Country <- "Zambia"
medals8[medals8$Nationality == "UGA",]$Country <- "Uganda"
medals8[medals8$Nationality == "SRI",]$Country <- "Sri Lanka"
medals8[medals8$Nationality == "GRN",]$Country <- "Grenada"
medals8[medals8$Nationality == "CIV",]$Country <- "Ivory Coast"
medals8[medals8$Nationality == "DEN",]$Country <- "Denmark"
medals8[medals8$Nationality == "JPN",]$Country <- "Japan"
medals8[medals8$Nationality == "BRA",]$Country <- "Brazil"
medals8[medals8$Nationality == "NGR",]$Country <- "Niger"
medals8[medals8$Nationality == "BWI",]$Country <- "British West Indies"
medals8[medals8$Nationality == "BDI",]$Country <- "Burundi"
medals8[medals8$Nationality == "SVK",]$Country <- "Slovakia"
medals8[medals8$Nationality == "LAT",]$Country <- "Latvia"
medals8[medals8$Nationality == "EUN",]$Country <- "Former Soviet Union"
medals8[medals8$Nationality == "SUD",]$Country <- "Sudan"
medals8[medals8$Nationality == "BOT",]$Country <- "Botswana"
medals8[medals8$Nationality == "BLR",]$Country <- "Belarus"
medals8[medals8$Nationality == "EST",]$Country <- "Estonia"
medals8[medals8$Nationality == "CZE",]$Country <- "Czech Republic"
medals8[medals8$Nationality == "TPE",]$Country <- "Taiwan"
medals8[medals8$Nationality == "KAZ",]$Country <- "Kazakhstan"
medals8[medals8$Nationality == "LTU",]$Country <- "Lithuania"
medals8[medals8$Nationality == "IRI",]$Country <- "Iran"
medals8[medals8$Nationality == "TJK",]$Country <- "Tajikistan"
medals8[medals8$Nationality == "SLO",]$Country <- "Slovenia"
medals8[medals8$Nationality == "UKR",]$Country <- "Ukraine"
medals8[medals8$Nationality == "ROU",]$Country <- "Romania"
medals8[medals8$Nationality == "HAI",]$Country <- "Haiti"
medals8[medals8$Nationality == "KOR",]$Country <- "South Korea"
medals8[medals8$Nationality == "ARG",]$Country <- "Argentina"
medals8[medals8$Nationality == "CHI",]$Country <- "Chile"
medals8[medals8$Nationality == "DJI",]$Country <- "Djibouti"
medals8[medals8$Nationality == "YUG",]$Country <- "Yugoslavia"
medals8[medals8$Nationality == "VEN",]$Country <- "Venezuela"
medals8[medals8$Nationality == "BRN",]$Country <- "Bahrain"
medals8[medals8$Nationality == "AUT",]$Country <- "Austria"
medals8[medals8$Nationality == "COL",]$Country <- "Columbia"
medals8[medals8$Nationality == "MOZ",]$Country <- "Mozambique"
medals8[medals8$Nationality == "CRO",]$Country <- "Croatia"
medals8[medals8$Nationality == "SYR",]$Country <- "Syria"
medals8[medals8$Nationality == "SRB",]$Country <- "Serbia"
medals8[medals8$Nationality == "ISL",]$Country <- "Iceland"
medals8[medals8$Nationality == "CMR",]$Country <- "Cameroon"
medals8[medals8$Nationality == "BAH",]$Country <- "Bahamas"

medals8$Medal <- factor(medals8$Medal, levels = c('G', 'S', 'B'))
medals8  <- medals8 %>%
  select(Event, Year, Nationality, Country, Medal, Name)
medals8 <- medals8[order(-medals8$Year),]

table_medals <- DT::datatable(medals8, extensions = "Responsive")
table_medals

medals9 <- subset(medals8, select = c(2, 1, 5, 4))
medals9 <- medals9[order(medals9$Year, medals9$Event, medals9$Medal),]

kbl1 <- kbl(medals9, row.names = FALSE) %>%
  kable_paper(lightable_options = "hover", full_width = FALSE) %>%
  scroll_box(width = "50%", height = "300px")
#kbl1


ui <- dashboardPage(
  skin = "red",
  
  dashboardHeader(
    title = "Olympic Medals"
  ),
  
  dashboardSidebar(
    sidebarMenu(
      menuItem("Top Five Historic Countries", tabName = "top_five"),
      menuItem("Maps", tabName = "maps"),
      menuItem("Table", tabName = "table_full")
    )
  ),
  
  dashboardBody(
    tabItems(
      #page 1
      tabItem("top_five",
              box(plotlyOutput("all_ply_stack"), width = 500)
              
      ),
      #page 2
      tabItem("maps",
              box(plotOutput("plot_all"), width = 300),
              box(plotOutput("plot_dist"), width = 300),
              box(plotOutput("plot_sprint"), width = 300),
              box(plotOutput("plot_field"), width = 300),
              box(plotOutput("plot_nous"), width = 300)
      ),
      #page 3
      tabItem("table_full",
              box(tableOutput("kbl1"), width = 500)
      )
    )
  )
)


server <- function(input, output) {
  
  #time series plots
  output$all_ply_stack <- renderPlotly({
    all_ply_stack
  })
  
  
  #medal maps
  output$plot_all <- renderPlot({
    plot_all
  })
  output$plot_dist <- renderPlot({
    plot_dist
  })
  output$plot_sprint <- renderPlot({
    plot_sprint
  })
  output$plot_field <- renderPlot({
    plot_field
  })
  output$plot_nous <- renderPlot({
    plot_nous
  })
  
  #table
  output$table <- renderTable({
    kbl1
  })
  
}

shinyApp(ui, server)

