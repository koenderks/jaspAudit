
// Copyright (C) 2013-2018 University of Amsterdam
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
// You should have received a copy of the GNU Affero General Public
// License along with this program.  If not, see
// <http://www.gnu.org/licenses/>.
//

// When making changes to this file always mention @koenderks as a
// reviewer in the Pull Request

import QtQuick
import QtQuick.Layouts
import JASP
import JASP.Controls
import JASP.Widgets

RadioButtonGroup
{
	property bool	enable:					true
	property bool	enable_betabinomial: 	false
	property bool	show_parameters:		false
	
	title: 						qsTr("Distribution")
	name: 						"prior_distribution"
	enabled:					enable
	info:						qsTr("Choose the functional form of the prior distribution.")

	RadioButton
	{
		id: 					betabinomial
		text: 					qsTr("Beta-binomial")
		name: 					"hypergeometric"
		enabled:				enable_betabinomial
		info:					qsTr("Use the beta-binomial distribution as a prior distribution.")
		childrenOnSameRow:		true

		Row
		{
			spacing:			5 * preferencesModel.uiScale

			DoubleField
			{
				text:			qsTr("\u03B1")
				name:			"betabinomial_alpha"
				visible:		betabinomial.checked && show_parameters
				defaultValue:	1
				min:			0
				decimals:		3
			}

			DoubleField
			{
				text:			qsTr("\u03B2")
				name:			"betabinomial_beta"
				visible:		betabinomial.checked && show_parameters
				defaultValue:	1
				min:			0
				decimals:		3
			}
		}
	}

	RadioButton
	{
		id: 					beta
		text: 					qsTr("Beta")
		name: 					"binomial"
		checked: 				true
		info:					qsTr("Use the beta distribution as a prior distribution.")
		childrenOnSameRow:		true

		Row
		{
			spacing:			5 * preferencesModel.uiScale

			DoubleField
			{
				text:			qsTr("\u03B1")
				name:			"beta_alpha"
				visible:		beta.checked && show_parameters
				defaultValue:	1
				min:			0
				decimals:		3
			}

			DoubleField
			{
				text:			qsTr("\u03B2")
				name:			"beta_beta"
				visible:		beta.checked && show_parameters
				defaultValue:	1
				min:			0
				decimals:		3
			}
		}
	}

	RadioButton
	{
		id: 					gamma
		text: 					qsTr("Gamma")
		name: 					"poisson"
		info:					qsTr("Use the gamma distribution as a prior distribution.")
		childrenOnSameRow:		true

		Row
		{
			spacing:			5 * preferencesModel.uiScale

			DoubleField
			{
				text:			qsTr("\u03B1")
				name:			"gamma_shape"
				visible:		gamma.checked && show_parameters
				defaultValue:	1
				min:			1
				decimals:		3
			}

			DoubleField
			{
				text:			qsTr("\u03B2")
				name:			"gamma_rate"
				visible:		gamma.checked && show_parameters
				defaultValue:	0
				min:			0
				decimals:		3
			}
		}
	}

	RadioButton
	{
		id: 					normal
		text: 					qsTr("Normal")
		name: 					"normal"
		info:					qsTr("Use the normal distribution as a prior distribution.")
		childrenOnSameRow:		true

		Row
		{
			spacing:			5 * preferencesModel.uiScale

			DoubleField
			{
				text:			qsTr("\u03BC")
				name:			"normal_mean"
				visible:		normal.checked && show_parameters
				defaultValue:	0
				min:			0
				max:			1
				decimals:		3
			}

			DoubleField
			{
				text:			qsTr("\u03C3")
				name:			"normal_sd"
				visible:		normal.checked && show_parameters
				defaultValue:	1000
				min:			0.0001
				decimals:		3
			}
		}
	}

	RadioButton
	{
		id: 					uniform
		text: 					qsTr("Uniform")
		name: 					"uniform"
		info:					qsTr("Use the uniform distribution as a prior distribution.")
		childrenOnSameRow:		true
		
		Row
		{
			spacing:			5 * preferencesModel.uiScale

			DoubleField
			{
				text:			qsTr("min")
				name:			"uniform_min"
				visible:		uniform.checked && show_parameters
				defaultValue:	0
				min:			0
				max:			1
				decimals:		3
			}

			DoubleField
			{
				text:			qsTr("max")
				name:			"uniform_max"
				visible:		uniform.checked && show_parameters
				defaultValue:	1
				min:			0
				max:			1
				decimals:		3
			}
		}
	}
}
