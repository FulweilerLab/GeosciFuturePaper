
if(.Platform$OS.type=="unix"){
setwd("~/Dropbox/GFP_N2NarragansettBay")
}

# for Tim / PC use
# setwd("C:/Users/Tim/Dropbox/GFP_N2NarragansettBay")

library(plotrix)
library(Hmisc)
library(gdata)
library(plyr)

se<-function(x) sqrt(var(x,na.rm=TRUE)/length(na.omit(x)))

#### Figure 3 ####
#### data import ####
mimsdata <- read.csv("Fig4.csv", stringsAsFactors=FALSE)
mimsdata$date=format(as.POSIXct(strptime(mimsdata$Date,format="%m/%d/%Y",tz="EST")),"%Y-%m")
#mimsdata = na.omit(mimsdata)

providence = cbind(adply(tapply(mimsdata[mimsdata$Site=="Prov",]$N2Flux,mimsdata[mimsdata$Site=="Prov",]$date,mean), c(1)),adply(tapply(mimsdata[mimsdata$Site=="Prov",]$N2Flux,mimsdata[mimsdata$Site=="Prov",]$date,se), c(1)))[,-3]
colnames(providence) = c("date","ProvN2_mean","ProvN2_stderr")

midbay = cbind(adply(tapply(mimsdata[mimsdata$Site=="Mid Bay",]$N2Flux,mimsdata[mimsdata$Site=="Mid Bay",]$date,mean), c(1)),adply(tapply(mimsdata[mimsdata$Site=="Mid Bay",]$N2Flux,mimsdata[mimsdata$Site=="Mid Bay",]$date,se), c(1)))[-10,-3] # there is a one-off January 2010 Mid Bay sample?
colnames(midbay) = c("date","BayN2_mean","BayN2_stderr")

dat = merge(providence,midbay,by="date", all=T)
dat$date = as.Date(paste(dat$date,"-01",sep=""))
dat = dat[order(dat$date),]
dat[,2] = round(dat[,2],2)
dat[,3] = round(dat[,3],2)
dat[,4] = round(dat[,4],2)
dat[,5] = round(dat[,5],2)
dat$date=format(as.POSIXct(strptime(dat$date,format="%Y-%m-%d",tz="EST")),"%b-%y")
par(mfrow = c(1,2))


#plot A - Providence River Estuary
par(mai=c(1.4,1.4,1,0.1))
mean <- dat$ProvN2_mean
sderr <- dat$ProvN2_stderr
plotCI(barplot(mean,
               col="green4",
               # y axis:
               ylim=c(-300,300), 
               cex.axis=.7,
               ylab=expression(Net ~ Sediment ~ N[2]-N ~ Flux ~ (mu ~ mol ~ m^{-2} ~ hr^{-1})),
               cex.lab=.7,
               tcl=-.2,
               #x axis:
               names=dat$date, 
               las=2, #makes labels perpendicular to axis
               cex.names=.7
),
mean,
sderr,
pch=NA, #suppresses center point on error bars
sfrac=0, #suppresses serifs on error bars
add=TRUE)
abline(h=0)
abline(h=mean(mean,na.rm=TRUE),lty=2,lwd=1.5)
text(1,250,"a")

#plot B - Narragansett Bay
par(mai=c(1.4,0.1,1,1.4))
mean <- dat$BayN2_mean
sderr <- dat$BayN2_stderr
plotCI(barplot(mean,
               col="red3",
               ylim=c(-300,300),  
               yaxt="n", #supresses y axis
               names=dat$date, 
               las=2, #makes labels perpendicular to axis
               cex.names=.7),
       mean,
       sderr,
       pch=NA, #suppresses center point on error bars
       sfrac=0, #suppresses serifs on error bars
       add=TRUE)
axis(2,labels=FALSE,tcl=-.2) #adds an axis without labels
abline(h=0)
abline(h=mean(mean,na.rm=TRUE),lty=2,lwd=1.5)
text(1,250,"b")

par(mfrow = c(1,1))

#Figure 3. Monthly net sediment N$_2$-N flux (± standard error) across the sediment-water interface over a nine-year record for (a) the Providence River Estuary, and (b) the historic mid-Narragansett Bay site. Overall nine-year mean N$_2$-N flux is highlighted in each (dashed line).

##### Figure 4 ####


#y = 0.038 x - 5.58 R^2 = 0.09   in the paper 

par(mai=c(1.02,0.82,0.82,0.42))

Fig4 <- mimsdata[c(-13,-40),] # omit the missing values, instead of calling them zero


Fig4$sym = 0
Fig4[which(Fig4[,1] == unique(Fig4[,1])[1]),]$sym = 19
Fig4[which(Fig4[,1] == unique(Fig4[,1])[2]),]$sym = 1

lmo2 = Fig4$O2Flux/2
N2_fit = lm(Fig4$N2Flux~lmo2)
#summary(N2_fit)
#range(Fig4[,5])

