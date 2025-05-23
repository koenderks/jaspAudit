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

################################################################################
################## Common functions for Bayesian calculations ##################
################################################################################

.jfaCredibleIntervalCalculation <- function(options, parentState) {
  # In calculation of the credible interval, we split the confidence from the
  # original one-sided bound in two so that it becomes two-sided.
  # Example: A 95% credible bound corresponds to the 95th percentile of the
  # posterior distribution. A 95% credible interval corresponds to the
  # 2.5th and 97.5th percentiles 2.5 and 97.5 of the posterior distribution.

  conf_lb <- (1 - parentState[["conf.level"]]) / 2
  conf_ub <- parentState[["conf.level"]] + conf_lb
  alpha <- parentState[["posterior"]][["description"]]$alpha
  beta <- parentState[["posterior"]][["description"]]$beta

  if (parentState[["method"]] == "poisson") {
    lb <- qgamma(conf_lb, shape = alpha, rate = beta)
    ub <- qgamma(conf_ub, shape = alpha, rate = beta)
  } else if (parentState[["method"]] == "binomial") {
    lb <- qbeta(conf_lb, shape1 = alpha, shape2 = beta)
    ub <- qbeta(conf_ub, shape1 = alpha, shape2 = beta)
  } else if (parentState[["method"]] == "hypergeometric") {
    lb <- jfa:::.qbbinom(conf_lb, N = parentState[["N.units"]] - parentState[["n"]], shape1 = alpha, shape2 = beta) / parentState[["N.units"]]
    ub <- jfa:::.qbbinom(conf_ub, N = parentState[["N.units"]] - parentState[["n"]], shape1 = alpha, shape2 = beta) / parentState[["N.units"]]
  }

  results <- list(lb = lb, ub = ub)

  if (options[["separateMisstatement"]] && options[["values"]] != "") {
    total_lb <- (parentState[["mle"]] + lb * parentState[["unseenValue"]]) / parentState[["N.units"]]
    total_ub <- (parentState[["mle"]] + ub * parentState[["unseenValue"]]) / parentState[["N.units"]]
    results <- list(lb = total_lb, ub = total_ub, lb_unseen = lb, ub_unseen = ub)
  }

  return(results)
}

################################################################################
################## Common functions specific to the planning stage #############
################################################################################

