#!/usr/bin/env sh
set -eu

site_dir="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
file_stamp="${NEW_FEED_STAMP:-$(date "+%Y%m%d-%H%M")}"
now="${NEW_FEED_NOW:-$(date "+%Y-%m-%dT%H:%M:%S%z")}"
target="$site_dir/content/feeds/$file_stamp.md"
script="hans"

usage() {
  echo "Usage: hugo new-feed [--script hans|hant] TEXT" >&2
  echo "Aliases: --hans, --simplified, --简中, --hant, --traditional, --繁中" >&2
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --script)
      if [ "$#" -lt 2 ]; then
        usage
        exit 2
      fi
      script="$2"
      shift 2
      ;;
    --script=*)
      script="${1#--script=}"
      shift
      ;;
    --hans|--simplified|--简中)
      script="hans"
      shift
      ;;
    --hant|--traditional|--繁中)
      script="hant"
      shift
      ;;
    --help|-h)
      usage
      exit 0
      ;;
    --)
      shift
      break
      ;;
    -*)
      echo "Unknown option: $1" >&2
      usage
      exit 2
      ;;
    *)
      break
      ;;
  esac
done

case "$script" in
  hans|simplified|简中)
    opencc_config="t2s.json"
    ;;
  hant|traditional|繁中)
    opencc_config="s2t.json"
    ;;
  *)
    echo "Unknown script: $script" >&2
    usage
    exit 2
    ;;
esac

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
if [ -n "$body" ]; then
  opencc_bin="${OPENCC_BIN:-opencc}"
  if ! command -v "$opencc_bin" >/dev/null 2>&1; then
    echo "opencc is required for new-feed script conversion. Install opencc or set OPENCC_BIN=/path/to/opencc." >&2
    exit 127
  fi
  body="$(printf "%s\n" "$body" | "$opencc_bin" -c "$opencc_config")"
fi

mkdir -p "$site_dir/content/feeds"

{
  printf "%s\n" "+++"
  printf "date = '%s'\n" "$now"
  printf "%s\n" "draft = false"
  printf "title = '%s'\n" "$file_stamp"
  printf "%s\n" "description = ''"
  printf "%s\n" "author = 'YangShaw'"
  printf "%s\n" "categories = ['feeds']"
  printf "%s\n\n" "+++"
  if [ -n "$body" ]; then
    printf "%s\n" "$body"
  fi
} > "$target"

printf "%s\n" "$target"
