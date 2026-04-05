# Correlate patch coverage with change in non-patch coverage.
# Use `patchCor` not `allCur`: coverageOfNewLines.R leaves a global `clean` that can
# interact badly with subset() if we reused the same names as that script.

patchCor <- allData
patchCor$PercentageOfDiffCovered <- with(patchCor, (newHitLines + newFileHitLines) /
  (newHitLines + newNonHitLines + newFileHitLines + newFileNonHitLines))
clean <- subset(patchCor,
  !is.na(PercentageOfDiffCovered) &
    is.finite(PercentageOfDiffCovered) &
    !is.nan(PercentageOfDiffCovered)
)

clean$patchHit <- clean$newFileHitLines + clean$newHitLines
clean$patchTotal <- clean$newFileNonHitLines + clean$newNonHitLines
clean$nonPatchHit <- clean$totalStatementsHitNow - clean$patchHit
clean$nonPatchTotal <- clean$totalStatementsNow - clean$patchTotal

clean$changeToNonPatchCoverage <- (clean$nonPatchHit - clean$totalStatementsHitPrev) /
  (clean$nonPatchTotal - clean$totalStatementsPrev)
clean <- subset(clean,
  !is.na(changeToNonPatchCoverage) &
    is.finite(changeToNonPatchCoverage) &
    !is.nan(changeToNonPatchCoverage)
)

kt <- stats::cor.test(
  x = clean$PercentageOfDiffCovered, y = clean$changeToNonPatchCoverage,
  use = "complete.obs", method = "kendall", exact = FALSE
)
print(kt)
cat("\n=== Kendall: patch coverage vs change in non-patch coverage (paper RQ2 reports Pearson for this pair) ===\n\n")
