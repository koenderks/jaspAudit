#
# Copyright (C) 2013-2018 University of Amsterdam
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
#
# When making changes to this file always mention @koenderks as a
# reviewer in the pull Request.

auditClassicalBenfordsLaw <- function(jaspResults, dataset, options, ...) {
  # Create the procedure paragraph
  .jfaBenfordsLawAddProcedure(options, jaspResults, position = 1)

  # Read in the data
  dataset <- .jfaBenfordsLawReadData(dataset, options)

  # Perform early error checks
  .jfaBenfordsLawDataCheck(dataset, options)

  # Ready for analysis
  ready <- .jfaBenfordsLawReadyCheck(options)

  benfordsLawContainer <- .jfaBenfordsLawStage(options, jaspResults, position = 2)

  # --- TABLES

  .jfaTableNumberInit(jaspResults) # Initialize table numbers

  # Create the goodness-of-fit table
  .jfaBenfordsLawTable(dataset, options, benfordsLawContainer, jaspResults, ready, positionInContainer = 1)

  # Create the observed and predicted probabilities table
  .jfaBenfordsLawDescriptivesTable(dataset, options, benfordsLawContainer, jaspResults, ready, positionInContainer = 2)

  # Create the matched rows table
  .jfaBenfordsLawMatchTable(dataset, options, benfordsLawContainer, jaspResults, ready, positionInContainer = 3)

  # ---

  # --- PLOTS

  .jfaFigureNumberInit(jaspResults) # Initialize figure numbers

  # Create the observed and predicted probabilities plot
  .jfaBenfordsLawPlot(dataset, options, benfordsLawContainer, jaspResults, ready, positionInContainer = 4)

  # Create the Bayes factor robustness plot
  .jfaBenfordsLawRobustnessPlot(dataset, options, benfordsLawContainer, jaspResults, ready, positionInContainer = 6)

  # Create the sequential analysis plot
  .jfaBenfordsLawSequentialPlot(dataset, options, benfordsLawContainer, jaspResults, ready, positionInContainer = 8)

  # ---

  # Create the conclusion paragraph
  .jfaBenfordsLawAddConclusion(options, benfordsLawContainer, jaspResults, ready, position = 3)

  # ---

  .jfaCreatedByText(jaspResults)
}

.jfaBenfordsLawReadData <- function(dataset, options) {
  values <- options[["values"]]
  if (values == "") {
    values <- NULL
  }
  dataset <- jaspBase::excludeNaListwise(dataset, values)
  return(dataset)
}

.jfaBenfordsLawAddProcedure <- function(options, jaspResults, position) {
  if (options[["explanatoryText"]] &&
    is.null(jaspResults[["procedureContainer"]])) {
    procedureContainer <- createJaspContainer(title = gettext("<u>Procedure</u>"))
    procedureContainer$position <- position

    confidenceLabel <- paste0(round((1 - options[["confidence"]]) * 100, 2), "%")

    if (options[["distribution"]] == "benford") {
      procedureText <- switch(options[["digits"]],
        "first" = gettextf("Benford's law states that in many naturally occurring collections of numerical observations, the leading significant digit is likely to be small. The goal of this procedure is to determine to what extent the first leading digits in the data set follow Benford's law, and to test this relation with a type-I error of %1$s. Data that are not distributed according to Benford's law might need further investigation.", confidenceLabel),
        "firsttwo" = gettextf("Benford's law states that in many naturally occurring collections of numerical observations, the leading significant digit is likely to be small. The goal of this procedure is to determine to what extent the first two leading digits in the data set follow Benford's law, and to test this relation with a type-I error of %1$s. Data that are not distributed according to Benford's law might need further investigation.", confidenceLabel),
        "last" = gettextf("Benford's law states that in many naturally occurring collections of numerical observations, the leading significant digit is likely to be small. The goal of this procedure is to determine to what extent the last digits in the data set follow Benford's law, and to test this relation with a type-I error of %1$s. Data that are not distributed according to Benford's law might need further investigation.", confidenceLabel)
      )
    } else if (options[["distribution"]] == "uniform") {
      procedureText <- switch(options[["digits"]],
        "first" = gettextf("The uniform distribution assigns equal probability to all possible digits that may occur. The goal of this procedure is to determine to what extent the first leading digits in the data set follow the uniform distribution, and to test this relation with a type-I error of %1$s. If the uniform distribution assumption is desirable, then violation of uniformity is cause for further investigation.", confidenceLabel),
        "firsttwo" = gettextf("The uniform distribution assigns equal probability to all possible digits that may occur. The goal of this procedure is to determine to what extent the first two leading digits in the data set follow the uniform distribution, and to test this relation with a type-I error of %1$s. If the uniform distribution assumption is desirable, then violation of uniformity is cause for further investigation.", confidenceLabel),
        "last" = gettextf("The uniform distribution assigns equal probability to all possible digits that may occur. The goal of this procedure is to determine to what extent the last digits in the data set follow the uniform distribution, and to test this relation with a type-I error of %1$s. If the uniform distribution assumption is desirable, then violation of uniformity is cause for further investigation.", confidenceLabel)
      )
    }
    procedureContainer[["procedureParagraph"]] <- createJaspHtml(procedureText, "p")
    procedureContainer[["procedureParagraph"]]$position <- 1
    procedureContainer$dependOn(options = c(
      "explanatoryText",
      "confidence",
      "digits",
      "distribution"
    ))

    jaspResults[["procedureContainer"]] <- procedureContainer
  }
}

