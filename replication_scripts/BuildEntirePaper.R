suppressPackageStartupMessages({
  library(plyr)
  library(reshape2)
  library(readr)
})
library(ggplot2)
library(plyr)
library(reshape2)
library(stringr)
library(dplyr)

#BUILD DATA WE NEED

basicFormat <- theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
                     plot.title = element_text(hjust = 0.5),
                     axis.title.y=element_blank(),
                     axis.title.x=element_blank(),
                     panel.background = element_blank(), axis.line = element_line(colour = "black"), 
                     legend.key.size=unit(10,"pt"),
                     aspect.ratio=0.5,text=element_text(size=8,  family="Times"))

lightRed <- "#EC564D"
medRed <- "#A03A34"
darkRed <- "#6D2823"

#lightGreen <- "#95B661"
lightGreen <- "#95B661"
medGreen <- "#568C54"
darkGreen <- "#375935"


data_dir <- "../datasets/"
flappingJacoco <- read_csv(paste0(data_dir, "flapping_jacoco.csv"), col_types = cols(
  commit = col_character(),
  file = col_character(),
  line = col_integer(),
  covered = col_integer()
))
flappingCoveralls <- read_csv(paste0(data_dir, "flapping_coveralls.csv"), col_types = cols(
  commit = col_character(),
  file = col_character(),
  line = col_integer(),
  covered = col_integer()
))
flappingAll <- rbind(flappingCoveralls,flappingJacoco)
projSources <- read_csv(paste0(data_dir, "project_sources.csv"), col_types = cols(
  ProjectName = col_character(),
  Source = col_character()
))
coverage <- read_csv(paste0(data_dir, "coverage_EOL.csv"), col_types = cols(
  repo = col_character(),
  childSha = col_character(),
  parentSha = col_character(),
  childBranch = col_character(),
  timestamp = col_integer(),
  newHitLines = col_integer(),
  newNonHitLines = col_integer(),
  newFileHitLines = col_integer(),
  newFileNonHitLines = col_integer(),
  deletedLinesTested = col_integer(),
  deletedLinesNotTested = col_integer(),
  deletedFileLinesTested = col_integer(),
  deletedFileLinesNotTested = col_integer(),
  oldLinesNewlyTested = col_integer(),
  oldLinesNoLongerTested = col_integer(),
  modifiedLinesNewlyHit = col_integer(),
  modifiedLinesStillHit = col_integer(),
  modifiedLinesNotHit = col_integer(),
  nStatementsInBoth = col_integer(),
  nStatementsInEither = col_integer(),
  totalStatementsHitNow = col_integer(),
  totalStatementsHitPrev = col_integer(),
  totalStatementsNow = col_integer(),
  totalStatementsPrev = col_integer(),
  insFilesSrc = col_integer(),
  insFilesTest = col_integer(),
  modFilesSrc = col_integer(),
  modFilesTest = col_integer(),
  delFilesSrc = col_integer(),
  delFilesTest = col_integer(),
  newLinesSrc = col_integer(),
  newLinesTest = col_integer(),
  delLinesSrc = col_integer(),
  delLinesTest = col_integer(),
  insLinesAllFiles = col_integer(),
  delLinesAllFiles = col_integer()
))
coverage <- coverage[coverage$repo != "repo", ]
# branches <- read_csv("branches_uniq.csv")
# timestamps <- read_csv("ShaAndTime.csv")
projectsCSV <- read_csv(paste0(data_dir, "upTo1000PerLang.rand.csv"), c("URL", "lang"), col_types = cols(
  URL = col_character(),
  lang = col_character()
))
projectsCSV_jacoco <- read_csv(paste0(data_dir, "projects_jacoco.csv"), c("URL", "lang", "slug"), col_types = cols(
  URL = col_character(),
  lang = col_character(),
  slug = col_character()
))
shaOrders <- read_csv(paste0(data_dir, "shaOrders.csv"), col_types = cols(
  project = col_character(),
  idx = col_integer(),
  sha = col_character()
))

