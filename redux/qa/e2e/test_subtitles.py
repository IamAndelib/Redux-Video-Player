"""Subtitles flow (Q0.3): a file's subtitles are on, and the user turns them off and on again in the tracks menu
(cases in redux/qa/cases/e2e.yaml)."""

from appium.webdriver.common.appiumby import AppiumBy
from selenium.webdriver.common.action_chains import ActionChains

from base import PlayerTest

# The subtitle track's entry, by its panel: audio and video tracks are also called "Track 1".
SUBTITLE_TRACK = "//panel[@name='Subtitle']//list_item"


class SubtitlesOnOff(PlayerTest):
    media = ["Videos/Clips/subtitles-ass-demo.mkv"]   # 60 s, one English ASS subtitle track

    def subtitle_track(self):
        """The subtitle track's entry in the tracks menu, opening the menu first if it isn't on screen."""
        entries = self.driver.find_elements(AppiumBy.XPATH, SUBTITLE_TRACK)
        if not entries or entries[0].get_attribute("showing") != "true":
            self.reveal_controls()
            self.press("Languages and tracks")
            entries = self.wait_for("the tracks menu", lambda: [
                e for e in self.driver.find_elements(AppiumBy.XPATH, SUBTITLE_TRACK)
                if e.get_attribute("showing") == "true"])
        return entries[0]

    def subtitles_on(self):
        return self.subtitle_track().get_attribute("checked") == "true"

    def test_1_subtitles_are_on(self):
        self.wait_for("PlaybackStatus Playing", lambda: self.mpris("PlaybackStatus") == "Playing")
        self.assertTrue(self.subtitles_on(), "the file's subtitle track isn't selected")

    def toggle(self):
        # A real click: the entry's accessibility action selects it but doesn't toggle it, unlike a click.
        ActionChains(self.driver).click(self.subtitle_track()).perform()

    def test_2_turn_them_off(self):
        self.toggle()
        self.wait_for("the subtitle track to be off", lambda: not self.subtitles_on())

    def test_3_turn_them_on_again(self):
        self.assertFalse(self.subtitles_on(), "precondition: test_2 turned them off")
        self.toggle()
        self.wait_for("the subtitle track to be on", self.subtitles_on)
