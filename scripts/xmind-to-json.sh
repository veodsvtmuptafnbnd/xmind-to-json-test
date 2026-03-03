#!/bin/bash

# Find staged .xmind files
FILES=$(git diff --cached --name-only --diff-filter=ACM | grep '\.xmind$')

if [ -z "$FILES" ]; then
  exit 0
fi

for file in $FILES; do
  echo "Processing $file"

  # Determine output JSON path
  json_file="${file%.xmind}.json"

  # Extract content.json from xmind archive
  unzip -p "$file" content.json 2>/dev/null \
    | jq 'walk(if type == "object" then (del(.controlPoints, .lineEndPoints, .id, .revisionId, .theme, .position) | if has("attached") then .attached else . end) else . end)' \
    | jq -s . \
    > "$json_file"

  if [ $? -ne 0 ]; then
    echo "❌ Failed to extract JSON from $file"
    exit 1
  fi

  # Stage generated JSON
  git add "$json_file"

  echo "✔ Generated $json_file"
done

exit 0
