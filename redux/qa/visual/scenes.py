"""Screenshot scenes (QA layer L6, Q0.4): each class drives the real app in the headless KDE session the way a user does,
through AT-SPI (the Q0.3 driver, redux/qa/e2e/base.py), and saves the screen as build/shots/<scene>.png with KWin's
screenshot interface. Run by redux/tools/shoot.sh; the scenes match the Figma frames named in redux/qa/visual/regions/<scene>.json.

The app uses its own title bar (`--no-qt-titlebar`, as the design does) and is maximised with that title bar's
button, so a shot is the whole 1920×1080 window like a Figma frame. THEME (night, day, system) picks the colour scheme.
"""

import os
import subprocess
import sys
import time
import unittest

from appium.webdriver.common.appiumby import AppiumBy
from selenium.webdriver.common.action_chains import ActionChains

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, "..", "e2e"))
from base import MEDIA, ROOT, PlayerTest  # noqa: E402

SHOTS = os.path.join(ROOT, "build", "shots")
SCHEMES = {"system": 0, "day": 1, "night": 2}   # vlc-qt-interface.conf color-scheme-index
EPISODE = "Videos/Shows/The Wand/S01/The_Wand_S01E04.mp4"   # 90 s


class Scene(PlayerTest):
    out = os.path.join(SHOTS, "session")
    profile = "shots"   # shared: the library scenes need the media library the first-run scene indexed
    keep_profile = True
    # The design's own title bar; no video-title overlay (it fades out at an unpredictable moment).
    extra_args = ["--no-qt-titlebar", "--no-video-title-show"]

    @classmethod
    def prepare_profile(cls, profile):
        config = os.path.join(profile, "config")
        os.makedirs(os.path.join(config, "vlc"), exist_ok=True)
        # The XDG Videos folder is the test media, as the first-run wizard and Browse show it.
        with open(os.path.join(config, "user-dirs.dirs"), "w") as f:
            f.write(f'XDG_VIDEOS_DIR="{MEDIA}/Videos"\n')
        cls.set_scheme(os.path.join(config, "vlc", "vlc-qt-interface.conf"))

    @staticmethod
    def set_scheme(conf):
        index = SCHEMES[os.environ.get("THEME", "night")]
        lines = open(conf).read().splitlines() if os.path.exists(conf) else []
        lines = [line for line in lines if not line.startswith("color-scheme-index=")]
        if "[MainWindow]" not in lines:
            lines.append("[MainWindow]")
        lines.insert(lines.index("[MainWindow]") + 1, f"color-scheme-index={index}")
        with open(conf, "w") as f:
            f.write("\n".join(lines) + "\n")

    def maximize(self):
        self.press("Maximize")
        self.wait_for("the window to be maximised", lambda: self.driver.find_elements(AppiumBy.NAME, "Restore"))

    def open_item(self, name):
        """Open a folder or file in a view the way a mouse user does: double-click it."""
        item = self.wait_for(f"“{name}” in the view", lambda: [
            e for e in self.driver.find_elements(AppiumBy.NAME, name) if e.get_attribute("showing") == "true"])[0]
        ActionChains(self.driver).double_click(item).perform()

    def shoot(self, scene, settle=1.5):
        time.sleep(settle)   # let fades and the hover animation finish (QML animations have no "done" signal on AT-SPI)
        path = os.path.join(SHOTS, f"{scene}.png")
        result = subprocess.run(["python3", "-I", os.path.join(ROOT, "redux", "tools", "kwin-shot.py"), path],
                                capture_output=True, text=True)
        self.assertEqual(result.returncode, 0, f"KWin couldn't take the screenshot: {result.stderr.strip()}")
        print(f"captured {path}", flush=True)


class FirstRun(Scene):
    """The first-run wizard; walking through it indexes the test media for the library scenes."""
    keep_profile = False
    extra_args = Scene.extra_args + ["--qt-privacy-ask"]

    def test_scene(self):
        self.wait_for("the first-run wizard", lambda: self.driver.find_elements(AppiumBy.NAME, "Next >"))
        self.shoot("first-run")
        while self.driver.find_elements(AppiumBy.NAME, "Next >"):
            self.press("Next >")
            time.sleep(0.5)
        self.press("Finish")
        # The media library shows "Scanning …" or "Indexing Medias (n%)" while it works: wait for it to start, then
        # to end (a short scan may already be over by the first look).
        scanning = lambda: [e for e in self.driver.find_elements(AppiumBy.XPATH, "//label")
                            if (e.text or "").startswith(("Scanning", "Indexing"))]
        try:
            self.wait_for("the media library to start scanning", scanning, timeout=10)
        except AssertionError:
            pass
        self.wait_for("the media library to finish scanning", lambda: not scanning(), timeout=60)


class Library(Scene):
    """Figma 970:3308: a season folder in list view, with the miniplayer (paused, so its time is the same every run)."""
    media = [EPISODE]
    extra_args = Scene.extra_args + ["--start-time=40", "--start-paused"]

    def test_scene(self):
        self.maximize()
        self.wait_for("the video to be paused", lambda: self.mpris("PlaybackStatus") == "Paused")
        self.reveal_controls()
        self.press("Back")
        self.press("Browse")
        for folder in ("Videos", "Shows", "The Wand", "S01"):
            self.open_item(folder)
        self.press("List/Grid")
        self.shoot("library")


class Player(Scene):
    """Figma 187:328: a video paused with the player controls showing."""
    media = [EPISODE]
    extra_args = Scene.extra_args + ["--start-time=40", "--start-paused"]

    def test_scene(self):
        self.maximize()
        self.wait_for("the video to be paused", lambda: self.mpris("PlaybackStatus") == "Paused")
        self.reveal_controls()
        self.shoot("player")


class Window(Scene):
    """The window as it opens, not maximised: VLC's own title bar and its shadow (no Figma frame). The window keeps
    its opening size: resizing it to the video lands at an unpredictable moment."""
    media = [EPISODE]
    extra_args = Scene.extra_args + ["--start-time=40", "--start-paused", "--no-qt-video-autoresize"]

    def test_scene(self):
        self.wait_for("the video to be paused", lambda: self.mpris("PlaybackStatus") == "Paused")
        self.reveal_controls()   # the title bar hides with the player controls
        self.shoot("window")


SCENES = {"first-run": FirstRun, "library": Library, "player": Player, "window": Window}


if __name__ == "__main__":
    # scenes.py <scene>: run one scene (redux/tools/shoot.sh starts a KDE session per scene)
    suite = unittest.defaultTestLoader.loadTestsFromTestCase(SCENES[sys.argv[1]])
    sys.exit(0 if unittest.TextTestRunner(verbosity=2, stream=sys.stdout).run(suite).wasSuccessful() else 1)
