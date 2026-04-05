# RQ1–RQ3: Hilton, Bell & Marinov (ASE'18) vs this replication (paper 3.pdf).
# Uses allData if set; else evaluates BuildEntirePaper.R up to PatchSummaryTable / #BUILD TABLE 1.

if (!exists("allData", inherits = TRUE) || is.null(allData)) {
  message("Loading BuildEntirePaper.R (through PatchSummaryTable breakpoint)...")
  bf <- readLines("BuildEntirePaper.R", warn = FALSE)
  cut <- grep("^source\\(\"PatchSummaryTable", bf)[1]
  if (is.na(cut)) {
    cut <- grep("^#BUILD TABLE 1:", bf)[1]
  }
  if (is.na(cut)) stop("Could not find PatchSummaryTable source or #BUILD TABLE 1: in BuildEntirePaper.R")
  eval(parse(text = paste(bf[seq_len(cut - 1)], collapse = "\n")), envir = .GlobalEnv)
}

paper_text <- list(
  rq1_interpretation = "Patch coverage does not correlate with overall coverage (RQ1).",
  rq2_interpretation = "High patch coverage does not correlate with increasing non-patch coverage (RQ2).",
  rq3_interpretation = 'However, every project had at least one commit where there were occluded changes, indicating that "steady" coverage does not imply "no change" to code covered (RQ3).'
)

allCur <- allData
allCur$PercentageOfDiffCovered <- with(allCur, (newHitLines + newFileHitLines) /
  (newHitLines + newNonHitLines + newFileHitLines + newFileNonHitLines))
rq1_clean <- subset(allCur,
  !is.na(PercentageOfDiffCovered) & is.finite(PercentageOfDiffCovered) & !is.nan(PercentageOfDiffCovered)
)
kt_rq1 <- stats::cor.test(
  rq1_clean$PercentageOfDiffCovered, rq1_clean$CoverageNow,
  use = "complete.obs", method = "kendall", exact = FALSE
)

rq2_clean <- rq1_clean
rq2_clean$patchHit <- rq2_clean$newFileHitLines + rq2_clean$newHitLines
rq2_clean$patchTotal <- rq2_clean$newFileNonHitLines + rq2_clean$newNonHitLines
rq2_clean$nonPatchHit <- rq2_clean$totalStatementsHitNow - rq2_clean$patchHit
rq2_clean$nonPatchTotal <- rq2_clean$totalStatementsNow - rq2_clean$patchTotal
rq2_clean$changeToNonPatchCoverage <- (rq2_clean$nonPatchHit - rq2_clean$totalStatementsHitPrev) /
  (rq2_clean$nonPatchTotal - rq2_clean$totalStatementsPrev)
rq2_clean <- subset(rq2_clean,
  !is.na(changeToNonPatchCoverage) & is.finite(changeToNonPatchCoverage) & !is.nan(changeToNonPatchCoverage)
)
pr_rq2 <- stats::cor.test(
  rq2_clean$PercentageOfDiffCovered, rq2_clean$changeToNonPatchCoverage,
  use = "complete.obs", method = "pearson"
)
kt_rq2_script <- stats::cor.test(
  rq2_clean$PercentageOfDiffCovered, rq2_clean$changeToNonPatchCoverage,
  use = "complete.obs", method = "kendall", exact = FALSE
)

thresh_prop <- 0.01 / 100
occluded <- subset(allData, abs(ActualChangeToCoverage) < thresh_prop)
occluded$changeInCoveredStatements <- occluded$nStatementsInEither - occluded$nStatementsInBoth
occluded$bucket <- cut(
  occluded$changeInCoveredStatements,
  breaks = c(0, 1, 10, 100, 1000, 10000000),
  labels = c("0", "1-10", "11-100", "101-1,000", "1,001+"),
  include.lowest = TRUE
)
n_proj <- length(unique(allData$ProjectName))
n_builds <- nrow(allData)
proj_occluded_any <- length(unique(occluded$ProjectName))
pooled_bucket <- prop.table(table(occluded$bucket)) * 100
n_occluded <- nrow(occluded)

truncate_str <- function(s, max_chars) {
  s <- gsub("\n", " ", as.character(s), fixed = TRUE)
  if (max_chars < 4L) max_chars <- 4L
  if (nchar(s) <= max_chars) return(s)
  paste0(substr(s, 1, max_chars - 3), "...")
}

print_box_table <- function(title, col_stat, col_paper, col_ours, w_stat = 38L, w_paper = 32L, w_ours = 34L) {
  inner <- w_stat + w_paper + w_ours + 10L
  tw <- inner - 4L
  cat("\n")
  cat("+", strrep("-", inner), "+\n", sep = "")
  cat("| ", sprintf("%-*s", tw, truncate_str(title, tw)), " |\n", sep = "")
  cat("+", strrep("-", w_stat + 2L), "+", strrep("-", w_paper + 2L), "+", strrep("-", w_ours + 2L), "+\n", sep = "")
  cat("| ", sprintf("%-*s", w_stat, truncate_str("Statistic", w_stat)), " | ",
      sprintf("%-*s", w_paper, truncate_str("Paper (ASE'18)", w_paper)), " | ",
      sprintf("%-*s", w_ours, truncate_str("This replication", w_ours)), " |\n", sep = "")
  cat("+", strrep("-", w_stat + 2L), "+", strrep("-", w_paper + 2L), "+", strrep("-", w_ours + 2L), "+\n", sep = "")
  n <- length(col_stat)
  for (i in seq_len(n)) {
    cat("| ", sprintf("%-*s", w_stat, truncate_str(col_stat[i], w_stat)), " | ",
        sprintf("%-*s", w_paper, truncate_str(col_paper[i], w_paper)), " | ",
        sprintf("%-*s", w_ours, truncate_str(col_ours[i], w_ours)), " |\n", sep = "")
  }
  cat("+", strrep("-", w_stat + 2L), "+", strrep("-", w_paper + 2L), "+", strrep("-", w_ours + 2L), "+\n", sep = "")
}

