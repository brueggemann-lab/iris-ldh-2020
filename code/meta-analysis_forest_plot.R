# Meta-analysis Forest Plot Script for IRIS Dataset (15/03/2021)
# Forest Plot in R
# Import .csv spreadsheet
library(readxl)
meta <- read.csv("location of meta.csv")

library(dmetar)
library(metafor)
library(meta)
library(tidyverse)

# Forest Plot Protocol
# Step (Interruption Time Point):

df<- meta[-c(2,4,6,8,10,12,14,16,18,20,22,24,26,28,30,32,34,36,38,40,42,44,46,48,50,52), ]

logRR <- log(df$RR)
loglower <- log(df$lower)
logupper <- log(df$upper)

graph1<- metagen(logRR, 
        lower=loglower,
        upper = logupper,
        studlab = Country,
        method.tau = "REML",
        sm = "IRR",
        data = df)

step<- forest(graph1,
           leftcols = c("studlab", "N"),
           just = "left", just.addcols = "right", just.studlab = "left",
           fontsize = 12,
           fs.hetstat = 10,
           plotwidth = "8cm",
           col.square = "#9EC1CF",
           col.diamond = "#CC99C9",
           col.diamond.lines = "black",
           col.square.lines = "black",
           col.fixed = "red",
           col.random = "red",
           col.predict = "black",
           xlim = c(0.1,5),
           col.study = "black",
           squaresize = 1.0,
           hetlab = "Het: ",
           spacing = 1)

# Slope:

df2<- meta[-c(1,3,5,7,9,11,13,15,17,19,21,23,25,27,29,31,33,35,37,39,41,43,45,47,49,51), ]

logRR2 <- log(df2$RR)
loglower2 <- log(df2$lower)
logupper2 <- log(df2$upper)

graph2<- metagen(logRR2, 
               lower=loglower2,
               upper = logupper2,
               studlab = Country,
               method.tau = "REML",
               sm = "IRR",
               data = df2)


slope<- forest(graph2,
           leftcols = c("studlab", "N"),
           just = "left", just.addcols = "right", just.studlab = "left",
           fontsize = 12,
           fs.hetstat = 10,
           plotwidth = "8cm",
           col.square = "#6FC0AB",
           col.diamond = "#CC99C9",
           col.diamond.lines = "black",
           col.square.lines = "black",
           col.fixed = "red",
           col.random = "red",
           col.predict = "black",
           xlim = c(0.1,5),
           col.study = "black",
           squaresize = 1.0,
           hetlab = "Het: ",
           spacing = 1)

# Combined step and slope for 4 weeks:

df3 <- read.csv("location of step_slope_1.csv")
logRR3 <- log(df3$RR)
loglower3 <- log(df3$lower)
logupper3 <- log(df3$upper)

graph3<- metagen(logRR3, 
               lower=loglower3,
               upper = logupper3,
               studlab = Country,
               method.tau = "REML",
               sm = "IRR",
               data = df3)

fourwks<- forest(graph3,
           leftcols = c("studlab", "N", "P"),
           just.addcols = "left",
           fontsize = 12,
           fs.hetstat = 10,
           plotwidth = "8cm",
           col.square = "#FEC9A7",
           col.diamond = "#CC99C9",
           col.diamond.lines = "black",
           col.square.lines = "black",
           col.fixed = "red",
           col.random = "red",
           col.predict = "black",
           xlim = c(0.01,2),
           col.study = "black",
           squaresize = 1.0,
           hetlab = "Het: ",
           spacing = 1)

# Combined step and slope for 8 weeks:

df4 <- read.csv("location of step_slope_2.csv")
logRR4 <- log(df4$RR)
loglower4 <- log(df4$lower)
logupper4 <- log(df4$upper)

graph4<- metagen(logRR4, 
                lower=loglower4,
                upper = logupper4,
                studlab = Country,
                method.tau = "REML",
                sm = "IRR",
                data = df4)

eightwks<- forest(graph4,
           leftcols = c("studlab", "N", "P"),
           just.addcols = "left",
           fontsize = 12,
           fs.hetstat = 10,
           plotwidth = "8cm",
           col.square = "#FEC9A7",
           col.diamond = "#CC99C9",
           col.diamond.lines = "black",
           col.square.lines = "black",
           col.fixed = "red",
           col.random = "red",
           col.predict = "black",
           xlim = c(0.01,2),
           col.study = "black",
           squaresize = 1.0,
           hetlab = "Het: ",
           spacing = 1)

## End ##