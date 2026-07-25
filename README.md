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
4. Create a local `.env` file containing the developer-key path:

```sh
DEVELOPER_KEY="/path/to/developer_key.der"
```

5. Build the signed watch-face file:

```sh
./scripts/build.sh
```

The output is written to `build/AnalogNoSeconds.prg`. The script resolves the active SDK automatically; set `SDK_PATH` before running it only if you need to override that SDK.

To test the output in the simulator:

```sh
SDK_PATH="/path/to/connectiq-sdk"

open "$SDK_PATH/bin/ConnectIQ.app"
"$SDK_PATH/bin/monkeydo" build/AnalogNoSeconds.prg fr255
```

The developer key must remain private and must not be committed.
