#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
SNAPSHOTS_BASE="$PROJECT_ROOT/DrinkSomeWaterSnapshotTests/Views/__Snapshots__"
OUTPUT_FILE="$PROJECT_ROOT/UI_CATALOG.md"

generate_catalog() {
    cat > "$OUTPUT_FILE" << 'HEADER'
# UI Catalog

> Auto-generated from snapshot tests. Run `./scripts/generate-ui-catalog.sh` to update.

This document showcases all UI components in the DrinkSomeWater app through snapshot test images.

## Table of Contents

- [Home Screen](#home-screen)
- [History Screen](#history-screen)
- [Settings & Onboarding](#settings--onboarding)

---

HEADER

    echo "## Home Screen" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
    add_section "HomeViewSnapshotTests"

    echo "## History Screen" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
    add_section "HistoryViewSnapshotTests"

    echo "## Settings & Onboarding" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
    add_section "UIKitViewControllerSnapshotTests"

    cat >> "$OUTPUT_FILE" << 'FOOTER'

---

## How to Update

1. Run snapshot tests: `tuist test DrinkSomeWaterSnapshotTests`
2. Run this script: `./scripts/generate-ui-catalog.sh`
3. Commit updated images and markdown

## Recording New Snapshots

To record new snapshots, set `record: .all` in the test suite:

```swift
@Suite(.snapshots(record: .all))
struct MyViewSnapshotTests { ... }
```

Then run tests and change back to `record: .missing`.
FOOTER

    echo "Generated UI Catalog at $OUTPUT_FILE"
}

add_section() {
    local test_name="$1"
    local snapshot_dir="$SNAPSHOTS_BASE/$test_name"

    if [ -d "$snapshot_dir" ]; then
        for img in "$snapshot_dir"/*.png; do
            if [ -f "$img" ]; then
                local filename=$(basename "$img")
                local name=$(echo "$filename" | sed 's/\.[^.]*$//' | sed 's/\./_/g')
                local display_name=$(echo "$name" | sed 's/_/ /g')
                local relative_path="DrinkSomeWaterSnapshotTests/Views/__Snapshots__/$test_name/$filename"
                
                echo "### $display_name" >> "$OUTPUT_FILE"
                echo "" >> "$OUTPUT_FILE"
                echo "![$display_name]($relative_path)" >> "$OUTPUT_FILE"
                echo "" >> "$OUTPUT_FILE"
            fi
        done
    else
        echo "_No snapshots found in $test_name._" >> "$OUTPUT_FILE"
        echo "" >> "$OUTPUT_FILE"
    fi
}

generate_catalog

echo "Done! UI Catalog generated at: $OUTPUT_FILE"
