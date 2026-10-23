"""Queue flow (Q0.3): with two videos in the queue, the second starts when the first ends (cases in
redux/qa/cases/e2e.yaml)."""

import re

from appium.webdriver.common.appiumby import AppiumBy

from base import PlayerTest


class QueueAdvances(PlayerTest):
    media = ["Videos/Shows/The Wand/S01/The_Wand_S01E01.mp4",   # 12 s each
             "Videos/Shows/The Wand/S01/The_Wand_S01E02.mp4"]
    extra_args = ["--start-time=6"]   # the last 6 s of each: short, with room for a slow runner

    def test_1_queue_holds_both(self):
        self.wait_for("the first video playing", lambda: self.title() == "The Wand S01E01")
        self.wait_for("the queue to list 2 elements", lambda: any(
            re.match(r"^2 elements", e.text or "") for e in self.driver.find_elements(AppiumBy.XPATH, "//label")))

    def test_2_second_starts_when_first_ends(self):
        self.wait_for("the second video", lambda: self.title() == "The Wand S01E02", timeout=30)
        # Playing, or already paused at its end (D21): either way it started after the first.
        self.assertIn(self.mpris("PlaybackStatus"), ("Playing", "Paused"))