.jfaPlotPriorAndPosterior <- function(options, parentOptions, parentState, parentContainer, jaspResults,
                                      positionInContainer, stage) {
  if ((stage == "planning" && !options[["plotPrior"]]) || (stage == "evaluation" && !options[["plotPosterior"]])) {
    return()
  }

  .jfaFigureNumberUpdate(jaspResults)

  if (is.null(parentContainer[["plotPriorAndPosterior"]])) {
    if (stage == "planning") {
      if (options[["plotPriorWithPosterior"]]) {
        title <- gettext("Prior and Expected Posterior Distribution")
      } else {
        title <- gettext("Prior Distribution")
      }
    } else {
      title <- gettext("Prior and Posterior Distribution")
    }
    fg <- createJaspPlot(plot = NULL, title = title, width = 530, height = 350)
    fg$position <- positionInContainer
    depends <- if (stage == "planning") c("plotPrior", "plotPriorWithPosterior") else c("plotPosterior", "plotPosteriorInfo", "area", "plotPosteriorWithPrior")
    fg$dependOn(options = depends)

    parentContainer[["plotPriorAndPosterior"]] <- fg

    if (is.null(parentState[["posterior"]]) || parentContainer$getError()) {
      return()
    }

    if (stage == "planning" && !options[["plotPriorWithPosterior"]]) {
      p <- plot(parentState[["prior"]])
    } else {
      p <- plot(parentState, type = "posterior")
    }

    p <- p +
      jaspGraphs::geom_rangeframe() +
      jaspGraphs::themeJaspRaw(legend.position = c(0.8, 0.875)) +
      ggplot2::theme(
        legend.title = ggplot2::element_blank(),
        legend.text = ggplot2::element_text(margin = ggplot2::margin(0, 0, 2, 0)),
        legend.key.height = ggplot2::unit(1, "cm"),
        legend.key.width = ggplot2::unit(1.5, "cm")
      )

    if (stage == "evaluation" && options[["plotPosteriorInfo"]]) {
      if (options[["area"]] == "less") {
        label_mode <- paste0("Mode: ", formatC(parentState[["posterior"]]$statistics$mode, 3, format = "f"))
        label_ub <- paste0(round(options[["conf_level"]] * 100, 3), "% CI: [0, ", formatC(parentState[["posterior"]]$statistics$ub, 3, format = "f"), "]")
      } else if (options[["area"]] == "greater") {
        label_mode <- paste0("Mode: ", formatC(parentState[["posterior"]]$statistics$mode, 3, format = "f"))
        label_ub <- paste0(round(options[["conf_level"]] * 100, 3), "% CI: [", formatC(parentState[["posterior"]]$statistics$lb, 3, format = "f"), ", 1]")
      } else {
        label_mode <- paste0("Median: ", formatC(parentState[["posterior"]]$statistics$median, 3, format = "f"))
        int <- if (options[["separateMisstatement"]]) .jfaCredibleIntervalCalculation(options, parentState) else NULL
        lb <- if (options[["separateMisstatement"]]) int[["lb_unseen"]] else parentState[["lb"]]
        ub <- if (options[["separateMisstatement"]]) int[["ub_unseen"]] else parentState[["ub"]]
        label_ub <- paste0(round(options[["conf_level"]] * 100, 3), "% CI: [", formatC(lb, 3, format = "f"), ", ", formatC(ub, 3, format = "f"), "]")
      }
      text_right <- jaspGraphs:::draw2Lines(c(label_ub, label_mode), x = 1, align = "right")

      if (options[["materiality_test"]] && !is.na(parentState[["posterior"]]$hypotheses$bf.h1)) {
        lab1 <- switch(options[["area"]],
          "less" = "BF\u208A\u208B",
          "two.sided" = "BF\u2080\u2081",
          "greater" = "BF\u208B\u208A"
        )
        lab1 <- paste0(lab1, " = ", formatC(parentState[["posterior"]]$hypotheses$bf.h0, 3, format = "f"))
        lab2 <- switch(options[["area"]],
          "less" = "BF\u208B\u208A",
          "two.sided" = "BF\u2081\u2080",
          "greater" = "BF\u208A\u208B"
        )
        lab2 <- paste0(lab2, " = ", formatC(parentState[["posterior"]]$hypotheses$bf.h1, 3, format = "f"))
        text_left <- jaspGraphs:::draw2Lines(c(lab1, lab2), x = 0.65, align = "center")
        subscripts <- switch(options[["area"]],
          "less" = c("-+", "+-"),
          "two.sided" = c("01", "10"),
          "greater" = c("+-", "-+")
        )
        txts <- switch(options[["area"]],
          "less" = c("data | H+", "data | H-"),
          "two.sided" = c("data | H0", "data | H1"),
          "greater" = c("data | H-", "data | H+")
        )
        tmp <- jaspGraphs:::makeBFwheelAndText(BF = parentState[["posterior"]]$hypotheses$bf.h1, bfSubscripts = subscripts, pizzaTxt = txts, drawPizzaTxt = TRUE, bfType = "BF10")
        plot_middle <- tmp$gWheel
      } else {
        plot_middle <- text_left <- ggplot2::ggplot() +
          jaspGraphs::getEmptyTheme()
      }

      plotList <- list(text_left, plot_middle, text_right)
      plotList <- c(plotList, mainGraph = list(p))
      p <- jaspGraphs:::jaspGraphsPlot$new(subplots = plotList, layout = matrix(c(1, 4, 2, 4, 3, 4), nrow = 2), heights = c(0.2, 0.8), widths = c(0.4, 0.2, 0.4))
    }
    fg$plotObject <- p
  }

  if (options[["explanatoryText"]]) {
    method <- if (stage == "planning") options[["likelihood"]] else options[["method"]]
    distribution <- switch(method,
      "poisson" = gettext("gamma"),
      "binomial" = gettext("beta"),
      "hypergeometric" = gettext("beta-binomial")
    )
    if (stage == "planning") {
      caption <- createJaspHtml(gettextf(
        "<b>Figure %1$i.</b> The prior and expected posterior distribution (%2$s) on the population misstatement \u03B8. The prior parameters (%3$s = %4$s, %5$s = %6$s) are derived from the prior information. The expected posterior distribution fulfills the conditions set in the sampling objectives.",
        jaspResults[["figNumber"]]$object,
        distribution,
        "\u03B1",
        round(parentState[["prior"]][["description"]]$alpha, 3),
        "\u03B2",
        round(parentState[["prior"]][["description"]]$beta, 3)
      ), "p")
    } else {
      caption <- createJaspHtml(gettextf(
        "<b>Figure %1$i.</b> The prior and posterior distribution (%2$s) on the misstatement in the population.",
        jaspResults[["figNumber"]]$object,
        distribution
      ), "p")
    }
    caption$position <- positionInContainer + 1
    caption$dependOn(optionsFromObject = parentContainer[["plotPriorAndPosterior"]])
    caption$dependOn(options = "explanatoryText")
    parentContainer[["priorAndPosteriorPlotText"]] <- caption
  }
}

