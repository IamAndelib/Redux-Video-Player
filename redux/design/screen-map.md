# Screen map: Figma frame → VLC code

Where each part of the redesign lands in VLC's Qt interface (`modules/gui/qt/`, VLC master at
`redux/UPSTREAM_COMMIT`). Frame IDs refer to Figma file `CAuJVJyM5yY7PnyQQK9X24`; `PLAN.md` §2
lists every frame. **Reuse** means the upstream component already does the job and needs restyling.
**Rework** means the layout or behavior changes. **New** means it doesn't exist yet. Paths are
relative to `modules/gui/qt/`.

## Global style (Track B, M1.x)
| Design element | Code | Kind |
|---|---|---|
| Color tokens, dark and light (`redux/design/tokens.json`) | `style/VLCStyle.qml`, `style/systempalette.cpp`, `style/colorcontext.cpp` | Rework |
| Accent color, 9 presets | `qt-accent-color` option, `style/systempalette.cpp` | Reuse + New picker |
| Blur and shadow effects (`bgBlur`, `bgBlurShadow`) | `widgets/qml/FrostedGlassEffect.qml`, `DualKawaseBlur.qml`, `style/AcrylicController.qml`, `DefaultShadow.qml` | Reuse |
| Icon set, frame 42:356 (monochrome; two-tone future, D14) | `pixmaps/VLCIcons.json`, `pixmaps/makeIconFont.py`, `VLCIcons.ttf` | Rework |
| Buttons, toggle, slider, dropdown, segmented control, search field, menus | `widgets/qml/*Ext.qml`, `IconToolButton.qml`, `SearchBox.qml`, `SliderExt.qml`, `ComboBoxExt.qml` | Rework |
| Window title bar (cone, "…", sidebar toggle, breadcrumb, title, window buttons) | `widgets/qml/CSDWindowButtonSet.qml`, `CSD*.qml`, `maininterface/qml/MenuTopbar.qml` | Rework |

## Player (Track C, M2.x): frames 187:328, 970:3792, 970:2703, 970:4028, 6261:15078, 247:445, 3328:11554
| Design element | Code | Kind |
|---|---|---|
| Player screen layout, top and bottom bars, hover reveal in fullscreen | `player/qml/Player.qml`, `TopBar.qml`, `ControlBar.qml`, `PlayerToolbarVisibilityFSM.qml` | Rework |
| Thick seek bar (seek thumbnails future, M6.1) | `player/qml/SliderBar.qml` | Rework |
| Cone-shaped volume | `player/qml/controlbarcontrols/VolumeWidget.qml` | Rework |
| Subtitle and audio buttons with track lists and output device | `player/qml/TracksMenu.qml`, `TracksPage*.qml`, `controlbarcontrols/LangButton.qml` | Rework |
| Queue toggle (was "playlist") | `controlbarcontrols/PlaylistButton.qml`, `playlist/qml/PlaylistPane.qml` | Rework |
| Hide UI mode | `player/qml/Player.qml`, `menus/menus.cpp` (right-click) | New |
| Resume prompt near the play controls | `player/qml/ResumeDialog.qml` | Rework |
| Default bar layout | `player/control_list_model.hpp`, `dialogs/toolbar/controlbar_profile*.cpp` | Rework |

## Customize Player (Track E, M4.x): frames 2107:5604, 2160:6137 … 2160:8732, 6587:19923
| Design element | Code | Kind |
|---|---|---|
| Drag-and-drop editor shown over the player | `dialogs/toolbar/qml/ToolbarEditor.qml`, `ToolbarEditorDialog.qml`, `EditorDNDView.qml` | Rework |
| About 35 control items (Forward/Back 10s and 15s, HDR, Zoom, PiP, File/Folder/Playlist name (Artist out of scope, D14), Favorite, Bookmarks, Chapters…) | `player/qml/controlbarcontrols/*.qml` (about 45 exist; add the missing ones) | Reuse + New |
| Layout profiles, frame 6648:20666 | `controlbar_profile_model.cpp` | Reuse |

