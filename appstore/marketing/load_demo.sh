#!/bin/sh
# Loads demo_journal.json into the booted simulator's stimmig App Group and restarts the app.
set -e
DIR=$(xcrun simctl get_app_container booted com.pinksharkdesign.stimmig group.com.pinksharkdesign.stimmig)
cp "$(dirname "$0")/demo_journal.json" "$DIR/stimmig_journal.json"
xcrun simctl terminate booted com.pinksharkdesign.stimmig 2>/dev/null || true
xcrun simctl status_bar booted override --time 9:41 --batteryLevel 100 --batteryState charged --cellularBars 4 --wifiBars 3
xcrun simctl launch booted com.pinksharkdesign.stimmig
echo "Demo-Tagebuch geladen: $DIR"
