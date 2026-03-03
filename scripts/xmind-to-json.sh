#!/bin/bash

FILE="$1"

# Extract content.json from the xmind (zip archive)
unzip -p "$FILE" content.json 2>/dev/null | jq -S .