.jfaBenfordsLawDataCheck <- function(dataset, options) {
  if (options[["values"]] == "") {
    return()
  }

  .hasErrors(dataset,
    type = c("infinity", "observations"),
    all.target = options[["values"]],
    message = "short",
    observations.amount = "< 2",
    exitAnalysisIfErrors = TRUE
  )
}

.jfaBenfordsLawReadyCheck <- function(options) {
  ready <- options[["values"]] != ""
  return(ready)
}

.jfaBenfordsLawStage <- function(options, jaspResults, position) {
  containerTitle <- switch(options[["distribution"]],
    "benford" = gettext("<u>Assessing Benford's Law</u>"),
    "uniform" = gettext("<u>Assessing the Uniform Distribution</u>")
  )
  benfordsLawContainer <- createJaspContainer(title = containerTitle)
  benfordsLawContainer$position <- position
  benfordsLawContainer$dependOn(options = c(
    "values",
    "confidence",
    "digits",
    "distribution",
    "concentration"
  ))

  jaspResults[["benfordsLawContainer"]] <- benfordsLawContainer

  return(benfordsLawContainer)
}

.jfaBenfordsLawState <- function(dataset, options, benfordsLawContainer, ready) {
  if (!is.null(benfordsLawContainer[["result"]])) {
    return(benfordsLawContainer[["result"]]$object)
  } else if (ready) {
    test <- jfa::digit_test(
      dataset[[options[["values"]]]],
      check = options[["digits"]],
      reference = options[["distribution"]],
      conf.level = options[["confidence"]]
    )
    btest <- jfa::digit_test(
      dataset[[options[["values"]]]],
      check = options[["digits"]],
      reference = options[["distribution"]],
      conf.level = options[["confidence"]],
      prior = options[["concentration"]]
    )
    estimates <- test$estimates
    estimates$bf10 <- btest$estimates$bf10
    result <- list(
      object = test,
      bobject = btest,
      digits = as.numeric(test$digits),
      relFrequencies = as.numeric(test$observed) / as.numeric(test$n),
      inBenford = as.numeric(test$expected) / as.numeric(test$n),
      N = as.numeric(test$n),
      observed = as.numeric(test$observed),
      expected = as.numeric(test$expected),
      chiSquare = as.numeric(test$statistic),
      df = as.numeric(test$parameter),
      pvalue = as.numeric(test$p.value),
      logBF10 = as.numeric(log(btest$bf)),
      estimates = estimates,
      mad = as.numeric(test$mad)
    )

    benfordsLawContainer[["result"]] <- createJaspState(result)
    benfordsLawContainer[["result"]]$dependOn(options = c(
      "values",
      "confidence",
      "digits",
      "distribution",
      "concentration"
    ))
    return(benfordsLawContainer[["result"]]$object)
  } else {
    return(list())
  }
}

