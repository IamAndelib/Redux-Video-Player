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
#include "palettedump.hpp"
#include "colorcontext.hpp"
#include "systempalette.hpp"

#include <QDir>
#include <QFile>
#include <QMetaEnum>
#include <QTextStream>

void dumpPaletteIfRequested(const SystemPalette &palette, ColorSchemeModel::ColorScheme scheme)
{
    const QString dir = qEnvironmentVariable("REDUX_PALETTE_DUMP");
    if (dir.isEmpty())
        return;

    const QString schemeName = QString(QMetaEnum::fromType<ColorSchemeModel::ColorScheme>().valueToKey(scheme));
    QFile file(QDir(dir).filePath(schemeName.toLower() + ".tsv"));
    if (!file.open(QIODevice::WriteOnly | QIODevice::Truncate | QIODevice::Text))
        return;

    const QMetaEnum sets = QMetaEnum::fromType<ColorContext::ColorSet>();
    const QMetaEnum sections = QMetaEnum::fromType<ColorContext::ColorSection>();
    const QMetaEnum names = QMetaEnum::fromType<ColorContext::ColorName>();
    const QMetaEnum states = QMetaEnum::fromType<ColorContext::ColorState>();

    QTextStream out(&file);
    out << "set\tsection\tname\tstate\tcolor\n";
    for (int i = 0; i < sets.keyCount(); ++i)
    {
        const auto set = static_cast<ColorContext::ColorSet>(sets.value(i));
        if (set == ColorContext::ColorSetUndefined)
            continue;
        for (int j = 0; j < sections.keyCount(); ++j)
            for (int k = 0; k < names.keyCount(); ++k)
                for (int l = 0; l < states.keyCount(); ++l)
                {
                    const QColor color = palette.getColor(set,
                        static_cast<ColorContext::ColorSection>(sections.value(j)),
                        static_cast<ColorContext::ColorName>(names.value(k)),
                        static_cast<ColorContext::ColorState>(states.value(l)));
                    out << sets.key(i) << '\t' << sections.key(j) << '\t' << names.key(k) << '\t'
                        << states.key(l) << '\t' << color.name(QColor::HexArgb) << '\n';
                }
    }
}
