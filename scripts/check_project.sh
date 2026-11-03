#!/usr/bin/env bash

set -euo pipefail

project_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if command -v godot4 >/dev/null 2>&1; then
  godot_command="godot4"
elif command -v godot >/dev/null 2>&1; then
  godot_command="godot"
else
  echo "Godot executable not found. Install Godot 4.7 or add it to PATH." >&2
  exit 2
fi

godot_version="$(${godot_command} --version)"
if [[ ! "${godot_version}" =~ ^4\.([0-9]+) ]] || (( BASH_REMATCH[1] < 7 )); then
  echo "Godot 4.7 or newer is required; found ${godot_version}." >&2
  exit 3
fi

echo "Using Godot ${godot_version}."
echo "Checking project import and script parsing with ${godot_command}..."
"${godot_command}" --headless --editor --path "${project_dir}" --quit

echo "Instantiating the main scene for a short headless smoke test..."
"${godot_command}" \
  --headless \
  --path "${project_dir}" \
  --script res://scripts/smoke_test.gd

echo "Godot project check passed."