.jfaBenfordsLawTable <- function(dataset, options, benfordsLawContainer,
                                 jaspResults, ready, positionInContainer) {
  .jfaTableNumberUpdate(jaspResults)

  if (!is.null(benfordsLawContainer[["benfordsLawTestTable"]])) {
    return()
  }

  title_dist <- switch(options[["distribution"]],
    "benford" = gettext("Benford's Law"),
    "uniform" = gettext("Uniform Distribution")
  )
  title <- gettextf(
    "<b>Table %1$i.</b> Omnibus Test - %2$s",
    jaspResults[["tabNumber"]]$object,
    title_dist
  )
  bftitle <- switch(options[["bayesFactorType"]],
    "BF10" = gettextf("BF%1$s", "\u2081\u2080"),
    "BF01" = gettextf("BF%1$s", "\u2080\u2081"),
    "logBF10" = gettextf("Log(BF%1$s)", "\u2081\u2080")
  )

  tb <- createJaspTable(title)
  tb$position <- positionInContainer
  tb$dependOn(options = "bayesFactorType")
  tb$addColumnInfo(name = "test", title = "", type = "string")
  tb$addColumnInfo(name = "N", title = "n", type = "integer")
  tb$addColumnInfo(name = "mad", title = gettext("MAD"), type = "number")
  tb$addColumnInfo(name = "value", title = "X\u00B2", type = "number")
  tb$addColumnInfo(name = "df", title = gettext("df"), type = "integer")
  tb$addColumnInfo(name = "pvalue", title = "p", type = "pvalue")
  tb$addColumnInfo(name = "bf", title = bftitle, type = "number")

  distribution <- switch(options[["distribution"]],
    "benford" = gettext("Benford's law"),
    "uniform" = gettext("the uniform distribution")
  )
  message <- switch(options[["digits"]],
    "first" = gettextf("The null hypothesis specifies that the first digits (1 - 9) in the data set are distributed according to %1$s.", distribution),
    "firsttwo" = gettextf("The null hypothesis specifies that the first two digits (10 - 99) in the data set are distributed according to %1$s.", distribution),
    "last" = gettextf("The null hypothesis specifies that the last digits (1 - 9) in the data set are distributed according to %1$s.", distribution)
  )
  tb$addFootnote(message)

  benfordsLawContainer[["benfordsLawTestTable"]] <- tb

  if (!ready) {
    return()
  }

  state <- .jfaBenfordsLawState(dataset, options, benfordsLawContainer, ready)

  tb[["test"]] <- options[["values"]]
  tb[["N"]] <- state[["N"]]
  tb[["mad"]] <- state[["mad"]]
  tb[["value"]] <- state[["chiSquare"]]
  tb[["df"]] <- state[["df"]]
  tb[["pvalue"]] <- state[["pvalue"]]
  tb[["bf"]] <- switch(options[["bayesFactorType"]],
    "BF10" = exp(state[["logBF10"]]),
    "BF01" = 1 / exp(state[["logBF10"]]),
    "logBF10" = state[["logBF10"]]
  )

  message <- gettextf("The Bayes factor is computed using a Dirichlet(%1$s,...,%2$s%3$s) prior with %2$s = %4$s.", "\u03B1\u2081", "\u03B1", if (options[["digits"]] == "first" || options[["digits"]] == "last") "\u2089" else "\u2089\u2089", options[["concentration"]])
  tb$addFootnote(message, colName = "bf")
  if (any(state[["expected"]] < 5)) {
    warning <- gettext("<b>Warning.</b> The <i>p</i>-value may be unreliable due to some expected counts being lower than 5.")
    tb$addFootnote(warning, colName = "pvalue")
  }
}

