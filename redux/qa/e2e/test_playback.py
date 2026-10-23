"""Playback flows (Q0.3): open a file and play it; at the end the video stays paused on its last frame, and Play starts
it again from the beginning (D21, SCOPE K-entries for playback; cases in redux/qa/cases/e2e.yaml)."""

from base import PlayerTest

SEC = 1_000_000   # MPRIS positions are in µs


class OpenAndPlay(PlayerTest):
    media = ["Videos/Shows/The Wand/S01/The_Wand_S01E04.mp4"]   # 90 s

    def test_plays_and_time_advances(self):
        self.wait_for("PlaybackStatus Playing", lambda: self.mpris("PlaybackStatus") == "Playing")
        start = self.wait_for("a playback position", lambda: self.mpris("Position"))
        self.wait_for("the position to advance 1 s", lambda: (self.mpris("Position") or 0) >= start + SEC)

    def test_shows_title_and_duration(self):
        self.wait_for("the title on MPRIS", lambda: self.title() == "The Wand S01E04")
        self.wait_for("the duration 01:30 on screen", lambda: "01:30" in self.time_labels())


class EndAndRestart(PlayerTest):
    media = ["Videos/Shows/The Wand/S01/The_Wand_S01E06.mp4"]   # 12 s
    # Only the last 6 s, to keep the test short. VLC then treats the 6 s as the whole media: its time and MPRIS
    # Position run from 0 and mpris:length is 6 s.
    extra_args = ["--start-time=6"]

    def test_1_end_stays_paused_on_last_frame(self):
        # D21: the last video ends paused on its last frame, not stopped.
        self.wait_for("PlaybackStatus Paused at the end", lambda: self.mpris("PlaybackStatus") == "Paused", timeout=30)
        position, length = self.mpris("Position"), self.length()
        self.assertGreaterEqual(position, length - SEC // 2,
                                f"paused at {position / SEC:.1f} s of {length / SEC:.1f} s, not at the end")
        # What the user sees: the elapsed time at the duration, within a second (the last frame starts just before
        # the end, and the label rounds down).
        self.reveal_controls()
        self.wait_for("the time labels to show the end",
                      lambda: (s := self.time_label_seconds()) and len(s) >= 2 and min(s) >= max(s) - 1, timeout=5)

    def test_2_play_again_restarts_from_the_beginning(self):
        # D21: Play on a finished video starts it from the beginning, pressed the way a user does.
        self.reveal_controls()
        self.press("Play/Pause")
        self.wait_for("PlaybackStatus Playing", lambda: self.mpris("PlaybackStatus") == "Playing")
        # Within the first half, not continuing from the end (tolerates a slow runner between the two reads).
        position, length = self.mpris("Position"), self.length()
        self.assertLess(position, length // 2, f"restarted at {position / SEC:.1f} s, not from the beginning")
