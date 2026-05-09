#!/usr/bin/env sh
set -eu

site_dir="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
test_stamp="20260509-1234"
target="$site_dir/content/feeds/$test_stamp.md"
out_dir="$site_dir/tmp/test-new-home-public"

rm -f "$target"
rm -rf "$out_dir"
trap 'rm -f "$target"; rm -rf "$out_dir"' 0

NEW_HOME_STAMP="$test_stamp" \
NEW_HOME_NOW="2026-05-09T12:34:56+08:00" \
  "$site_dir/bin/hugo" new-home "这是一段直接从命令写入首页的文字。"

if [ ! -f "$target" ]; then
  echo "new-home should create content/feeds/$test_stamp.md"
  exit 1
fi

if ! grep -q "categories = \\['home'\\]" "$target"; then
  echo "new-home should add only the home category"
  exit 1
fi

if ! grep -q "这是一段直接从命令写入首页的文字。" "$target"; then
  echo "new-home should write command text into the feed body"
  exit 1
fi

if NEW_HOME_STAMP="$test_stamp" "$site_dir/bin/hugo" new-home "重复创建应该失败" >/dev/null 2>&1; then
  echo "new-home should not overwrite an existing same-day file"
  exit 1
fi

"$site_dir/bin/hugo" --quiet --buildFuture --destination "$out_dir"

if grep -q "这是一段直接从命令写入首页的文字。" "$out_dir/feeds/index.html"; then
  echo "home entries should not appear in the feeds list"
  exit 1
fi

if ! grep -q "20260509-1234" "$out_dir/categories/home/index.html"; then
  echo "home entries should be discoverable in the home category"
  exit 1
fi
