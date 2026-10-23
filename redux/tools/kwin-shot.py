#!/usr/bin/env python3
"""Screenshot of the headless KWin session (redux/tools/kwin-session.sh) through KWin's ScreenShot2 interface.

  python3 -I redux/tools/kwin-shot.py <out.png>     (run inside the session)

KWin writes raw pixels into a pipe we pass over D-Bus and replies with their size and layout; ImageMagick turns them
into a PNG. `gdbus` can't pass a file descriptor, hence this small client (pattern from KDE's selenium-webdriver-at-spi
screenshotter, credited in redux/CREDITS.md). The session sets KWIN_SCREENSHOT_NO_PERMISSION_CHECKS, so any caller may
capture.
"""

import os
import subprocess
import sys
import threading

import gi

gi.require_version("Gio", "2.0")
from gi.repository import Gio, GLib  # noqa: E402

# QImage::Format values KWin may report: 4-6 are 32-bit words in host (little-endian) order, i.e. BGRA bytes;
# 16-18 are RGBA bytes.
BYTE_ORDER = {4: "bgra", 5: "bgra", 6: "bgra", 16: "rgba", 17: "rgba", 18: "rgba"}


def capture(out_png):
    read_fd, write_fd = os.pipe()
    chunks = []
    # Read while KWin writes: the image is larger than the pipe buffer.
    reader = threading.Thread(target=lambda: chunks.extend(iter(lambda: os.read(read_fd, 1 << 20), b"")),
                              daemon=True)   # if KWin cancels, the pipe never closes; don't block exit
    reader.start()

    fds = Gio.UnixFDList.new()
    handle = fds.append(write_fd)
    bus = Gio.bus_get_sync(Gio.BusType.SESSION, None)
    try:
        reply, _ = bus.call_with_unix_fd_list_sync(
            "org.kde.KWin", "/org/kde/KWin/ScreenShot2", "org.kde.KWin.ScreenShot2", "CaptureWorkspace",
            GLib.Variant("(a{sv}h)", ({}, handle)), GLib.VariantType("(a{sv})"),
            Gio.DBusCallFlags.NONE, 15000, fds, None)
    except GLib.Error as error:
        if "Cancelled" in error.message:
            sys.exit("kwin-shot: KWin cancelled the screenshot: it needs OpenGL compositing, i.e. a DRM device "
                     "(the GPU, or `sudo modprobe vgem` on a CI runner); see redux/tools/kwin-session.sh")
        raise
    # Close every write end on our side: ours, and the duplicate the FD list keeps. Only then does the read end when
    # KWin closes its copy.
    os.close(write_fd)
    for fd in fds.steal_fds():
        os.close(fd)
    reader.join(timeout=30)
    os.close(read_fd)

    meta = reply.unpack()[0]
    width, height, stride, fmt = (int(meta[k]) for k in ("width", "height", "stride", "format"))
    if fmt not in BYTE_ORDER:
        sys.exit(f"kwin-shot: unsupported pixel format {fmt}")
    data = b"".join(chunks)
    if len(data) < stride * height:
        sys.exit(f"kwin-shot: got {len(data)} bytes, expected {stride * height}")
    rows = b"".join(data[y * stride:y * stride + width * 4] for y in range(height))   # drop row padding
    subprocess.run(["magick", "-size", f"{width}x{height}", "-depth", "8", f"{BYTE_ORDER[fmt]}:-",
                    "-alpha", "off", out_png], input=rows, check=True)
    return width, height


if __name__ == "__main__":
    if len(sys.argv) != 2:
        sys.exit(__doc__)
    w, h = capture(sys.argv[1])
    print(f"{sys.argv[1]} ({w}x{h})")