.jfaBenfordsLawDescriptivesTable <- function(dataset, options, benfordsLawContainer,
                                             jaspResults, ready, positionInContainer) {
  if (!options[["summaryTable"]]) {
    return()
  }

  .jfaTableNumberUpdate(jaspResults)

  if (is.null(benfordsLawContainer[["benfordsLawTable"]])) {
    title <- gettextf(
      "<b>Table %1$i.</b> Frequency Table",
      jaspResults[["tabNumber"]]$object
    )

    tb <- createJaspTable(title)
    tb$position <- positionInContainer
    tb$dependOn(options = c("summaryTable", "confidenceInterval", "expectedCounts"))
    dtitle <- switch(options[["digits"]],
      "first" = gettext("Leading digit"),
      "firsttwo" = gettext("Leading digits"),
      "last" = gettext("Last digit")
    )
    etitle <- switch(options[["distribution"]],
      "benford" = gettext("Benford's law"),
      "uniform" = gettext("Uniform distribution")
    )
    tb$addColumnInfo(name = "digit", title = dtitle, type = "integer")
    tb$addColumnInfo(name = "count", title = gettext("Count"), type = "integer")
    tb$addColumnInfo(name = "obs", title = gettext("Relative frequency"), type = "number")
    if (options[["confidenceInterval"]]) {
      otitle <- gettextf("%1$s%% Confidence Interval", paste0(round(options[["confidence"]] * 100, 3)))
      tb$addColumnInfo(name = "lb", title = gettext("Lower"), type = "number", overtitle = otitle)
      tb$addColumnInfo(name = "ub", title = gettext("Upper"), type = "number", overtitle = otitle)
    }
    if (options[["expectedCounts"]]) {
      tb$addColumnInfo(name = "exp_count", title = gettext("Expected count"), type = "number")
    }
    tb$addColumnInfo(name = "exp", title = etitle, type = "number")
    tb$addColumnInfo(name = "pval", title = "p", type = "pvalue")
    bftitle <- switch(options[["bayesFactorType"]],
      "BF10" = gettextf("BF%1$s", "\u2081\u2080"),
      "BF01" = gettextf("BF%1$s", "\u2080\u2081"),
      "logBF10" = gettextf("Log(BF%1$s)", "\u2081\u2080")
    )
    tb$addColumnInfo(name = "bf", title = bftitle, type = "number")
    messageTitle <- switch(options[["distribution"]],
      "benford" = gettext("Benford's law"),
      "uniform" = gettext("the uniform distribution")
    )
    tb$addFootnote(gettextf("The null hypothesis specifies that the relative frequency of a digit is equal to its expected relative frequency under %1$s.", messageTitle))

    benfordsLawContainer[["benfordsLawTable"]] <- tb

    if (options[["digits"]] == "first" || options[["digits"]] == "last") {
      digits <- 1:9
    } else {
      digits <- 10:99
    }

    if (!ready) {
      tb[["digit"]] <- digits
      tb[["count"]] <- rep(".", length(digits))
      tb[["obs"]] <- rep(".", length(digits))
      if (options[["expectedCounts"]]) {
        tb[["exp_count"]] <- rep(".", length(digits))
      }
      tb[["exp"]] <- switch(options[["distribution"]],
        "benford" = log10(1 + 1 / digits),
        "uniform" = 1 / length(digits)
      )
      tb[["pval"]] <- rep(".", length(digits))
      tb[["bf"]] <- rep(".", length(digits))
      if (options[["confidenceInterval"]]) {
        tb[["lb"]] <- rep(".", length(digits))
        tb[["ub"]] <- rep(".", length(digits))
      }
      return()
    }

    state <- .jfaBenfordsLawState(dataset, options, benfordsLawContainer, ready)
    tb[["digit"]] <- state[["digits"]]
    tb[["count"]] <- state[["observed"]]
    tb[["obs"]] <- state[["relFrequencies"]]
    if (options[["expectedCounts"]]) {
      tb[["exp_count"]] <- state[["expected"]]
    }
    tb[["exp"]] <- state[["inBenford"]]
    tb[["pval"]] <- state[["estimates"]]$p.value
    tb[["bf"]] <- switch(options[["bayesFactorType"]],
      "BF10" = state[["estimates"]]$bf10,
      "BF01" = 1 / state[["estimates"]]$bf10,
      "logBF10" = log(state[["estimates"]]$bf10)
    )
    tb$addFootnote(gettext("Bayes factors are computed using a beta(1, 1) prior."), colName = "bf")
    if (options[["confidenceInterval"]]) {
      tb[["lb"]] <- state[["estimates"]]$lb
      tb[["ub"]] <- state[["estimates"]]$ub
      tb$addFootnote(gettext("Confidence intervals and <i>p</i>-values are based on independent binomial distributions."), colName = "pval")
    } else {
      tb$addFootnote(gettext("The <i>p</i>-values are based on independent binomial distributions."), colName = "pval")
    }
  }
}