.jfaPlotPredictive <- function(options, parentOptions, parentState, parentContainer, jaspResults,
                               positionInContainer, stage) {
  if ((stage == "planning" && !options[["plotPriorPredictive"]]) || (stage == "evaluation" && !options[["plotPosteriorPredictive"]])) {
    return()
  }

  if ((stage == "planning" && options[["likelihood"]] == "hypergeometric") || (stage == "evaluation" && options[["method"]] == "hypergeometric")) {
    return()
  }

  .jfaFigureNumberUpdate(jaspResults)

  if (is.null(parentContainer[["plotPredictive"]])) {
    title <- if (stage == "planning") gettext("Prior Predictive Distribution") else gettext("Posterior Predictive Distribution")
    fg <- createJaspPlot(plot = NULL, title = title, width = 530, height = 350)
    fg$position <- positionInContainer
    depends <- if (stage == "planning") "plotPriorPredictive" else "plotPosteriorPredictive"
    fg$dependOn(options = depends)

    parentContainer[["plotPredictive"]] <- fg

    if (is.null(parentState[["posterior"]]) || parentContainer$getError()) {
      return()
    }

    size <- if (stage == "planning") parentState[["n"]] else parentState[["N.units"]] - parentState[["n"]]
    if (size <= 0) {
      fg$setError("The number of units in the population is lower than the sample size")
      return()
    }

    object <- if (stage == "planning") parentState[["prior"]] else parentState[["posterior"]]
    fg$plotObject <- plot(predict(object, size)) +
      jaspGraphs::geom_rangeframe() +
      jaspGraphs::themeJaspRaw(legend.position = "none")
  }

  if (options[["explanatoryText"]]) {
    object <- if (stage == "planning") parentState[["prior"]] else parentState[["posterior"]]
    size <- if (stage == "planning") parentState[["n"]] else parentState[["N.units"]] - parentState[["n"]]
    caption <- createJaspHtml(gettextf(
      "<b>Figure %1$i.</b> The %2$s predictive distribution is %3$s and displays the predictions of the %2$s distribution for %4$s <i>n</i> = %5$s.",
      jaspResults[["figNumber"]]$object,
      if (stage == "planning") gettext("prior") else gettext("posterior"),
      if (parentState[["posterior"]]$likelihood == "poisson") gettext("negative binomial") else gettext("beta-binomial"),
      if (stage == "planning") gettext("the intended sample of") else gettext("the remaining population of"),
      size
    ), "p")
    caption$position <- positionInContainer + 1
    caption$dependOn(optionsFromObject = parentContainer[["plotPredictive"]])
    caption$dependOn(options = "explanatoryText")
    parentContainer[["priorPredictiveText"]] <- caption
  }
}

################################################################################
################## Common functions not tied to a specific stage ###############
################################################################################

