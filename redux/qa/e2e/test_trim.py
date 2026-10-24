"""Feature trim flows (M0.8, D14): what a user can reach shows no cut feature (cases in redux/qa/cases/trim.yaml).

The menus' entries and the QWidget dialogs aren't visible over AT-SPI (G29): `l1.cut-entries` checks the menus, and a
shortcut's effect is judged by the screen, as a user sees it: KWin screenshots before and after the key.
"""

import os
import subprocess
import time

from appium.webdriver.common.appiumby import AppiumBy
from selenium.webdriver.common.action_chains import ActionChains
from selenium.webdriver.common.keys import Keys

from base import OUT, ROOT, PlayerTest

CUT_SECTIONS = ("Music", "Discover")
# Ctrl + key opened: disc, network, capture, convert, stream, the log viewer, jump to time (D37 keeps Ctrl+V).
CUT_SHORTCUTS = ("d", "n", "c", "r", "s", "m", "t")


def showing(driver, xpath):
    return [e.get_attribute("name") for e in driver.find_elements(AppiumBy.XPATH, xpath)
            if e.get_attribute("showing") == "true"]


class SidebarTrimmed(PlayerTest):
    def test_sections(self):
        sections = self.wait_for("the sidebar", lambda: showing(self.driver, "//list_item[@name='Home']") and
                                 showing(self.driver, "//list_item"))
        for cut in CUT_SECTIONS:
            self.assertNotIn(cut, sections)
        for kept in ("Home", "Video", "Browse"):   # Browse until M3.1 (D36)
            self.assertIn(kept, sections)


class HomeWithoutLibraryTrimmed(PlayerTest):
    extra_args = ["--no-media-library"]

    def test_buttons(self):
        buttons = self.wait_for("the Home buttons", lambda: "Open File" in showing(self.driver, "//button") and
                                showing(self.driver, "//button"))
        self.assertNotIn("Open Disc", buttons)


class ShortcutsTrimmed(PlayerTest):
    """The no-library Home is a still screen: a shortcut that opens any window changes it."""
    extra_args = ["--no-media-library"]

    def shot(self, name):
        path = os.path.join(OUT, f"trim-{name}.png")
        result = subprocess.run(["python3", "-I", os.path.join(ROOT, "redux", "tools", "kwin-shot.py"), path],
                                capture_output=True, text=True)
        if result.returncode == 3:
            self.skipTest("KWin can't take screenshots without a DRM render node (G27)")
        self.assertEqual(result.returncode, 0, result.stderr)
        return path

    def changed(self, before, after):
        result = subprocess.run(["magick", "compare", "-metric", "AE", before, after, "null:"],
                                capture_output=True, text=True)
        return float(result.stderr.split()[0]) > 0   # differing pixels

    def ctrl(self, key):
        ActionChains(self.driver).key_down(Keys.CONTROL).send_keys(key).key_up(Keys.CONTROL).perform()
        time.sleep(1.5)   # a dialog appears well within this

    def test_1_media_information_still_opens(self):
        # The positive control: a kept shortcut's window does change the screen, so the check below can see one.
        self.wait_for("the main window", lambda: "Open File" in showing(self.driver, "//button"))
        time.sleep(1)
        before = self.shot("home")
        self.ctrl("i")
        self.assertTrue(self.changed(before, self.shot("ctrl-i")), "Ctrl+I didn't open Media Information")
        ActionChains(self.driver).send_keys(Keys.ESCAPE).perform()
        time.sleep(1)
        self.assertFalse(self.changed(before, self.shot("closed")), "Media Information didn't close")

    def test_2_cut_shortcuts_open_nothing(self):
        before = self.shot("home-2")
        for key in CUT_SHORTCUTS:
            self.ctrl(key)
            after = self.shot(f"ctrl-{key}")
            if self.changed(before, after):
                ActionChains(self.driver).send_keys(Keys.ESCAPE).perform()
                self.fail(f"Ctrl+{key.upper()} changed the screen (a window opened); see {after}")
        # Keys still reach the app: a kept shortcut still changes the screen, so the passes above mean something.
        self.ctrl("i")
        self.assertTrue(self.changed(before, self.shot("ctrl-i-after")), "keys no longer reach the app")
        ActionChains(self.driver).send_keys(Keys.ESCAPE).perform()
