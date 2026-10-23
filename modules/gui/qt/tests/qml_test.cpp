/*****************************************************************************
 * Copyright (C) 2023 VLC authors and VideoLAN
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston MA 02110-1301, USA.
*****************************************************************************/

#include <QtQuickTest>
#include "qml_test.hpp"
#include "qml_baseline.hpp"

#include "maininterface/mainctx.hpp"   // tests/stub/: a stand-in MainCtx (Redux, Q0.5, D34)
#include "style/colorcontext.hpp"
#include "style/systempalette.hpp"
#include "style/vlcicons.hpp"
#include "util/color_scheme_model.hpp"
#include "widgets/native/navigation_attached.hpp"

// The style sources log through msg_Err, which names the module.
extern "C" const char vlc_module_name[] = "qml_test";

// https://doc.qt.io/qt-6/qtquicktest-index.html#executing-c-before-qml-tests

void Setup::qmlEngineAvailable(QQmlEngine *engine)
{
#if QT_VERSION < QT_VERSION_CHECK(6, 5, 0)
    engine->addImportPath(":/qt/qml");
#endif
    // Redux (Q0.5, D34): what the widgets need to be tested alone, registered as MainUI::registerQMLTypes does.
    static MainCtx mainCtx;
    qmlRegisterSingletonInstance<MainCtx>("VLC.MainInterface", 1, 0, "MainCtx", &mainCtx);
    qmlRegisterUncreatableType<NavigationAttached>("VLC.MainInterface", 1, 0, "Navigation",
                                                   "Navigation is only available via attached properties");
    qmlRegisterUncreatableType<ColorSchemeModel>("VLC.Style", 1, 0, "ColorSchemeModel", "");
    qmlRegisterType<ColorContext>("VLC.Style", 1, 0, "ColorContext");
    qmlRegisterUncreatableType<ColorProperty>("VLC.Style", 1, 0, "colorProperty", "");
    qmlRegisterType<SystemPalette>("VLC.Style", 1, 0, "SystemPalette");
    qmlRegisterTypesAndRevisions<VLCIcons>("VLC.Style", 1);
    qmlRegisterSingletonInstance<Baseline>("Redux.Test", 1, 0, "Baseline", new Baseline(engine));
}

int main(int argc, char **argv)
{
    QTEST_SET_MAIN_SOURCE_PATH

    Q_INIT_RESOURCE( util_assets );
    Q_INIT_RESOURCE( style_assets );
    Q_INIT_RESOURCE( widgets_assets );
    Q_INIT_RESOURCE( maininterface_assets );
#ifdef QT_USE_QMLCACHEGEN
    Q_INIT_RESOURCE( util_cachegen );
    Q_INIT_RESOURCE( style_cachegen );
    Q_INIT_RESOURCE( widgets_cachegen );
    Q_INIT_RESOURCE( maininterface_cachegen );
#endif

    //run tests offscreen as the CI doesn't have a desktop environment
    qputenv("QT_QPA_PLATFORM", "offscreen");
    // Redux (Q0.5): the same pixels everywhere, and hover as on a desktop (offscreen leaves it off)
    qputenv("QT_QUICK_BACKEND", "software");
    qputenv("QT_QUICK_CONTROLS_HOVER_ENABLED", "1");
    Setup setup;
    return quick_test_main_with_setup(argc, argv, "qml_test", QUICK_TEST_SOURCE_DIR, &setup);
}