coverage_jacoco <- read_csv(paste0(data_dir, "coverage_jacoco_EOL.csv"), col_types = cols(
  date = col_character(),
  repo = col_character(),
  childSha = col_character(),
  parentSha = col_character(),
  childBranch = col_character(),
  timestamp = col_integer(),
  newHitLines = col_integer(),
  newNonHitLines = col_integer(),
  newFileHitLines = col_integer(),
  newFileNonHitLines = col_integer(),
  deletedLinesTested = col_integer(),
  deletedLinesNotTested = col_integer(),
  deletedFileLinesTested = col_integer(),
  deletedFileLinesNotTested = col_integer(),
  oldLinesNewlyTested = col_integer(),
  oldLinesNoLongerTested = col_integer(),
  modifiedLinesNewlyHit = col_integer(),
  modifiedLinesStillHit = col_integer(),
  modifiedLinesNotHit = col_integer(),
  nStatementsInBoth = col_integer(),
  nStatementsInEither = col_integer(),
  totalStatementsHitNow = col_integer(),
  totalStatementsHitPrev = col_integer(),
  totalStatementsNow = col_integer(),
  totalStatementsPrev = col_integer(),
  insFilesSrc = col_integer(),
  insFilesTest = col_integer(),
  modFilesSrc = col_integer(),
  modFilesTest = col_integer(),
  delFilesSrc = col_integer(),
  delFilesTest = col_integer(),
  newLinesSrc = col_integer(),
  newLinesTest = col_integer(),
  delLinesSrc = col_integer(),
  delLinesTest = col_integer(),
  insLinesAllFiles = col_integer(),
  delLinesAllFiles = col_integer()
))
#coverage_jacoco$timeStamp <- as.numeric(strptime(coverage_jacoco$date,'%Y-%m-%d %H:%M:%S'))
projects <- cbind(projectsCSV, colsplit(projectsCSV$URL, ".com/", c("prePend", "ProjectName")))
projects$ProjectName <- sub("^/", "", projects$ProjectName)
projects_jacoco <- cbind(projectsCSV_jacoco, colsplit(projectsCSV_jacoco$URL, ".com/", c("prePend", "ProjectName")))
projects_jacoco$ProjectName <- sub("^/", "", projects_jacoco$ProjectName)

#timestamps <-unique(timestamps)

coverage_jacoco <- merge(projects_jacoco, unique(coverage_jacoco), by.x = 'slug', by.y = 'repo', all.y = TRUE)

#mCov <- coverage[coverage$repo=="ManageIQ/ui-components",]
#mProj <- projects[projects$ProjectName=="ManageIQ/ui-components",]

allData <- merge(projects, coverage, by.x = 'ProjectName', by.y = 'repo', all.y = TRUE)
#allData <- merge(unique(coverage), projects, by.y = 'ProjectName', by.x = 'repo', all.x = TRUE)
#allData <- merge(allData,branches,by.x='childSha',by.y='SHA',all.x = TRUE)
#allData <- merge(allData,timestamps,by.x='childSha',by.y='SHA',all.x = TRUE)
coverage_jacoco$date <- NULL
coverage_jacoco$slug <- NULL
allData$childBranch <- NULL
#coverage_jacoco$branch <- coverage_jacoco$childBranch
coverage_jacoco$childBranch <- NULL
allData <- rbind(allData, coverage_jacoco)

allData <- merge(allData, shaOrders, by.x = "childSha", by.y = "sha", all.x = TRUE)
if ("project" %in% names(allData)) allData$project <- NULL
#allData <- allData[allData$branch == 'master',]

allData$ActualChangeToCoverage <- with(allData, (totalStatementsHitNow / totalStatementsNow) - (totalStatementsHitPrev / totalStatementsPrev))
allData$PercentageOfStatementsNewlyCovered <- with(allData, (totalStatementsHitNow + oldLinesNewlyTested) / ((totalStatementsNow + totalStatementsPrev) / 2))
allData$PercentageOfStatementsNoLongerCovered <- with(allData, 0 - (newNonHitLines + oldLinesNoLongerTested) / ((totalStatementsNow + totalStatementsPrev) / 2))
allData$Jaccard <- with(allData, (nStatementsInBoth / nStatementsInEither))
allData$CoverageNow <- with(allData, (totalStatementsHitNow / totalStatementsNow))

allData <- na.omit(allData)

allData <- subset(allData,ProjectName!="Points/PyLCP")
allData <- subset(allData,ProjectName!="apache/commons-configuration")


counts <- data.frame(table(allData$ProjectName))
counts <- counts[counts$Freq>10,]
allData <- merge(allData, counts, by.x = 'ProjectName', by.y = 'Var1', all.y = TRUE)


projectIds <- as.data.frame(unique(allData$ProjectName))
projectIds$pid <- paste("P",str_pad(row.names(projectIds),2,pad="0"), sep="")
projectIds$pid <- as.factor(projectIds$pid)
projectIds$pidNumeric <- as.numeric(row.names(projectIds))
colnames(projectIds) <- c("ProjectName","pid","pidNumeric")
allData <- merge(allData,projectIds,by.x="ProjectName",by.y="ProjectName", all.x=TRUE)
allData <- allData[order(allData$pid, allData$idx), ]
allData$totalPatchSize <- allData$insLinesAllFiles + allData$delLinesAllFiles

message("Loaded builds: ", nrow(allData), " | Projects: ", length(unique(allData$ProjectName)))

#BUILD TABLE 1:
source("PatchSummaryTable.R", echo = FALSE)
#BUILD FIGURE 2 (RQ1):
source("coverageOfNewLines.R", echo = FALSE)
#BUILD FIGURE 3 (RQ2):
source("patchImpactOnOverallCoverage.R", echo = FALSE)
#BUILD FIGURE 4 (RQ3):
source("occluded_changes_barplot.R", echo = FALSE)
#Correlation: patch coverage vs change in non-patch coverage (Kendall; paper RQ2 uses Pearson — see comparison_to_paper.R)
source("corrolatePatchCovWithChange.R", echo = FALSE)
source("comparison_to_paper.R", echo = FALSE)
