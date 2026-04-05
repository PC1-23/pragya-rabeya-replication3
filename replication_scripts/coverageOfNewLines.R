#IDEA: number of classes with test coveage change but no edits

# make patch coverage graph (Fig. 2 / RQ1)
fig_dir <- "../outputs/figures"
dir.create(fig_dir, showWarnings = FALSE, recursive = TRUE)

allCur <- allData
allCur$PercentageOfDiffCovered <- with(allCur,(newHitLines+newFileHitLines)/(newHitLines+newNonHitLines+newFileNonHitLines+newFileNonHitLines))
na.omit(allCur)
allCur$PercentageOfDiffCoveredBucketed <- cut(allCur$PercentageOfDiffCovered,
                                              breaks=c(-1,.00001,.25,.5,.75,0.99999,1),
                                              include.lowest=1,
                                              labels=c("0","(0-25)","(25-50]","(50-75]","(75-100)","100"))


#Normalize to % of patch size 
allCur$totalPatchSize <- with(allCur,newHitLines+newNonHitLines+deletedLinesTested+deletedLinesNotTested)
allCur$totalCovChangeSize <- with(allCur,oldLinesNewlyTested+oldLinesNoLongerTested)
allCur$percentOfPatchSize <- with(allCur,(totalCovChangeSize*100)/totalPatchSize)

#prev <- subset(allData,interval=="Prev")
# prevFiltered <- allCur
# prevFiltered <- subset(allCur,totalCovChangeSize>0)
# prevFiltered <- subset(prevFiltered,totalPatchSize>0)
# print(quantile(prevFiltered$percentOfPatchSize))
#Here is the avg per project
# print(aggregate(prevFiltered["percentOfPatchSize"], list(prevFiltered$ProjectName), mean))

allCur$patchAndCovChange <- with(allCur,totalPatchSize+totalCovChangeSize)
# rev <- subset(allCur,totalCovChangeSize>0)

plotData <- allCur
#plotData <-subset(allCur,ProjectName=="apache-commons-configuration")
plotDataOverallTmp <- ddply(plotData,~pidNumeric,summarise,mean=mean(totalStatementsHitNow/totalStatementsNow))
row.names(plotDataOverallTmp) <- t(plotDataOverallTmp['pidNumeric'])
plotDataOverall<-plotDataOverallTmp['mean']-0.005
plotDataOverall<-cbind(plotDataOverall,rep(0.005,length(plotDataOverallTmp$mean)))
plotDataOverall<-cbind(plotDataOverall,rep(0.005,length(plotDataOverallTmp$mean)))
plotDataOverall<-t(plotDataOverall)
# plotDataOverall<-plotDataOverall[,rev(colnames(plotDataOverall))]



plotDataBuckets <- table(plotData$PercentageOfDiffCoveredBucketed,plotData$pidNumeric)
plotDataBuckets <- prop.table(plotDataBuckets,2)
colnames(plotDataBuckets)<-paste("P",colnames(plotDataBuckets),sep="")
# plotDataBuckets<-plotDataBuckets[,rev(colnames(plotDataBuckets))]

pdf(file.path(fig_dir, "coverageofnewlines.pdf"), width = 10, height = 6)
par(las = 1, cex = 0.5, pin = c(7, 3.5), family = "serif")
clear <- rgb(0, 0, 1, alpha=0)
labs <- seq(0, 1, by = 0.25)
barplot(plotDataBuckets,axes = FALSE,
        col=c("#ad302e","#de5434","#e9923e","#f8cc47","#8bb954","#428f4d"),horiz=TRUE,border=NA,
        legend = rownames(plotDataBuckets), args.legend=list(x="bottom",inset=c(0,-.12),bty="n",ncol=6),xlim=c(0,1))
barplot(plotDataOverall, col=c(clear,"black",clear), horiz=TRUE,xlim=c(0,1), border=NA, add=TRUE,axes = FALSE)

#legend(mean(range(b)), -0.5, legend.text, xjust = 0.5,
#       fill=heat.colors(length(legend.text)))
axis(side = 1, at = labs, labels = paste0(labs * 100, "%"), padj=-1)
title(xlab = "Percent of builds satisfying patch coverage % at level indicated by color:", mgp = c(1.5, 1, 0))
dev.off()
message("Saved Fig. 2 (RQ1): ", normalizePath(file.path(fig_dir, "coverageofnewlines.pdf"), mustWork = FALSE))

# Extra diagnostic (not the paper's RQ1 headline statistic). Name avoids clashing with corrolatePatchCovWithChange.R.
covPearsonClean <- subset(allCur,
  !is.na(PercentageOfDiffCovered) & is.finite(PercentageOfDiffCovered) & !is.nan(PercentageOfDiffCovered)
)
cat("\n=== Extra: Pearson (overall coverage vs delta overall coverage) — see paper RQ1 for Kendall patch vs overall ===\n")
print(stats::cor.test(
  x = covPearsonClean$CoverageNow, y = covPearsonClean$ActualChangeToCoverage,
  use = "complete.obs"
))

# plot(allCur$CoverageNow, log(allCur$ActualChangeToCoverage))
# 
# fit <- aov(CoverageNow ~ PercentageOfDiffCovered +  ProjectName, data = clean)
# 
# vif(fit)
# 
# fit
# 
# plot(fit)


