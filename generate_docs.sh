#!/usr/bin/env bash
# generate_docs.sh — Generate Markdown documentation from Dart source files
# Copyright (C) 2026 Jay Smeekes — MijnKabelberekening

set -euo pipefail

OUTPUT="docs/documentation.md"
ROOT="$(cd "$(dirname "$0")" && pwd)"

mkdir -p "$ROOT/docs"

cat > "$OUTPUT" << 'HEADER'
# MijnKabelberekening — Code Documentation

> Auto-generated from Dart source files.
> Copyright (C) 2026 Jay Smeekes — Licensed under GPL-3.0.

---

## Table of Contents

HEADER

# Collect all dart files (lib + test)
DART_FILES=()
while IFS= read -r line; do
  DART_FILES+=("$line")
done < <(find "$ROOT/lib" "$ROOT/test" -name "*.dart" | sort)

# Build table of contents
for file in "${DART_FILES[@]}"; do
  rel="${file#$ROOT/}"
  anchor=$(echo "$rel" | tr '/' '-' | tr '.' '-' | tr '[:upper:]' '[:lower:]')
  echo "- [$rel](#$anchor)" >> "$OUTPUT"
done

echo "" >> "$OUTPUT"
echo "---" >> "$OUTPUT"
echo "" >> "$OUTPUT"

# Process each file
for file in "${DART_FILES[@]}"; do
  rel="${file#$ROOT/}"
  anchor=$(echo "$rel" | tr '/' '-' | tr '.' '-' | tr '[:upper:]' '[:lower:]')

  echo "## $rel {#$anchor}" >> "$OUTPUT"
  echo "" >> "$OUTPUT"
  echo "\`\`\`" >> "$OUTPUT"
  echo "Path: $rel" >> "$OUTPUT"
  echo "\`\`\`" >> "$OUTPUT"
  echo "" >> "$OUTPUT"

  # Extract /// doc comments + the line that follows them
  python3 - "$file" >> "$OUTPUT" << 'PYEOF'
import sys, re

with open(sys.argv[1]) as f:
    lines = f.readlines()

i = 0
while i < len(lines):
    line = lines[i].rstrip()

    # Collect consecutive /// doc comment block
    if re.match(r'\s*///', line):
        doc_lines = []
        while i < len(lines) and re.match(r'\s*///', lines[i]):
            doc_lines.append(lines[i].rstrip().lstrip().lstrip('/').lstrip())
            i += 1
        # The declaration after the doc block
        decl = lines[i].rstrip() if i < len(lines) else ''
        # Only show classes, functions, methods, enums, mixins
        if re.search(r'\b(class|enum|mixin|extension|typedef)\b', decl) or \
           re.match(r'\s*(static\s+)?(final\s+|const\s+)?[\w<>\[\]?,\s]+\s+\w+\s*\(', decl):
            print(f"### `{decl.strip()}`\n")
            for dl in doc_lines:
                print(f"{dl}")
            print()
        continue

    # Classes, enums, mixins without doc comments
    if re.match(r'\s*(abstract\s+)?(class|enum|mixin|extension)\s+\w+', line):
        print(f"### `{line.strip()}`\n")

    # Top-level functions / methods (heuristic: return type + name + '(')
    elif re.match(r'\s*(static\s+)?(Future|void|bool|int|double|String|List|Map|Widget|'
                  r'Set|dynamic|[\w<>\[\]?]+)\s+\w+\s*[(<]', line) and \
         not line.strip().startswith('//') and \
         not line.strip().startswith('return') and \
         not line.strip().startswith('final') and \
         not line.strip().startswith('const'):
        print(f"#### `{line.strip()}`\n")

    i += 1
PYEOF

  echo "" >> "$OUTPUT"
  echo "---" >> "$OUTPUT"
  echo "" >> "$OUTPUT"
done

echo "Documentation generated: $OUTPUT"
echo "Files processed: ${#DART_FILES[@]}"
