/*****************************************************************************
 * Copyright (C) 2020 VLC authors and VideoLAN
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

import VLC.MainInterface
import VLC.Dialogs

Item {
    // Redux (M0.8, D14, D37): no shortcuts for cut features (disc, network, capture, convert, stream, log viewer,
    // jump to time, VLM). Paste stays: it plays files copied in a file manager.

    ShortcutExt{ context: Qt.WindowShortcut; sequence:"Ctrl+O"; onActivated: DialogsProvider.simpleOpenDialog(); }
    ShortcutExt{ sequence:"Ctrl+Shift+O"; onActivated: DialogsProvider.openFileDialog(); }
    ShortcutExt{ context: Qt.WindowShortcut; sequence:"Ctrl+F"; onActivated: DialogsProvider.PLOpenDir(); }
    ShortcutExt{ sequences: [StandardKey.Paste]; onActivated: MainCtx.pasteFromClipboard(); }
    ShortcutExt{ context: Qt.WindowShortcut; sequence:"Ctrl+Y"; onActivated: DialogsProvider.savePlayingToPlaylist(); }
    ShortcutExt{ sequence:"Ctrl+Q"; onActivated: DialogsProvider.quit(); }
    ShortcutExt{ sequence:"Ctrl+E"; onActivated: DialogsProvider.extendedDialog(); }
    ShortcutExt{ sequence:"Ctrl+I"; onActivated: DialogsProvider.mediaInfoDialog(); }
    ShortcutExt{ sequence:"Ctrl+J"; onActivated: DialogsProvider.mediaCodecDialog(); }
    ShortcutExt{ sequence:"Ctrl+P"; onActivated: DialogsProvider.prefsDialog(); }

    ShortcutExt{ sequence:"Ctrl+L"; onActivated: MainCtx.playqueuePanel.visible = !MainCtx.playqueuePanel.visible; }

    ShortcutExt{ sequence:"F1"; onActivated: DialogsProvider.helpDialog() }
    ShortcutExt{ sequence:"F10"; onActivated: MainCtx.toggleToolbarMenu() }
    ShortcutExt{ sequence:"F11"; onActivated: MainCtx.toggleInterfaceFullScreen() }
    ShortcutExt{ sequence:"Ctrl+H"; onActivated: MainCtx.minimalView = !MainCtx.minimalView; }

    ShortcutExt{ sequences: [StandardKey.ZoomIn, "Ctrl+="]; onActivated: MainCtx.incrementIntfUserScaleFactor(true) }
    ShortcutExt{ sequences: [StandardKey.ZoomOut, "Ctrl+Shift+-"]; onActivated: MainCtx.incrementIntfUserScaleFactor(false) }

    Loader {
        active: MainCtx.mediaLibraryAvailable
        source: "qrc:///qt/qml/VLC/MediaLibrary/MLGlobalShortcuts.qml"
    }
}
