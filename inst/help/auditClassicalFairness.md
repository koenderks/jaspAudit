Fairness Metrics
===

The fairness metrics analysis enables the user to assess fairness and discrimination regarding specific groups in the data in algorithmic decision-making systems. Considering a certain positive class in the data, fairness -or discrimination- can be quantified using model-agnostic fairness metrics. The ratio of two fairness metrics is called parity, which is a well-known concept in algorithmic fairness.

### Input
---

#### Assignment Box
- Ground Truth Information: In this box the target (i.e., to be predicted) variable should be entered.
- Predictions: In this box the predictions of the algorithm about the target variable should be entered.
- Sensitive Attribute: In this box the protected (i.e., sensitive) attribute should be entered.

#### Analysis
- Confidence: The confidence level used. The confidence level is the complement of the audit risk: the risk that the user is willing to take to give an incorrect judgment about the population. For example, if you want to use an audit risk of 5%, this equals 95% confidence.
- Fairness Measure: The type of fairness metric to compute.

#### Levels
- Privileged group: The privileged group refers to the class in the protected variable that historically or systematically experiences certain advantages, benefits, or privileges.
- Positive class: The positive class in the target variable.

### Alt. Hypothesis
- Unprivileged \u2260 Privileged: Test the alternative hypothesis that the fairness metric of an unprivileged group is not equal to the fairness metric in the privileged group.
- Unprivileged < Privileged: Test the alternative hypothesis that the fairness metric of an unprivileged group is lower than the fairness metric in the privileged group.
- Unprivileged > Privileged: Test the alternative hypothesis that the fairness metric of an unprivileged group is higher than the fairness metric in the privileged group.

#### Display
- Explanatory Text: When checked, enables explanatory text in the analysis to help interpret the procedure and the statistical results.

#### Report
- Tables
  - Individual comparisons: Produces a table comparing the unprivileged groups against the privileged group.
  - Model performance: Produces a table containing the performance measures for the classification, including support, accuracy, precision, recall and F1-score.
  - Confusion matrix: Produces the confusion matrix for each group.
    - Display proportions: Displays proportions in the confusion table.
    - Traspose matrix: Displays the transposed confusion matrix (i.e., a variation of the standard confusion matrix where rows and columns are swapped). 

- Plots
  - Parity estimates: Produces a plot showing the parity statistics for each unprivileged group against the privileged group.
  

### References
---
- Derks, K. (2023). jfa: Statistical Methods for Auditing. R package (latest version). https://cran.r-project.org/package=jfa

### R Packages
---
- jfa
