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
import QtQuick
import QtTest

import VLC.MainInterface
import VLC.Style
import VLC.Widgets as Widgets
import Redux.Test

// Redux (Q0.5, D34): ButtonExt in every state and both themes, against baseline grabs (QA layer L4). The root item
// gives the widget a theme to inherit, as MainInterface.qml does for the app.
Item {
    width: 200
    height: 80

    readonly property ColorContext colorContext: ColorContext {
        palette: VLCStyle.palette
        colorSet: ColorContext.Window
    }

    Rectangle {
        anchors.fill: parent
        color: parent.colorContext.bg.primary
    }

    Widgets.ButtonExt {
        id: button
        anchors.centerIn: parent
        text: "Play"
    }

    TestCase {
        name: "ButtonExt"
        when: windowShown

        function test_states_data() {
            const rows = []
            for (const scheme of [{ name: "day", index: 1 }, { name: "night", index: 2 }])
                for (const state of ["normal", "hover", "pressed", "focus", "disabled"])
                    rows.push({ tag: scheme.name + "-" + state, scheme: scheme.index, state: state })
            return rows
        }

        function init() {
            mouseMove(button.parent, 1, 1)   // away from the button: no hover left over
            button.enabled = true
            button.focus = false
            button.parent.forceActiveFocus()
        }

        function cleanup() {
            if (button.down)   // a failed pressed row returns before its release
                mouseRelease(button)
        }

        function test_states(data) {
            MainCtx.setColorScheme(data.scheme)
            // Reach the state the way a user does, and check it was reached: a state whose colours equal Normal's
            // (stock Pressed) would otherwise pass without being exercised.
            if (data.state === "hover") {
                mouseMove(button)
                verify(button.hovered)
            } else if (data.state === "pressed") {
                mousePress(button)
                verify(button.down)
            } else if (data.state === "focus") {
                button.forceActiveFocus(Qt.TabFocusReason)
                verify(button.visualFocus)
            } else if (data.state === "disabled") {
                button.enabled = false
            }
            wait(VLCStyle.duration_long * 2)   // colour transitions run for duration_long
            compare(Baseline.check(button, "ButtonExt/" + data.tag), "")
        }
    }
}
