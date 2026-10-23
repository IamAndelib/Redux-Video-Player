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
#ifndef QML_BASELINE_HPP
#define QML_BASELINE_HPP

#include <QObject>
#include <QString>

class QQuickItem;

/* Redux (Q0.5, D34): baseline images for the QML component tests (QA layer L4). From QML:
 *   compare(Baseline.check(item, "ButtonExt/night-hover"), "")
 * grabs the item, compares it with redux/qa/components/baselines/<name>.png and returns "" when they match, else
 * what differs; the actual image and a diff are then written to l4/ in the test's working directory (the meson
 * build directory). With REDUX_UPDATE_BASELINES=1 it writes the baseline instead (after an intended change). */
class Baseline : public QObject
{
    Q_OBJECT

public:
    using QObject::QObject;

    Q_INVOKABLE QString check(QQuickItem* item, const QString& name) const;
};

#endif // QML_BASELINE_HPP
