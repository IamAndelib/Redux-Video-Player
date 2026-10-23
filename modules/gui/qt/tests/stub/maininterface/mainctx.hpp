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
#ifndef QVLC_MAIN_INTERFACE_H_
#define QVLC_MAIN_INTERFACE_H_

/* Redux (Q0.5, D34): a stand-in for maininterface/mainctx.hpp in the QML component tests (qml_test). It is first on
 * qml_test's include path, so the style sources compiled into the test (SystemPalette, ColorContext…) see this
 * MainCtx: only what VLCStyle and the widgets under test read, with the defaults of a fresh interface. The real one
 * needs a running interface (playlist, settings, models). Add members here as more widgets get tests (M1.5). */

#include <QObject>
#include <QWindow>

#include <cmath>

#include "util/color_scheme_model.hpp"

struct qt_intf_t;

class MainCtx : public QObject
{
    Q_OBJECT

    Q_PROPERTY(double intfScaleFactor READ getIntfScaleFactor CONSTANT FINAL)
    Q_PROPERTY(ColorSchemeModel* colorScheme READ getColorScheme CONSTANT FINAL)
    Q_PROPERTY(bool hasAcrylicSurface READ hasAcrylicSurface CONSTANT FINAL)
    Q_PROPERTY(QWindow* intfMainWindow READ intfMainWindow CONSTANT FINAL)
    Q_PROPERTY(float safeArea READ safeArea CONSTANT FINAL)

public:
    explicit MainCtx(QObject* parent = nullptr);

    qt_intf_t* getIntf() const { return nullptr; }   // no interface: SystemPalette keeps the default accent
    double getIntfScaleFactor() const { return 1.0; }
    Q_INVOKABLE double getIntfUserScaleFactor() const { return 1.0; }
    ColorSchemeModel* getColorScheme() const { return m_colorScheme; }
    bool hasAcrylicSurface() const { return false; }
    QWindow* intfMainWindow() const { return nullptr; }
    float safeArea() const { return 0; }

    Q_INVOKABLE static double dp(double px, double scale) { return std::round(px * scale); }

    // Test only: pick the colour scheme (ColorSchemeModel row: 1 Day, 2 Night). There's no System scheme here: it
    // reads the desktop's theme through the interface's theme provider modules.
    Q_INVOKABLE void setColorScheme(int index)
    {
        if (index != 1 && index != 2)
            qFatal("MainCtx stub: colour scheme %d isn't Day (1) or Night (2)", index);
        m_colorScheme->setCurrentIndex(index);
    }

private:
    ColorSchemeModel* m_colorScheme;
};

#endif // QVLC_MAIN_INTERFACE_H_