.jfaTablePriorPosterior <- function(options, parentOptions, parentState, parentContainer, jaspResults,
                                    ready = NULL, positionInContainer, stage) {
  if ((stage == "planning" && !options[["tablePrior"]]) || (stage == "evaluation" && !options[["tablePriorPosterior"]])) {
    return()
  }

  .jfaTableNumberUpdate(jaspResults)

  if (is.null(parentContainer[["tablePriorPosterior"]])) {
    title <- if (stage == "planning") gettext("Descriptive Statistics for Prior and Expected Posterior Distribution") else gettext("Descriptive Statistics for Prior and Posterior Distribution")
    tableTitle <- gettextf("<b>Table %1$i.</b> %2$s", jaspResults[["tabNumber"]]$object, title)
    tb <- createJaspTable(tableTitle)
    tb$position <- positionInContainer
    tb$transpose <- TRUE
    depends <- if (stage == "planning") c("tablePrior", "likelihood", "tableImplicitSample", "tableBookDist") else "tablePriorPosterior"
    tb$dependOn(options = depends)

    tb$addColumnInfo(name = "v", title = "", type = "string")
    tb$addColumnInfo(name = "form", title = gettext("Functional form"), type = "string")
    if (options[["materiality_test"]] && options[["area"]] != "two.sided") {
      tb$addColumnInfo(name = "hMin", title = gettextf("Support %1$s", "H\u208B"), type = "number")
      tb$addColumnInfo(name = "hPlus", title = gettextf("Support %1$s", "H\u208A"), type = "number")
      tb$addColumnInfo(name = "odds", title = gettextf("Ratio %1$s", "<sup>H\u208B</sup>&frasl;<sub>H\u208A</sub>"), type = "number")
    }
    tb$addColumnInfo(name = "mean", title = gettext("Mean"), type = "number")
    tb$addColumnInfo(name = "median", title = gettext("Median"), type = "number")
    tb$addColumnInfo(name = "mode", title = gettext("Mode"), type = "number")
    tb$addColumnInfo(name = "bound", title = gettextf("%1$s%% Upper bound", round(options[["conf_level"]] * 100, 2)), type = "number")
    tb$addColumnInfo(name = "precision", title = gettext("Precision"), type = "number")

    parentContainer[["tablePriorPosterior"]] <- tb

    names <- c(gettext("Prior"), gettext("Posterior"), gettext("Shift"))

    if (stage == "planning") {
      if (!ready || parentContainer$getError()) {
        tb[["v"]] <- names
        return()
      }
    } else if (stage == "evaluation") {
      if (!(options[["materiality_test"]] || options[["min_precision_test"]]) ||
        ((options[["values.audit"]] == "" || options[["id"]] == "") && options[["dataType"]] %in% c("data", "pdata")) ||
        (options[["dataType"]] == "stats" && options[["n"]] == 0) ||
        (parentOptions[["materiality_val"]] == 0 && options[["materiality_test"]]) ||
        parentContainer$getError()) {
        tb[["v"]] <- names
        return()
      }
    }

    likelihood <- if (stage == "planning") parentState[["likelihood"]] else parentState[["method"]]

    N <- parentState[["N.units"]]
    prior <- parentState[["prior"]]
    posterior <- parentState[["posterior"]]
    n <- parentState[["n"]]

    if (posterior[["description"]]$density != "MCMC") {
      if (likelihood == "poisson") {
        formPrior <- paste0("gamma(\u03B1 = ", round(prior[["description"]]$alpha, 3), ", \u03B2 = ", round(prior[["description"]]$beta, 3), ")")
        formPost <- paste0("gamma(\u03B1 = ", round(posterior[["description"]]$alpha, 3), ", \u03B2 = ", round(posterior[["description"]]$beta, 3), ")")
      } else if (likelihood == "binomial") {
        formPrior <- paste0("beta(\u03B1 = ", round(prior[["description"]]$alpha, 3), ", \u03B2 = ", round(prior[["description"]]$beta, 3), ")")
        formPost <- paste0("beta(\u03B1 = ", round(posterior[["description"]]$alpha, 3), ", \u03B2 = ", round(posterior[["description"]]$beta, 3), ")")
      } else if (likelihood == "hypergeometric") {
        formPrior <- paste0("beta-binomial(N = ", N, ", \u03B1 = ", round(prior[["description"]]$alpha, 3), ", \u03B2 = ", round(prior[["description"]]$beta, 3), ")")
        formPost <- paste0("beta-binomial(N = ", N - n, ", \u03B1 = ", round(posterior[["description"]]$alpha, 3), ", \u03B2 = ", round(posterior[["description"]]$beta, 3), ")")
      }
    } else {
      formPrior <- gettext("Nonparametric")
      formPost <- gettext("Nonparametric")
    }

    rows <- data.frame(
      v = names,
      form = c(formPrior, formPost, ""),
      mean = c(prior[["statistics"]]$mean, posterior[["statistics"]]$mean, posterior[["statistics"]]$mean - prior[["statistics"]]$mean),
      median = c(prior[["statistics"]]$median, posterior[["statistics"]]$median, posterior[["statistics"]]$median - prior[["statistics"]]$median),
      mode = c(prior[["statistics"]]$mode, posterior[["statistics"]]$mode, posterior[["statistics"]]$mode - prior[["statistics"]]$mode),
      bound = c(prior[["statistics"]]$ub, posterior[["statistics"]]$ub, posterior[["statistics"]]$ub - prior[["statistics"]]$ub),
      precision = c(prior[["statistics"]]$precision, posterior[["statistics"]]$precision, NA)
    )
    if (options[["materiality_test"]] && options[["area"]] != "two.sided") {
      rows <- cbind(rows,
        hMin = c(prior[["hypotheses"]][["p.h1"]], posterior[["hypotheses"]][["p.h1"]], posterior[["hypotheses"]][["p.h1"]] / prior[["hypotheses"]][["p.h1"]]),
        hPlus = c(prior[["hypotheses"]][["p.h0"]], posterior[["hypotheses"]][["p.h0"]], posterior[["hypotheses"]][["p.h0"]] / prior[["hypotheses"]][["p.h0"]]),
        odds = c(prior[["hypotheses"]][["odds.h1"]], posterior[["hypotheses"]][["odds.h1"]], posterior[["hypotheses"]][["bf.h1"]])
      )
      if (likelihood != "hypergeometric") {
        tb$addFootnote(message = gettextf("%1$s %2$s vs. %3$s %2$s.", "H\u208B: \u03B8 <", round(parentState[["materiality"]], 3), "H\u208A: \u03B8 >"))
      } else {
        tb$addFootnote(message = gettextf("%1$s %2$s vs. %3$s %2$s.", "H\u208B: \u03B8 <", ceiling(parentState[["materiality"]] * parentState[["N.units"]]), "H\u208A: \u03B8 >="))
      }
    }

    tb$addRows(rows)
  }
}

