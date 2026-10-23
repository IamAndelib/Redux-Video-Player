"""Run the end-to-end tests (redux/qa/e2e/test_*.py) and write one QA result line per test.

  python -I redux/qa/e2e/run.py <results.tsv> [test ...]

Each line is "l5.<module>.<test>\t<pass|fail|skip>\t<detail>" (redux/QA.md). Called by redux/qa/e2e.sh inside the
KDE session, with the WebDriver server already listening.
"""

import os
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


class ResultFile(unittest.TextTestResult):
    lines = []

    def _record(self, test, status, detail=""):
        module, _, name = test.id().rpartition(".")
        module = module.split(".")[0]
        detail = " ".join(detail.split())[:180]
        self.lines.append(f"l5.{module}.{name}\t{status}\t{detail}")

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
    results_path, names = sys.argv[1], sys.argv[2:]
    loader = unittest.TestLoader()
    suite = loader.loadTestsFromNames(names) if names else loader.discover(HERE, pattern="test_*.py")
    runner = unittest.TextTestRunner(resultclass=ResultFile, verbosity=2, stream=sys.stdout)
    runner.run(suite)
    with open(results_path, "w") as out:
        out.write("\n".join(ResultFile.lines) + ("\n" if ResultFile.lines else ""))


if __name__ == "__main__":
    main()