paper_n_proj <- "47"
paper_n_builds <- "7,816"
paper_rq1_tau <- "-0.01"
paper_rq1_p <- "p<0.01"
paper_rq2_r <- "-0.004"
paper_rq2_p <- "0.79"

ours_n_proj <- as.character(n_proj)
ours_n_builds <- as.character(n_builds)

rq1_stat <- c(
  "Projects in corpus (Table 1)",
  "Build rows (paper corpus)",
  "Kendall tau (patch cov. vs overall cov.)",
  "p-value (Kendall)",
  "Main figure"
)
rq1_paper <- c(paper_n_proj, paper_n_builds, paper_rq1_tau, paper_rq1_p, "Fig. 2")
rq1_ours <- c(
  ours_n_proj, ours_n_builds,
  sprintf("%.4f", unname(kt_rq1$estimate)),
  format.pval(kt_rq1$p.value, digits = 3, eps = 1e-16),
  "outputs/figures/coverageofnewlines.pdf"
)

rq2_stat <- c(
  "Projects / build rows",
  "Pearson r (patch cov. vs non-patch cov.)",
  "p-value (Pearson)",
  "Kendall tau (same pair; ASE'18 gives Pearson only)",
  "Main figure"
)
rq2_paper <- c(
  paste0(paper_n_proj, " / ", paper_n_builds),
  paper_rq2_r,
  paper_rq2_p,
  "-",
  "Fig. 3"
)
rq2_ours <- c(
  paste0(ours_n_proj, " / ", ours_n_builds),
  sprintf("%.4f", unname(pr_rq2$estimate)),
  format.pval(pr_rq2$p.value, digits = 3, eps = 1e-16),
  sprintf("%.4f", unname(kt_rq2_script$estimate)),
  "outputs/figures/patchImpact.pdf"
)

bucket_labs <- c("0 stmts", "1-10", "11-100", "101-1k", "1,001+")
bucket_paper <- rep("Fig. 4 (per project)", length(bucket_labs))
bucket_ours <- sprintf("%.2f%%", as.numeric(pooled_bucket[levels(occluded$bucket)]))

rq3_stat <- c(
  "Stable-coverage rule",
  "Projects with >=1 occluded commit",
  "Occluded commits (row count)",
  paste0("Share of occluded commits: ", bucket_labs),
  "Main figure"
)
rq3_paper <- c(
  "diff. in coverage < 0.01 percentage points",
  "47 / 47",
  "not reported",
  bucket_paper,
  "Fig. 4"
)
rq3_ours <- c(
  "|ActualChangeToCoverage| < 0.0001 (= 0.01 pp)",
  paste0(proj_occluded_any, " / ", n_proj),
  as.character(n_occluded),
  bucket_ours,
  "outputs/figures/occludedImpact.pdf"
)

out_dir <- "../outputs/tables"
dir.create(out_dir, showWarnings = FALSE, recursive = TRUE)
rows <- rbind(
  data.frame(rq = "RQ1", statistic = rq1_stat, paper = rq1_paper, replication = rq1_ours, stringsAsFactors = FALSE),
  data.frame(rq = "RQ2", statistic = rq2_stat, paper = rq2_paper, replication = rq2_ours, stringsAsFactors = FALSE),
  data.frame(rq = "RQ3", statistic = rq3_stat, paper = rq3_paper, replication = rq3_ours, stringsAsFactors = FALSE)
)
rows$note <- ""
rows$note[rows$rq == "RQ1"] <- paper_text$rq1_interpretation
rows$note[rows$rq == "RQ2"] <- paper_text$rq2_interpretation
rows$note[rows$rq == "RQ3"] <- paper_text$rq3_interpretation
rows$note[rows$rq == "RQ1" & rows$statistic != rq1_stat[1]] <- ""
rows$note[rows$rq == "RQ2" & rows$statistic != rq2_stat[1]] <- ""
rows$note[rows$rq == "RQ3" & rows$statistic != rq3_stat[1]] <- ""

out_csv <- file.path(out_dir, "rq1_rq2_rq3_comparison.csv")
write.csv(rows, out_csv, row.names = FALSE)

cat("\n", strrep("=", 78), "\n", sep = "")
cat(" ASE'18 vs replication (RQ1–RQ3)\n", sep = "")
cat(strrep("=", 78), "\n", sep = "")
cat("\nPaper corpus: 47 projects, 7,816 builds. This run: ", n_proj, " projects, ", n_builds, " builds.\n", sep = "")

print_box_table(" RQ1 — Patch coverage and overall coverage", rq1_stat, rq1_paper, rq1_ours)
cat("  ", paper_text$rq1_interpretation, "\n", sep = "")

print_box_table(" RQ2 — Patch vs non-patch coverage change", rq2_stat, rq2_paper, rq2_ours)
cat("  ", paper_text$rq2_interpretation, "\n", sep = "")

print_box_table(" RQ3 — Occluded changes", rq3_stat, rq3_paper, rq3_ours)
cat("  ", paper_text$rq3_interpretation, "\n", sep = "")

cat("\n", strrep("-", 78), "\n", sep = "")
cat("Wrote:\n  ", normalizePath(out_csv, mustWork = FALSE), "\n\n", sep = "")