.jfaBenfordsLawMatchTable <- function(dataset, options, benfordsLawContainer,
                                      jaspResults, ready, positionInContainer) {
  if (!options[["matchTable"]]) {
    return()
  }

  .jfaTableNumberUpdate(jaspResults)

  if (is.null(benfordsLawContainer[["matchTable"]])) {
    label_digit <- switch(options[["digits"]],
      "first" = gettext("Leading Digit"),
      "firsttwo" = gettext("Leading Digits"),
      "last" = gettext("Last Digit")
    )
    title <- gettextf(
      "<b>Table %1$i.</b> Rows Matched to %2$s %3$s",
      jaspResults[["tabNumber"]]$object,
      label_digit,
      options[["match"]]
    )

    tb <- createJaspTable(title)
    tb$position <- positionInContainer
    tb$dependOn(options = c("matchTable", "match"))
    tb$addColumnInfo(name = "row", title = gettext("Row"), type = "integer")
    tb$addColumnInfo(name = "value", title = gettext("Value"), type = "number")

    benfordsLawContainer[["matchTable"]] <- tb

    if (!ready) {
      return()
    }

    if (options[["digits"]] != "firsttwo" && options[["match"]] > 9) {
      tb$addFootnote(gettext("The requested digit must be between 1 - 9."),
        symbol = gettext("<b>Warning.</b>")
      )
    } else if (options[["digits"]] == "firsttwo" && options[["match"]] < 10) {
      tb$addFootnote(gettext("The requested digit must be between 10 - 99."),
        symbol = gettext("<b>Warning.</b>")
      )
    } else {
      tb$addFootnote(gettext("Displayed values are rounded to the number of decimals set in the global preferences."))
    }

    state <- .jfaBenfordsLawState(dataset, options, benfordsLawContainer, ready)
    tb$setData(state[["object"]][["match"]][[as.character(options[["match"]])]])
  }
}

.jfaBenfordsLawPlot <- function(dataset, options, benfordsLawContainer,
                                jaspResults, ready, positionInContainer) {
  if (!options[["benfordsLawPlot"]]) {
    return()
  }

  .jfaFigureNumberUpdate(jaspResults)

  if (is.null(benfordsLawContainer[["benfordsLawPlot"]])) {
    fg <- createJaspPlot(
      plot = NULL,
      title = gettext("Observed vs. Expected Relative Frequencies"),
      width = 600, height = 400
    )

    fg$position <- positionInContainer
    fg$dependOn(options = "benfordsLawPlot")

    benfordsLawContainer[["benfordsLawPlot"]] <- fg

    if (!ready) {
      return()
    }

    state <- .jfaBenfordsLawState(dataset, options, benfordsLawContainer, ready)

    fg$plotObject <- plot(state[["object"]], type = "estimates") +
      jaspGraphs::geom_rangeframe() +
      jaspGraphs::themeJaspRaw(legend.position = "top")
  }

  if (options[["explanatoryText"]]) {
    distribution <- switch(options[["distribution"]],
      "benford" = "Benford's law",
      "uniform" = "the uniform distribution"
    )
    caption <- createJaspHtml(gettextf("<b>Figure %1$i.</b> The observed relative frequencies of each digit in the data set compared to the expected relative frequencies under %2$s. For data sets distributed according %2$s the blue dots will lie near the top of the grey bars.", jaspResults[["figNumber"]]$object, distribution), "p")
    caption$position <- positionInContainer + 1
    caption$dependOn(optionsFromObject = benfordsLawContainer[["benfordsLawPlot"]])
    benfordsLawContainer[["benfordsLawPlotText"]] <- caption
  }
}

.jfaBenfordsLawRobustnessPlot <- function(dataset, options, benfordsLawContainer,
                                          jaspResults, ready, positionInContainer) {
  if (!options[["robustnessPlot"]]) {
    return()
  }

  .jfaFigureNumberUpdate(jaspResults)

  if (is.null(benfordsLawContainer[["robustnessPlot"]])) {
    fg <- createJaspPlot(title = gettext("Bayes Factor Robustness Plot"), width = 530, height = 450)
    fg$position <- positionInContainer
    fg$dependOn(options = "robustnessPlot")
    benfordsLawContainer[["robustnessPlot"]] <- fg
    if (!ready) {
      return()
    }
    state <- .jfaBenfordsLawState(dataset, options, benfordsLawContainer, ready)
    fg$plotObject <- plot(state[["bobject"]], type = "robustness") +
      jaspGraphs::geom_rangeframe() +
      jaspGraphs::themeJaspRaw(legend.position = "top")
  }
  if (options[["explanatoryText"]]) {
    caption <- createJaspHtml(gettextf("<b>Figure %1$i.</b> The results of a robustness check using the Bayes factor. The figure illustrates the impact of different specifications (i.e., concentration parameters) of the Dirichlet prior on the Bayes factor values, providing insights into the robustness of the statistical evidence to the choice of prior distribution.", jaspResults[["figNumber"]]$object), "p")
    caption$position <- positionInContainer + 1
    caption$dependOn(optionsFromObject = benfordsLawContainer[["robustnessPlot"]])
    benfordsLawContainer[["robustnessPlotText"]] <- caption
  }
}

