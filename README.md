# Analog No Seconds

A minimal Garmin Connect IQ analog watch face for the Forerunner 255. It displays hour and minute hands only, with no seconds hand, dial border, or hour marks.

## Preview

| No data fields enabled | All four data fields enabled |
| --- | --- |
| ![Watch face with no data fields](assets/empty.png) | ![Watch face with all data fields](assets/full-set.png) |

## Configurable fields

Each of the top, right, bottom, and left positions can independently show one of these options:

- None
- Date (`Sat 25`)
- Steps
- Heart rate
- Stress
- Battery
- Calories
- Distance

Selecting **None** leaves that position empty. Fields use compact white icons and values; the date is displayed without an icon.

The default configuration is stress at the top, heart rate on the left, date on the right, and an empty bottom position.

## Build and run

1. Install Garmin Connect IQ SDK Manager.
2. Install and activate a Connect IQ SDK, then install the `fr255` device definition.
3. Generate a Garmin developer key.
4. Build and run from VS Code with **Monkey C: Run Without Debugging**, selecting `fr255`.

To run from the command line:

```sh
SDK_PATH="/path/to/connectiq-sdk"
DEVELOPER_KEY="/path/to/developer_key.der"
OUTPUT_PATH="/tmp/AnalogNoSeconds.prg"

"$SDK_PATH/bin/monkeyc" \
  -d fr255 \
  -f monkey.jungle \
  -o "$OUTPUT_PATH" \
  -y "$DEVELOPER_KEY" \
  -w

open "$SDK_PATH/bin/ConnectIQ.app"
"$SDK_PATH/bin/monkeydo" "$OUTPUT_PATH" fr255
```

The developer key must remain private and must not be committed.
