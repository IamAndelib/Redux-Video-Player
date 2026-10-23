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
- **M0.7-6 · Open:** the Flatpak · **Do:** quit with Ctrl+Q · **Expect:** it closes cleanly, no crash dialog (G24).