plot(Fig4$O2Flux/2,Fig4$N2Flux, pch=Fig4$sym,  ylim = c(-300,350),xlab="",ylab="")
abline(N2_fit)
mtext(side = 2, text = expression(Net ~ Sediment ~ N[2]-N ~ Flux ~ (mu ~ mol ~ m^{-2} ~ h^{-1})), line = 1.8)
mtext(side = 1, text = expression(O[2] ~ Flux ~ (mu ~ mol ~ m^{-2} ~ h^{-1})), line = 2.5)


#Figure 4. Individual net sediment N$_2$ fluxes as a function of sediment oxygen demand for the Providence River Estuary (closed circles) and mid-Narragansett Bay (open circles). N$_2$ was significantly correlated (0.0006) to sediment oxygen demand but the overall predictive power of the relationship was weak (N$_2$-N flux = 0.038(O$_2$ flux) – 5.58; R$^2$ = 0.09, n = 134).

##### Figure 5 ####

#import datas
SmaydaData <- read.csv("SmaydaData.csv", stringsAsFactors=FALSE)
GSOData <- read.xls("http://www.gso.uri.edu/phytoplankton/chldata.xls", stringsAsFactors=FALSE)

## GSO data clean-up

# fix dates
GSOData$Sample.Date.1=as.POSIXct(strptime(GSOData$Sample.Date.1,format="%d-%b-%y",tz="EST"))

#get rid of unused columns: redundant date, empty columns, pheophytin and >20 um stuff
names(GSOData)
junk=c(1,3,5,7:12,15,17:24)
GSOData[,junk] <- list(NULL)

# get rid of blank rows where changes in methods are indicated in the xls
junkrows=which(GSOData$Sample.Date.1=="" | is.na(GSOData$Sample.Date.1))
GSOData=GSOData[-junkrows,]

#make a year column and drop 2012 data
GSOData$year=format(GSOData$Sample.Date.1,"%Y")
x2012 <- which(GSOData$year=="2012")
GSOData=GSOData[-x2012,]

# make values numeric
frozen.chla=as.numeric(GSOData$Surface.Chla.all)
fresh.chla=as.numeric(GSOData$surface.chla.all)

# date that immediate extraction began
imex=as.POSIXct("2007-05-07",tz="EST")

# fill in recent blanks in frozen data with corrected immediate extraction data
for(i in 1:length(frozen.chla)){
  if(GSOData$Sample.Date.1[i]>imex & is.na(frozen.chla[i]) & !is.na(fresh.chla[i])){
    frozen.chla[i] <- fresh.chla[i]*.4323
  }
}

# pull out annual means
ann.means=as.data.frame(cbind(as.integer(unique(GSOData$year)),as.numeric(tapply(frozen.chla,GSOData$year,mean,na.rm=TRUE))))
names(ann.means) <- names(SmaydaData)

## NOTE: These values differ from the published values for 2008, 2009, and 2013!! WHY>? (Other years match.)

## This is the data that RWF sent out:
#Fig5 <- read.csv("Fig5.csv", stringsAsFactors=FALSE)

## This is the data from the above code:
Fig5 <- rbind(SmaydaData,ann.means)

exp.lm <- lm(log(Fig5$chl_a)~Fig5$Year)
#summary(exp.lm)
#exp(exp.lm$coeff[1])
#round(exp.lm$coeff[2],3)

chl.exponential <- exp(predict(exp.lm,list(Year=Fig5$Year)))

plot(Fig5[,1],
Fig5[,2],
xlab="",
ylab="",
pch = 21,
bg="green4",
ylim = c(0,12),
yaxs="i",
xaxt="n")
axis(1, at=seq(1970,2015,5), labels=seq(1970,2015,5))
minor.tick(ny=0,nx=10, tick.ratio=.5)
mtext(side = 2, text = expression(Chlorophyll ~ italic(a) ~ (mg ~ m^{-3})), line = 1.8)
mtext(side = 1, text = expression(Year), line = 2.5)
lines(Fig5$Year, chl.exponential,lwd=2)


#Figure 5. Mean annual water column chlorophyll a concentrations over the past four decades at the long-term monitoring station in the middle of Narragansett Bay’s west passage, expanded from Nixon et al. (2009) (Chl *a* = 3.0 x 10$^{20}$ e$^{-??0.023(Year)}$; R$^2$ = .40). The mean annual chlorophyll decline is significant (p < .0001). Annual data from Li and Smayda (1998) through 1990. Historical data (1991-??1997) from Ted Smayda (University of Rhode Island) based on personal communication from Scott Nixon). All data from 1999 to present are from the University of Rhode Island Graduate School of Oceanography (GSO) plankton monitoring program (http://www.gso.uri.edu/phytoplankton); the year 2012 is not included as there were only two months of chlorophyll data available. Note that in May 2007, the GSO monitoring program changed to an immediate extraction method. The new and traditional extraction techniques were compared over a one-year period (July 2007 to July 2008; Graff and Rynearson, 2011). We used this year-long study to correct data from May 2007 to the present so that we could compare the long-term trend in chlorophyll. (All new data were multiplied by the slope of the linear regression of the traditional method as a function of the new method, y = 0.4323x -?? 1.2094; R$^2$ = 0.88).

