#!/usr/bin/env sh
set -eu

site_dir="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
test_stamp_default="20260513-1011"
test_stamp_traditional="20260513-1012"
target_default="$site_dir/content/feeds/$test_stamp_default.md"
target_traditional="$site_dir/content/feeds/$test_stamp_traditional.md"
out_dir="$site_dir/tmp/test-new-feed-public"

rm -f "$target_default" "$target_traditional"
rm -rf "$out_dir"
trap 'rm -f "$target_default" "$target_traditional"; rm -rf "$out_dir"' 0

NEW_FEED_STAMP="$test_stamp_default" \
NEW_FEED_NOW="2026-05-13T10:11:12+08:00" \
  "$site_dir/bin/hugo" new-feed "風乾了憂傷，雨散了惆悵。"

if [ ! -f "$target_default" ]; then
  echo "new-feed should create content/feeds/$test_stamp_default.md"
  exit 1
fi

if ! grep -q "categories = \\['feeds'\\]" "$target_default"; then
  echo "new-feed should add the feeds category"
  exit 1
fi

if grep -q '^tags =' "$target_default"; then
  echo "new-feed should not write tags"
  exit 1
fi

if ! grep -q "风干了忧伤，雨散了惆怅。" "$target_default"; then
  echo "new-feed should default to simplified Chinese content"
  exit 1
fi

NEW_FEED_STAMP="$test_stamp_traditional" \
NEW_FEED_NOW="2026-05-13T10:12:13+08:00" \
  "$site_dir/bin/hugo" new-feed --script hant "风干了忧伤，雨散了惆怅。"

if [ ! -f "$target_traditional" ]; then
  echo "new-feed should create content/feeds/$test_stamp_traditional.md"
  exit 1
fi

if ! grep -q "風乾了憂傷，雨散了惆悵。" "$target_traditional"; then
  echo "new-feed should support traditional Chinese output"
  exit 1
fi

if NEW_FEED_STAMP="$test_stamp_default" "$site_dir/bin/hugo" new-feed "重复创建应该失败" >/dev/null 2>&1; then
  echo "new-feed should not overwrite an existing same-minute file"
  exit 1
fi

"$site_dir/bin/hugo" --quiet --buildFuture --destination "$out_dir"

if ! grep -q "风干了忧伤，雨散了惆怅。" "$out_dir/feeds/index.html"; then
  echo "new-feed entries should appear in the feeds list"
  exit 1
fi

if ! grep -q "風乾了憂傷，雨散了惆悵。" "$out_dir/feeds/index.html"; then
  echo "new-feed should publish traditional output when requested"
  exit 1
fi
