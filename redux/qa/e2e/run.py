"""Run the end-to-end tests (redux/qa/e2e/test_*.py) and write one QA result line per test.

  python -I redux/qa/e2e/run.py <results.tsv> [test ...]

Each line is "l5.<module>.<Class>.<test>\t<pass|fail|skip>\t<detail>" (redux/QA.md). Called by redux/qa/e2e.sh inside the
KDE session, with the WebDriver server already listening.
"""

import os
import re
import sys
import unittest

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)


def screenshot(test):
    """Save what the screen showed when a test failed (nothing where KWin can't take screenshots, G27)."""
    driver = getattr(test, "driver", None)
    if driver is not None:
        try:
            driver.get_screenshot_as_file(os.path.join(os.path.dirname(sys.argv[1]), f"{test.id()}.png"))
        except Exception:
            pass


def check_id(test):
    """`l5.<module>.<Class>.<test>`; an error in setUpClass or tearDownClass is `l5.<module>.<Class>.setUpClass`."""
    class_error = re.fullmatch(r"(\w+) \((.+)\)", test.id())   # unittest's id for a class-level error
    return "l5." + (f"{class_error[2]}.{class_error[1]}" if class_error else test.id())


class ResultFile(unittest.TextTestResult):
    path = None   # results file; each row is written as it's recorded, so a session killed by its timeout keeps them

    def _record(self, test, status, detail=""):
        detail = " ".join(detail.split())[:180]
        with open(self.path, "a") as out:
            out.write(f"{check_id(test)}\t{status}\t{detail}\n")

    def addSuccess(self, test):
        super().addSuccess(test)
        self._record(test, "pass")

    def addFailure(self, test, err):
        super().addFailure(test, err)
        self._record(test, "fail", str(err[1]))
        screenshot(test)

    def addError(self, test, err):
        super().addError(test, err)
        self._record(test, "fail", f"{err[0].__name__}: {err[1]}")
        screenshot(test)

    def addSkip(self, test, reason):
        super().addSkip(test, reason)
        self._record(test, "skip", reason)


def main():
    ResultFile.path, names = sys.argv[1], sys.argv[2:]
    open(ResultFile.path, "w").close()
    loader = unittest.TestLoader()
    suite = loader.loadTestsFromNames(names) if names else loader.discover(HERE, pattern="test_*.py")
    runner = unittest.TextTestRunner(resultclass=ResultFile, verbosity=2, stream=sys.stdout)
    runner.run(suite)


if __name__ == "__main__":
    main()
