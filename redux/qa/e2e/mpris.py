#!/usr/bin/env python3
"""Read the player's state over MPRIS (VLC's `dbus` control module, `--control=dbus`) and print it as JSON.

  python3 -I redux/qa/e2e/mpris.py <Property>      e.g. PlaybackStatus, Position (µs), Metadata

Runs with the system Python, which has GLib's bindings (the end-to-end venv doesn't); the tests call it as a
subprocess. Exit status 1 when the player isn't on the bus (yet).
"""

import json
import sys

import gi

gi.require_version("Gio", "2.0")
from gi.repository import Gio, GLib  # noqa: E402

BUS_NAME = "org.mpris.MediaPlayer2.vlc"


def get(prop):
    bus = Gio.bus_get_sync(Gio.BusType.SESSION, None)
    reply = bus.call_sync(BUS_NAME, "/org/mpris/MediaPlayer2", "org.freedesktop.DBus.Properties", "Get",
                          GLib.Variant("(ss)", ("org.mpris.MediaPlayer2.Player", prop)),
                          GLib.VariantType("(v)"), Gio.DBusCallFlags.NONE, 5000, None)
    return reply.unpack()[0]


if __name__ == "__main__":
    if len(sys.argv) != 2:
        sys.exit(__doc__)
    try:
        print(json.dumps(get(sys.argv[1]), default=str))
    except GLib.Error as error:
        sys.exit(f"mpris: {error.message}")