## Library (Tracks D and H, M3.x, M7.x): frames 970:3308, 848:1996 (sidebar), 856:2215, 858:3290, context menus
| Design element | Code | Kind |
|---|---|---|
| Icon rail sidebar: Home, Videos, Playlists, Recent, Add, plus pinned items (Music and Network out of scope, D14) | `maininterface/qml/SideNavigationPane.qml`, `SideNavigationDelegate.qml` | Rework + New pins |
| Compact library panel next to the video | `maininterface/qml/MainDisplay.qml`, `playlist/qml/PlaylistPane.qml` | New |
| Folder browser with clickable address bar, back/forward, sort/view/search | `network/qml/BrowseTreeDisplay.qml`, `NetworkAddressbar.qml`, `widgets/qml/SortControl.qml`, `ViewHeader.qml` | Rework |
| Videos and playlists (music sections out of scope, D14) | `medialibrary/qml/Video*.qml`, `PlaylistMedia*.qml` | Rework |
| Home page and Recent | `medialibrary/qml/HomePage.qml`, `HomeDisplay.qml` | Rework |
| Sorting: Unwatched/Watched first | `medialibrary/` C++ models (`mlvideomodel.*`) | New |
| File, folder and playlist context menus, frames 2404:13340, 2139:8935, 2459:9389 | `medialibrary/qml/MLContextMenu.qml`, `menus/menus.cpp` | Rework |
| Floating miniplayer card, frame 970:3091 | `player/qml/PIPPlayer.qml`, `MiniPlayer.qml` | Rework |
| New playlist dialog, frame 6259:14954 | `dialogs/playlists/` | Rework (to QML) |
| Open file(s) and folder(s) (network stream, frame 6216:13614, out of scope, D14) | `dialogs/open/open.cpp` | Rework |

## Music mode: frames 4767:23726, 4778:25123. Out of scope (D14)
| Design element | Code | Kind |
|---|---|---|
| Blurred artwork backdrop, centered cover, title and artist | `player/qml/Player.qml` (audio branch) | Rework |
| Waveform seek bar | `player/` C++ waveform provider plus `SliderBar.qml` | New |

## Side panels (Track F, M5.x): frames 536:1513, 6114:13610, 536:1703, 612:1223, 536:1855, 543:990, 614:1430, 2372:*
| Design element | Code | Kind |
|---|---|---|
| Right sidebar with Subtitles, Audio, Video and Playback tabs | `player/qml/TracksPage*.qml`, `TracksPageSpeed.qml` | Rework + New tabs |
| EQ, compressor, spatializer, stereo widener | logic in `dialogs/extended/extended_panels.cpp` → shared model + QML | Rework (to QML) |
| Video essential, crop, colors, HDR | `dialogs/extended/extended_panels.cpp` (ExtVideo) | Rework (to QML) |
| Subtitle timeline, subtitle presets, default track | `widgets/qml/TrackDelayButton.qml` + new | New |
| Bookmarks and chapters (queue-panel tabs, D12) | `medialibrary/qml/Bookmarks.qml`, `dialogs/bookmarks/` | Rework |
| Add Subtitles to file/folder/playlist, frames 1911:7545, 3336:11929, 1919:8707, 1919:9278 | — | New |

## Settings (Track I, M8.x): frames 999:5047 … 6575:17137 (Figma has 13 pages plus Advanced; 10 ship, D14), 2437:14832 shortcuts
| Design element | Code | Kind |
|---|---|---|
| Settings dialog with search and basic-then-advanced pages | `dialogs/preferences/` (QtWidgets today) | Rework (to QML) |
| Keyboard shortcuts dialog | `dialogs/preferences/` hotkeys panel | Rework (to QML) |
| Extensions page (out of scope, D14) | `dialogs/extensions/`, `dialogs/plugins/` | None (cut) |

## Onboarding (Track J, M9.1): frames 1899:3055, 1902:3670 … 1902:6465
| Design element | Code | Kind |
|---|---|---|
| 3-step onboarding (welcome and media folder, theme and accent, shortcuts) | `dialogs/firstrun/firstrunwizard.*` (QtWidgets) | Rework (to QML) |

## Feature trim (M0.8): entry points to remove
Features cut by `redux/SCOPE.md` (D14) disappear from the UI at one place each; their modules are switched off by
the M0.6 build profile. Upstream files are not deleted.
| Cut feature | Entry points | Kind |
|---|---|---|
| Discover and Music sections (Browse stays until M3.1, D36) | `maininterface/navigationmodel.cpp` (+ `tests/test_navigation_model.cpp`) | Remove from model |
| Disc, network, capture, clipboard, convert, stream, VLM, EPG, renderer, visualizations, wallpaper, 3D, skins, extensions, update check, go to time, messages | `menus/menus.cpp`, `menus/qml_menu_wrapper.cpp`, `dialogs/dialogs_provider.cpp` | Remove menu entries and shortcuts |
| Record, renderer, teletext, DVD menu, DVD navigation, program, reverse (A-B loop stays) | `player/control_list_model.hpp`, `player/qml/PlayerControlbarControls.qml` | Hide from the toolbar editor list (IDs stay for old profiles) |
| Online subtitle search via VLSub | `player/player_controller.cpp` (`openVLsub`) | Replaced by M5.7 |
| System tray, now-playing popup | `dialogs/systray/systray.cpp`, `qt.cpp` options | Disable by default, hide settings |
| Lyrics view, dual-subtitle selection, metadata editing in Media Information, boss key | `player/qml/Player.qml`, `menus/qml_menu_wrapper.cpp` (`QmlSubtitleMenu`), `dialogs/mediainfo/info_panels.cpp`, `maininterface/mainctx.cpp` | Hide; Media Information stays read-only |
