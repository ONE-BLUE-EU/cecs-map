library(readxl)

contaminants <- read_excel("Chemical occurrence review ONE-BLUE.xlsx", sheet = "Occurrence")
contaminants <- contaminants[-c(1:6), ]
contaminants <- contaminants[,-c(2:18)]
View(contaminants)
contaminants <- t(contaminants)
contaminants <- as.data.frame(contaminants)
names(contaminants) <- contaminants[1,]
contaminants <- contaminants[-c(1:4), ]
contaminants$area<-row.names(contaminants)
contaminants <- contaminants[,c(ncol(contaminants),1:c(ncol(contaminants)-1))]

names(contaminants)[2]<-"lat"
names(contaminants)[3]<-"lng"
names(contaminants)[4]<-"contributor"
contaminants$total<-"River water"

contaminants <- contaminants[,c(1,3,2,4,ncol(contaminants),c(6:ncol(contaminants)-1))]
row.names(contaminants)<-NULL

contaminants$lng <- as.numeric(contaminants$lng)
contaminants$lat <- as.numeric(contaminants$lat)



contaminants$`Estradiol (E2)`


contaminants -> eco2mix
save.image("data.RData")