.jfaBenfordsLawSequentialPlot <- function(dataset, options, benfordsLawContainer,
                                          jaspResults, ready, positionInContainer) {
  if (!options[["sequentialPlot"]]) {
    return()
  }

  .jfaFigureNumberUpdate(jaspResults)

  if (is.null(benfordsLawContainer[["sequentialPlot"]])) {
    fg <- createJaspPlot(title = gettext("Sequential Analysis Plot"), width = 530, height = 350)
    fg$position <- positionInContainer
    fg$dependOn(options = "sequentialPlot")
    benfordsLawContainer[["sequentialPlot"]] <- fg
    if (!ready) {
      return()
    }
    state <- .jfaBenfordsLawState(dataset, options, benfordsLawContainer, ready)
    fg$plotObject <- plot(state[["bobject"]], type = "sequential") +
      jaspGraphs::geom_rangeframe() +
      jaspGraphs::themeJaspRaw(legend.position = "top")
  }
  if (options[["explanatoryText"]]) {
    caption <- createJaspHtml(gettextf("<b>Figure %1$i.</b> The results of a sequential analysis using the Bayes factor. The figure provides insight into how the statistical evidence from these data accumulates over time and under different prior specifications.", jaspResults[["figNumber"]]$object), "p")
    caption$position <- positionInContainer + 1
    caption$dependOn(optionsFromObject = benfordsLawContainer[["sequentialPlot"]])
    benfordsLawContainer[["sequentialPlotText"]] <- caption
  }
}

.jfaBenfordsLawAddConclusion <- function(options, benfordsLawContainer, jaspResults,
                                         ready, position) {
  if (!is.null(jaspResults[["conclusionContainer"]]) || !ready || !options[["explanatoryText"]]) {
    return()
  }

  container <- createJaspContainer(title = gettext("<u>Conclusion</u>"))
  container$position <- position
  container$dependOn(options = c(
    "values",
    "confidence",
    "digits",
    "explanatoryText",
    "distribution"
  ))

  state <- .jfaBenfordsLawState(dataset = NULL, options, benfordsLawContainer, ready)

  rejectnull <- state[["pvalue"]] < (1 - options[["confidence"]])
  conclusion <- if (rejectnull) gettext("is rejected") else gettext("is not rejected")
  pvalue <- format.pval(state[["pvalue"]], eps = 0.001)
  pvalue <- if (rejectnull) gettextf("%1$s < %2$s", pvalue, "\u03B1") else gettextf("%1$s >= %2$s", pvalue, "\u03B1")
  distribution <- switch(options[["distribution"]],
    "benford" = "Benford's law",
    "uniform" = "the uniform distribution"
  )

  caption <- switch(options[["digits"]],
    "first" = gettextf("The <i>p</i>-value is %1$s and the null hypothesis that the first digits in the data set are distributed according to %2$s %3$s.", pvalue, distribution, conclusion),
    "firsttwo" = gettextf("The <i>p</i>-value is %1$s and the null hypothesis that the first two digits in the data set are distributed according to %2$s %3$s.", pvalue, distribution, conclusion),
    "last" = gettextf("The <i>p</i>-value is %1$s and the null hypothesis that the last digits in the data set are distributed according to %2$s %3$s.", pvalue, distribution, conclusion)
  )
  caption <- gettextf("%1$s The Bayes factor indicates that the data are %2$s times more likely to occur under the null hypothesis than under the alternative hypothesis.", caption, format(1 / exp(state[["logBF10"]]), digits = 3))

  container[["conclusionParagraph"]] <- createJaspHtml(caption, "p")
  container[["conclusionParagraph"]]$position <- 1
  container$dependOn(options = c(
    "explanatoryText",
    "confidence",
    "values",
    "digits",
    "distribution"
  ))

  jaspResults[["conclusionContainer"]] <- container
}