.jfaPlotSequentialAnalysisEvaluation <- function(options, jaspResults, parentState, parentContainer, positionInContainer, sample, evaluationOptions) {
  if (!options[["plotSequentialAnalysis"]] || options[["dataType"]] == "stats" || !options[["materiality_test"]] || options[["stratum"]] != "" || options[["separateMisstatement"]] || options[["hurdle"]]) {
    return()
  }

  .jfaFigureNumberUpdate(jaspResults)

  if (is.null(parentContainer[["sequentialAnalysisPlot"]])) {
    fg <- createJaspPlot(title = gettext("Sequential Analysis"), width = 600, height = 400)
    fg$position <- positionInContainer
    fg$dependOn(options = "plotSequentialAnalysis")

    parentContainer[["sequentialAnalysisPlot"]] <- fg

    if (is.null(parentState) || parentContainer$getError()) {
      return()
    }

    if (all(unique(sample[[options[["values.audit"]]]]) %in% c(0, 1))) {
      binaryData <- data.frame(book = rep(1, nrow(sample)), audit = ifelse(sample[[options[["values.audit"]]]] == 0, 1, 0))
      binaryData$times <- sample[[options[["times"]]]]
      result <-
        jfa::evaluation(
          conf.level = parentState[["conf.level"]], materiality = parentState[["materiality"]],
          data = binaryData, values = "book", values.audit = "audit",
          method = parentState[["method"]], prior = parentState[["prior"]], alternative = parentState[["alternative"]],
          N.units = parentState[["N.units"]], times = if (options[["times"]] != "") "times" else NULL
        )
      parentState <- result
    }

    if (is.infinite(parentState[["posterior"]][["hypotheses"]][["bf.h1"]])) {
      fg$setError(gettext("Plot not possible: The Bayes factor is infinite."))
    } else {
      fg$plotObject <- plot(parentState, type = "sequential") +
        jaspGraphs::geom_rangeframe() +
        jaspGraphs::themeJaspRaw()
    }
  }

  if (options[["explanatoryText"]]) {
    caption_part1 <- gettextf(
      "<b>Figure %1$i.</b> The Bayes factor as a function of the sample size (n).",
      jaspResults[["figNumber"]]$object
    )
    caption_part2 <- switch(options[["area"]],
      "less" = gettext("The figure illustrates how the evidence for the hypothesis H\u2081 (i.e. H\u208B) versus the hypothesis H\u2080 (i.e. H\u208A) accumulates."),
      "greater" = gettext("The figure illustrates how the evidence for the hypothesis H\u2081 (i.e. H\u208A) versus the hypothesis H\u2080 (i.e. H\u208B) accumulates."),
      "two.sided" = gettext("The figure illustrates how the evidence for the hypothesis H\u2081 versus the hypothesis H\u2080 accumulates."),
    )
    caption <- createJaspHtml(paste(caption_part1, caption_part2), "p")
    caption$position <- positionInContainer + 1
    caption$dependOn(optionsFromObject = parentContainer[["sequentialAnalysisPlot"]])
    caption$dependOn(options = c("explanatoryText", "area"))
    parentContainer[["sequentialAnalysisPlotText"]] <- caption
  }
}

################################################################################
################## End Bayesian functions ######################################
################################################################################
