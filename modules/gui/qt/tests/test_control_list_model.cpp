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
#include <QTest>

#include "player/control_list_model.hpp"

/* Redux (M0.8, D14): the toolbar never shows a control of a cut feature, whether it comes from a stock profile, a
 * profile saved by an older version (the IDs stay valid, never renumbered) or the toolbar editor. */
class TestControlListModel : public QObject
{
    Q_OBJECT

    using C = ControlListModel;

    static QVector<int> cutControls()
    {
        return { C::RECORD_BUTTON, C::RENDERER_BUTTON, C::TELETEXT_BUTTONS, C::DVD_MENUS_BUTTON,
                 C::NAVIGATION_BUTTONS, C::NAVIGATION_BOX, C::PROGRAM_BUTTON, C::REVERSE_BUTTON };
    }

private slots:
    void testProfileDropsCutControls()
    {
        ControlListModel model;
        QVector<int> saved = { C::PLAY_BUTTON };
        saved += cutControls();
        saved += C::ATOB_BUTTON;

        model.setControls(saved);

        QCOMPARE(model.getControls(), (QVector<int>{ C::PLAY_BUTTON, C::ATOB_BUTTON }));
        QCOMPARE(model.rowCount(), 2);
    }

    void testEditorCannotInsertCutControls()
    {
        ControlListModel model;
        model.setControls({ C::PLAY_BUTTON });

        for (int id : cutControls())
            model.insert(0, { { "id", id } });
        model.insert(1, { { "id", C::ATOB_BUTTON } });

        QCOMPARE(model.getControls(), (QVector<int>{ C::PLAY_BUTTON, C::ATOB_BUTTON }));
    }
};

QTEST_GUILESS_MAIN(TestControlListModel)
#include "test_control_list_model.moc"
