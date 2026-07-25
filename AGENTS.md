# Project Context

## Goal

Build a Garmin Connect IQ analog watch face for the Garmin Forerunner 255. It displays only hour and minute hands and provides four independently configurable data fields at the top, right, bottom, and left of the dial, plus configurable hand/accent/background colors.

## Product requirements

- Do not draw a seconds hand.
- The four positions must be configurable in Garmin Connect IQ settings, both via the phone app/Garmin Express and via an on-device "Customize" menu (`AppBase.getSettingsView()`). Without `getSettingsView()`, the watch's Apply/Customize prompt only offers "Apply" — this is a common Connect IQ pitfall.
- Hour hand color, minute hand color, accent color, and background color must each be independently configurable from the same 8-color palette (id 0-7: White, Black, Red, Orange, Yellow, Green, Blue, Gray). The id-to-color mapping lives in `source/ColorOptions.mc` and must stay in sync with `resources/settings/settings.xml`.
- Field-type ids (0-7: Date, Steps, Heart Rate, Stress, Battery, Calories, Distance, None) live in `source/FieldOptions.mc` and must stay in sync with `resources/settings/settings.xml` and `resources/settings/properties.xml`.
- Available field types: date, steps, heart rate, stress, battery, calories, and distance.
- Values unavailable on the current device should display `--` rather than cause an error.
- Field icons should be large enough to read at a glance; it is acceptable for them to overlap the watch hands.
- Field text color auto-contrasts (black/white) against the chosen background color so it stays legible for any combination.
- Keep visual redraw work lightweight for watch-face battery use.

## Project layout

- `manifest.xml`: Connect IQ application metadata and FR255 target.
- `monkey.jungle`: Connect IQ SDK source and resource paths.
- `resources/drawables/`: launcher icon resources required by the SDK build.
- `source/AnalogFourFieldApp.mc`: application entry point; also wires up `getSettingsView()` for the on-device Customize menu.
- `source/AnalogFourFieldView.mc`: face drawing, field icons, and metric formatting.
- `source/SettingsMenu.mc`: on-device Menu2 UI (field pickers + color pickers) shown when the user taps Customize on the watch.
- `source/FieldOptions.mc`: shared field-type id/label mapping.
- `source/ColorOptions.mc`: shared color id/value/label/contrast mapping.
- `resources/settings/properties.xml`: defaults for the four positions and four colors.
- `resources/settings/settings.xml`: Connect IQ settings-menu definitions (phone app / Garmin Express).
- `resources/strings/strings.xml`: user-visible strings.

## Setup and verification

1. Install the Garmin Connect IQ SDK and download the Forerunner 255 device definition through SDK Manager.
2. Configure a developer key in the Garmin Monkey C extension or CLI.
3. Build/run from VS Code with **Monkey C: Run Without Debugging** and choose `fr255`, or run `./scripts/build.sh` (requires `.env` with `DEVELOPER_KEY`; local SDK is auto-detected).
4. Use the Connect IQ simulator settings to change each field and verify date, steps, heart rate, stress, battery, calories, and distance rendering, plus each color setting.
5. On a physical watch, verify the Apply/Customize prompt actually shows a working Customize menu (not just Apply) after installing.
6. Install the generated `.iq`/`.prg` file through Garmin Express or the Connect IQ app for on-device verification.

## Git

This repository was initialized locally for project history. Do not alter `.gitignore` merely to expose ignored files to an AI tool. Do not commit secrets, developer keys, SDK paths, or generated build artifacts.

## TODO

- Verify the layout and field readability on a physical FR255.
- Optionally tune colors, fonts, and dial markings after a screenshot comparison with the preferred Garmin stock analog face.
- Add additional device variants only when requested and after checking their display resolutions.
