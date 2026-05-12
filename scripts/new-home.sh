#!/usr/bin/env sh
set -eu

site_dir="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
file_stamp="${NEW_HOME_STAMP:-$(date "+%Y%m%d-%H%M")}"
now="${NEW_HOME_NOW:-$(date "+%Y-%m-%dT%H:%M:%S%z")}"
target="$site_dir/content/feeds/$file_stamp.md"

case "$now" in
  *[+-][0-9][0-9][0-9][0-9])
    now="$(printf "%s" "$now" | sed -E 's/([+-][0-9]{2})([0-9]{2})$/\1:\2/')"
    ;;
esac

if [ -e "$target" ]; then
  echo "Refusing to overwrite existing file: $target" >&2
  exit 1
fi

body="$*"
mkdir -p "$site_dir/content/feeds"

{
  printf "%s\n" "+++"
  printf "date = '%s'\n" "$now"
  printf "%s\n" "draft = false"
  printf "title = '%s'\n" "$file_stamp"
  printf "%s\n" "description = ''"
  printf "%s\n" "author = 'YangShaw'"
  printf "%s\n" "categories = ['home']"
  printf "%s\n\n" "+++"
  if [ -n "$body" ]; then
    printf "%s\n" "$body"
  fi
} > "$target"

printf "%s\n" "$target"
