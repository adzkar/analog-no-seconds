#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENV_FILE="$ROOT_DIR/.env"
OUTPUT_DIR="$ROOT_DIR/build"
DEVICE="${DEVICE:-fr255}"

if [[ ! -f "$ENV_FILE" ]]; then
    echo "Missing $ENV_FILE. Set DEVELOPER_KEY to your .der signing key path." >&2
    exit 1
fi

source "$ENV_FILE"

if [[ -z "${DEVELOPER_KEY:-}" || ! -f "$DEVELOPER_KEY" ]]; then
    echo "DEVELOPER_KEY must point to an existing .der signing key." >&2
    exit 1
fi

if [[ -z "${SDK_PATH:-}" ]]; then
    SDK_CONFIG="$HOME/Library/Application Support/Garmin/ConnectIQ/current-sdk.cfg"
    if [[ ! -f "$SDK_CONFIG" ]]; then
        echo "Set SDK_PATH or activate a Connect IQ SDK in SDK Manager." >&2
        exit 1
    fi
    SDK_PATH="$(cat "$SDK_CONFIG")"
fi

if [[ ! -x "$SDK_PATH/bin/monkeyc" ]]; then
    echo "No Monkey C compiler found under SDK_PATH: $SDK_PATH" >&2
    exit 1
fi

mkdir -p "$OUTPUT_DIR"
OUTPUT_PATH="$OUTPUT_DIR/AnalogNoSeconds.prg"

"$SDK_PATH/bin/monkeyc" \
    -d "$DEVICE" \
    -f "$ROOT_DIR/monkey.jungle" \
    -o "$OUTPUT_PATH" \
    -y "$DEVELOPER_KEY" \
    -r \
    -w

echo "Built $OUTPUT_PATH"
