#!/usr/bin/env bash

set -euo pipefail

file=$(jq -r '.tool_input.file_path')

case "$file" in
  *.rb)  bundle exec rubocop -a "$file" ;;
  *.erb) npm run herb:format -- "$file" ;;
esac
