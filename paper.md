---
title: 'JASP for Audit: Bayesian Tools for the Auditing Practice'
tags:
  - audit
  - Bayesian statistics
  - financial auditing
  - JfA
authors:
  - name: Koen Derks
    affiliation: "1"
  - name: Jacques de Swart
    affiliation: "1, 2"
  - name: Eric-Jan Wagenmakers
    affiliation: "3"
  - name: Jan Wille
    affiliation: "2"
  - name: Ruud Wetzels
    affiliation: "1, 2"
affiliations:
 - name: Nyenrode Business University
   index: 1
 - name: PwC Advisory
   index: 2
 - name: University of Amsterdam
   index: 3
date: 10 January 2020
bibliography: paper.bib
---

# Summary

In many countries, listed organizations are required to be audited by law. In the United States alone there were 4,397 listed companies that had at least one audit performed in 2017 [@TheWorldBank:2019]. Most audits are complex and come with high quality requirements, and the associated costs can be high [@george:2012]. Because the outcome of an audit is a probabilistic statement (for example, with 95% certainty the general ledger contains no material misstatements), much research has been done in how statistical techniques can increase audit quality and reduce audit complexity [@appelbaum:2017]. JASP for Audit (``JfA``) was developed to facilitate research into Bayesian statistics in an audit context and to simplify the statistical aspects of an audit.

``JfA`` is a module for the free and open-source statistical software platform JASP [@love:2019; @JASP:2018]. The module consists of the ``R`` [@RTeam:2019] package ``jfa`` [@derks:2020a] and a graphical user interface around the ``jfa`` package that provides a continuous workflow for the auditor, and supports audit documentation by automatically creating a report containing the results, visualizations, and statistical interpretation of these results. The graphical user interface was implemented in ``QML`` to create an interactive layout that dynamically responds to user input. This simple point-and-click layout was designed with the auditor in mind, which means that relevant options are highlighted clearly and advanced options are hidden by default. The user input is sent to the ``jfa`` package in ``R`` for fast and efficient computing of the results. The results are returned to the ``JfA`` module and displayed in such a way (i.e., with explanatory text that explains the results in non-statistical terms) that any auditor, student, and researcher, can understand the statistical theory underlying their results. In addition, the integration in ``R`` enables ``JfA`` to easily import high-quality visualization packages to create reportable tables and figures that clarify the statistical results. This approach minimizes the dependency on an auditor’s statistical knowledge so that any auditor can use ``JfA``.

The goal of ``JfA`` is to help the auditor perform their statistical analyses and interpret the results correctly. First, ``JfA`` guides the user through the standard audit sampling workflow based on the type of data and audit question and automatically selects the appropriate statistical techniques compliant with the International Standards on Auditing [@IAASB:2018]. Second, ``JfA`` supports audit documentation by generating a report containing the results and the statistical interpretation of these results. Finally, in addition to standard frequentist methods ``JfA`` enables the use of Bayesian techniques, which were previously not readily available in an audit context. ``JfA`` may be used by audit researchers, practitioners, and students, interested in statistical auditing. It has already been used in undergraduate courses on statistical auditing to provide support for course material and to explain Bayesian inference in auditing. Furthermore, ``JfA`` is being used to research how Bayesian statistics can be applied in an audit context [@derks:2020b]. To our knowledge, ``JfA`` is the first open-source software that facilitates the use of Bayesian inference in audit research and practice.

# References