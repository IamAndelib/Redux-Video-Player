"""Shared base for the end-to-end tests (QA layer L5, Q0.3): each test class starts the real player through the WebDriver
server (KDE's selenium-webdriver-at-spi) with its own throw-away profile, and checks behaviour two ways:

- what the player does, over MPRIS (`mpris()`, exact and independent of the UI);
- what the user sees and can reach, over AT-SPI (`element()`, `press()`), by accessible name, so a test survives the
  redesign moving a control.

Waits poll a condition with a time limit (`wait_for()`) instead of sleeping a fixed time, so a slow CI runner makes a
test slower, not flaky. Pattern after KDE's plasma-pa tests (credited in redux/CREDITS.md).
"""

import json
import os
import re
import shlex
import shutil
import subprocess
import time
import unittest

from appium import webdriver
from appium.options.common.base import AppiumOptions
from appium.webdriver.common.appiumby import AppiumBy
from selenium.webdriver.common.action_chains import ActionChains
from selenium.webdriver.common.keys import Keys

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "..", ".."))
VLC = os.path.join(ROOT, os.environ.get("BUILD_DIR", "build/meson"), "bin", "vlc-static")
MEDIA = os.path.join(ROOT, "build", "media")
OUT = os.path.join(os.environ.get("QA_OUT", os.path.join(ROOT, "build", "qa")), "l5")
MPRIS = os.path.join(os.path.dirname(os.path.abspath(__file__)), "mpris.py")
TIME_LABEL = re.compile(r"^\d{2}:\d{2}(:\d{2})?$")


class PlayerTest(unittest.TestCase):
    media = []        # paths under build/media, opened in this order (the queue)
    extra_args = []   # more player options for this class

    @classmethod
    def setUpClass(cls):
        profile = os.path.join(OUT, "profile-" + cls.__name__)
        shutil.rmtree(profile, ignore_errors=True)
        os.makedirs(profile)
        # Software only, as in l1.kwin-session (D30): shared-memory video output, software decoding.
        args = [VLC, "--control=dbus", "--no-qt-privacy-ask", "--aout=dummy", "--vout=wl", "--no-hw-dec",
                "--file-logging", f"--logfile={os.path.join(OUT, 'vlc-' + cls.__name__ + '.log')}",
                *cls.extra_args, *(os.path.join(MEDIA, m) for m in cls.media)]
        options = AppiumOptions()
        options.set_capability("app", shlex.join(args))
        options.set_capability("appium:environ", {
            "HOME": profile, "XDG_CONFIG_HOME": os.path.join(profile, "config"),
            "XDG_DATA_HOME": os.path.join(profile, "data"), "XDG_CACHE_HOME": os.path.join(profile, "cache")})
        options.set_capability("timeouts", {"implicit": 10000})
        cls.driver = webdriver.Remote(command_executor="http://127.0.0.1:4723", options=options)

    @classmethod
    def tearDownClass(cls):
        cls.driver.quit()   # the driver kills the player
        # Wait until it has left the session bus: D-Bus frees the MPRIS name asynchronously, and a player that starts
        # while it is still taken registers as org.mpris.MediaPlayer2.vlc.instance<pid>, which mpris() doesn't read.
        deadline = time.monotonic() + 10
        while time.monotonic() < deadline and cls.mpris("PlaybackStatus") is not None:
            time.sleep(0.2)

    # --- what the player does (MPRIS) --------------------------------------------------------------------------
    @staticmethod
    def mpris(prop):
        """The player's MPRIS property (PlaybackStatus, Position in µs, Metadata), or None if it isn't on the bus."""
        result = subprocess.run(["python3", "-I", MPRIS, prop], capture_output=True, text=True, timeout=10)
        return json.loads(result.stdout) if result.returncode == 0 else None

    def title(self):
        return (self.mpris("Metadata") or {}).get("xesam:title")

    def length(self):
        """The media's length in µs as the player sees it (with --start-time, the remaining segment)."""
        return (self.mpris("Metadata") or {}).get("mpris:length")

    # --- what the user sees (AT-SPI) ---------------------------------------------------------------------------
    def element(self, name):
        return self.driver.find_element(AppiumBy.NAME, name)

    def press(self, name):
        self.element(name).click()

    def reveal_controls(self):
        """Bring back the auto-hidden player controls the way a keyboard user does: any key press counts as activity
        (the driver, like a user, can't reach hidden controls). Shift alone types nothing, moves no focus and triggers
        no shortcut. Pointer moves only revealed them the first time in this session (KWin fake input under the
        virtual output), so the tests use the keyboard. Input goes through KWin's fake-input protocol (KWIN_PID)."""
        ActionChains(self.driver).send_keys(Keys.SHIFT).perform()

    def time_labels(self):
        """The texts of the time labels on screen (the player's elapsed time and duration, the queue's total)."""
        return [e.text for e in self.driver.find_elements(AppiumBy.XPATH, "//label")
                if TIME_LABEL.match(e.text or "")]

    def time_label_seconds(self):
        """The time labels in seconds."""
        return [sum(int(part) * 60 ** i for i, part in enumerate(reversed(text.split(":"))))
                for text in self.time_labels()]

    # --- waiting -----------------------------------------------------------------------------------------------
    def wait_for(self, what, condition, timeout=20, interval=0.25):
        """Poll `condition()` until it returns a truthy value (returned), or fail after `timeout` seconds."""
        deadline = time.monotonic() + timeout
        last = None
        while time.monotonic() < deadline:
            last = condition()
            if last:
                return last
            time.sleep(interval)
        self.fail(f"timed out after {timeout} s waiting for {what} (last: {last!r})")
