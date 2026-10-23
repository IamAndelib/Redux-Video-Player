/*****************************************************************************
 * Copyright (C) 2026 Redux Video Player authors
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * ( at your option ) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston MA 02110-1301, USA.
 *****************************************************************************/
#ifndef PALETTEDUMP_HPP
#define PALETTEDUMP_HPP

#include "util/color_scheme_model.hpp"

class SystemPalette;

/* Redux (Q0.4, D33): when the environment variable REDUX_PALETTE_DUMP names a directory, write every colour of the
 * palette (each set, section, name and state, with the fallbacks getColor() applies) to <dir>/<scheme>.tsv, for the
 * WCAG contrast report (redux/qa/contrast.py). Does nothing otherwise. */
void dumpPaletteIfRequested(const SystemPalette &palette, ColorSchemeModel::ColorScheme scheme);

#endif // PALETTEDUMP_HPP
