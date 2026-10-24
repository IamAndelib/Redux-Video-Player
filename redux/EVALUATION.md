# Final evaluation script

The maintainer's full quality check of the finished project (D26). Each milestone adds the checks that only a person
at a real desktop can judge (sound, GPU, feel, looks); everything else is covered by the QA suite (`redux/QA.md`).
Work through it top to bottom when the project is complete, in both the Flatpak ("Redux Video Player") and, where it
says so, the dev build ("Redux Video Player (dev)"). Use your own videos of at least 30 s unless an item names a file.

**Report:** the item ID and what you saw (a screenshot helps), as an issue with the "Bug or feedback" template.

## M0.7: Flatpak
- **M0.7-1 · Open:** app menu → "Redux Video Player" · **Do:** start it · **Expect:** the Home page opens, no error.
- **M0.7-2 · Open:** the Flatpak · **Do:** open your own video from your home folder and from another drive · **Expect:**
  it plays with sound; the file dialog can browse everywhere.
- **M0.7-3 · Open:** the Flatpak · **Do:** play a 4K or HEVC/10-bit video · **Expect:** smooth playback.
- **M0.7-4 · Open:** the Flatpak · **Do:** open `build/media/Videos/Clips/subtitles-ass-demo.mkv` (60 s) · **Expect:**
  styled subtitles; at the end the last frame stays; Play restarts from 0:00.
- **M0.7-5 · Open:** the Flatpak while a video plays · **Do:** media keys or the KDE media applet · **Expect:**
  play/pause works; the applet shows the title.
- **M0.7-6 · Open:** the Flatpak · **Do:** quit with Ctrl+Q · **Expect:** it closes cleanly, no crash dialog (G24, fixed in M0.7: it crashed on every quit before).

## M0.8: Feature trim
- **M0.8-1 · Open:** the Flatpak, the "⋮" menu at the top right · **Do:** go through Media, Playback, Audio, Video,
  Subtitle, Tools, View and Help, then right-click on a video and look at that menu too · **Expect:** nothing for discs,
  network streams, capture devices, converting, streaming, recording, renderers (casting), the program guide, the log
  viewer ("Messages"), plugins and extensions, visualizations, 3D, wallpaper or the system tray; Media Information is
  still there (Tools). No menu has an empty gap or a doubled separator where an entry was.
- **M0.8-2 · Open:** the Flatpak's sidebar · **Do:** look at the sections · **Expect:** Home, Video, Browse; no Music
  or Discover. Browse stays until M3.1 brings folders into Videos (D36).
- **M0.8-3 · Open:** a video playing in the Flatpak · **Do:** press Ctrl+D, Ctrl+N, Ctrl+C, Ctrl+R, Ctrl+S, Ctrl+M,
  Ctrl+T, then Shift+R and W · **Expect:** nothing opens or changes; Ctrl+I still opens Media Information, where the
  fields can't be edited, there's no Save or Fingerprint, and nothing leaves an empty gap.
- **M0.8-4 · Open:** Tools › Customize Interface · **Do:** look through the controls you can add · **Expect:** no
  Record, Renderer, Teletext, DVD menus, Navigation, Program or Trickplay Reverse; A-B Loop is there.
- **M0.8-5 · Open:** Dolphin and the Flatpak · **Do:** copy a video file in Dolphin, then press Ctrl+V in the player;
  then copy a web address (or any text) and press Ctrl+V; then drag a video file, and then a web link from a browser,
  onto the window · **Expect:** the copied and the dragged file play; the web address, the text and the dropped link do
  nothing (no dialog, no error).
