# Project Context

## Goal

Build a Garmin Connect IQ analog watch face for the Garmin Forerunner 255. It displays only hour and minute hands and provides four independently configurable data fields at the top, right, bottom, and left of the dial.

## Product requirements

- Do not draw a seconds hand.
- The four positions must be configurable in Garmin Connect IQ settings.
- Available field types: date, steps, heart rate, stress, battery, calories, and distance.
- Values unavailable on the current device should display `--` rather than cause an error.
- Keep visual redraw work lightweight for watch-face battery use.

## Project layout

- `manifest.xml`: Connect IQ application metadata and FR255 target.
- `monkey.jungle`: Connect IQ SDK source and resource paths.
- `resources/drawables/`: launcher icon resources required by the SDK build.
- `source/AnalogFourFieldApp.mc`: application entry point.
- `source/AnalogFourFieldView.mc`: face drawing and metric formatting.
- `resources/settings/properties.xml`: defaults for the four positions.
- `resources/settings/settings.xml`: Connect IQ settings-menu definitions.
- `resources/strings/strings.xml`: user-visible strings.

## Setup and verification

1. Install the Garmin Connect IQ SDK and download the Forerunner 255 device definition through SDK Manager.
2. Configure a developer key in the Garmin Monkey C extension or CLI.
3. Build/run from VS Code with **Monkey C: Run Without Debugging** and choose `fr255`.
4. Use the Connect IQ simulator settings to change each field and verify date, steps, heart rate, stress, battery, calories, and distance rendering.
5. Install the generated `.iq` file through Garmin Express or the Connect IQ app for on-device verification.

## Git

This repository was initialized locally for project history. Do not alter `.gitignore` merely to expose ignored files to an AI tool. Do not commit secrets, developer keys, SDK paths, or generated build artifacts.

## TODO

- Verify the layout and field readability on a physical FR255.
- Optionally tune colors, fonts, and dial markings after a screenshot comparison with the preferred Garmin stock analog face.
- Add additional device variants only when requested and after checking their display resolutions.