##### Figure 6 ####

# data import
dat=read.csv("Fig6.csv",header=TRUE)

#fix years
dat$yr=as.numeric(as.character(dat$Year))
dat$yr[is.na(dat$yr)]=1981

# split data into current and historical groups 
recent=dat[dat$yr>=2005,]
z1979 <- dat[dat$yr==1979,]
MERL <- dat[dat$yr==1981,]
z1986 <- dat[dat$yr==1986,]

# three fits described in table 1
allfit=lm(N2_flux~chl_a,data=dat) #all the data
netfit=lm(N2_flux~chl_a,data=recent) #just the new data
denitfit=lm(N2_flux~chl_a,data=recent[recent$N2_flux>0,]) #just the new POSITIVE data

#plot the current data 
par(mai=c(1.4,1.4,1,1.4))
plot(recent$chl_a,
recent$N2_flux,
pch=21,
bg="grey",
xlim=c(0,60),
ylim=c(-200,1000),
ylab="",
xlab="",
xaxt="n", #suppress the axis
yaxt="n",
bty="n") # suppress the box
axis(1, pos=0) # add the x-axis at y=0
mtext(expression(Chlorophyll ~ italic(a) ~ (mg ~ m^{-3})),1,-1)
axis(2, pos=0)
mtext(expression(Net ~ Sediment ~ N[2]-N ~ Flux ~ (mu ~ mol ~ m^{-2} ~ hr^{-1})),2,2)
abline(allfit) # add the regression line from the complete data
points(MERL$chl_a,MERL$N2_flux,pch=22) # add the MERL points as open squares
points(z1979$chl_a,z1979$N2_flux,pch=17) # add the 1979 points as closed triangles
points(z1986$chl_a,z1986$N2_flux,pch=2) # add the 1986 points as open triangles

#set bounds in par for the inset figure
par(fig=c(0.55,1,.2,.8),new=TRUE)

#plot the inset - just recent data
plot(recent$chl_a,
recent$N2_flux,
pch=21,
bg="grey",
xlim=c(0,5),
ylim=c(-200,150),
mgp=c(2,1,0),
cex.axis=.8,
cex.lab=.8,
ylab=expression((mu ~ mol ~ m^{-2} ~ hr^{-1})),
xlab="",
xaxt="n")
mtext(expression(Net ~ Sediment ~ N[2]-N ~ Flux),2,3,cex=.8)
mtext(expression(Chl ~ italic(a) ~ (mg ~ m^{-3})),1,0.5,cex=.8)
axis(1,pos=0,cex.axis=.8)
abline(h=0)
abline(netfit) # add the fit to this data set
par(fig=c(0,1,0,1)) #reset the bounds to the default

#Figure 6. Mean summer (June, July, August) net sediment N$_2$-N flux as a function of summer surface water column chlorophyll a for sediments from mid-Narragansett Bay over the last 40 years. Shaded circles = 2005–2013. Closed triangle = 1979 (Seitzinger et al., 1984). Open triangle = 1985 (Nowicki, 1994). Open squares = MERL 1981 (Seitzinger, 1982). Unpublished summer chlorophyll a data from 1968 to 1996 is from Ted Smayda (University of Rhode Island). This relationship is significant (p < 0.0001). The inset shows the relationship between mean summer water column chlorophyll and net N$_2$ fluxes from 2005 to 2013 only (p = 0.0505). See Table 1 and the text for more details.

#### Figure 7 ####

# data import
dat=read.csv("Fig7.csv",header=TRUE)

# plot
mean=rbind(dat$N2fit_mean,dat$N2flux_mean)
sderr=rbind(dat$N2fit_stderr,dat$N2flux_stderr)

par(mai=c(1.4,1.4,1,.2))
plotCI(barplot(mean,
col=c("steelblue4","maroon"),
ylim=c(-200,1000),
cex.axis=.7,
ylab=expression(Net ~ Sediment ~ N[2]-N ~ Flux ~ (mu ~ mol ~ m^{-2} ~ hr^{-1})),
cex.lab=.7,
tcl=-.2,

names=dat$Year,
las=2, #makes labels perpendicular to axis
cex.names=.7,
#xaxt="n", #supresses x axis
space=c(0,0),
beside=TRUE, # as opposed to stacked
border=NA
),
mean,
sderr,
pch=NA, #suppresses center point on error bars
sfrac=0, #suppresses serifs on error bars
add=TRUE)
abline(h=0)


#Figure 7. Long-term mean (± standard error) summer net sediment N$_2$ flux rates in Narragansett Bay. Blue bars = predicted rates. Red bars = measured rates. The predicted rates shown here are the average of the rates predicted from the three different relationships between mean summer (June, July, August) surface water column chlorophyll and measured sediment N$_2$ fluxes (Table 1: All, 2005–2013 all, and 2005–2013 net denitrification only) (± standard error of the three different predictions).

