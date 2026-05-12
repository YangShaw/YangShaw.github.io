#!/usr/bin/env sh
set -eu

site_dir="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
out_dir="$site_dir/tmp/test-feeds-ui-public"
switch_config="$site_dir/tmp/test-feeds-ui-page-lower-left.toml"
switch_out_dir="$site_dir/tmp/test-feeds-ui-page-lower-left-public"

rm -rf "$out_dir" "$switch_config" "$switch_out_dir"
trap 'rm -rf "$out_dir" "$switch_config" "$switch_out_dir"' EXIT
hugo --quiet --source "$site_dir" --destination "$out_dir"

feeds_index="$out_dir/feeds/index.html"

if grep -q 'feed-card-title' "$feeds_index"; then
  echo "feeds list should not render feed titles"
  exit 1
fi

if grep -Eq 'feed-card-readmore|feed-card-permalink|Read more|Permalink' "$feeds_index"; then
  echo "feeds list should not render detail links"
  exit 1
fi

if grep -Eq 'feed-card-tags|post-taxonomy-tag|/tags/' "$feeds_index"; then
  echo "feeds list should not render tags"
  exit 1
fi

if ! grep -q 'site-aside-image-slot' "$feeds_index"; then
  echo "site aside should include the lower-left image slot"
  exit 1
fi

if ! grep -q 'site-page-lower-left-image-slot' "$feeds_index"; then
  echo "site should include the page lower-left image slot"
  exit 1
fi

if ! grep -q 'data-aside-image-position="aside"' "$feeds_index"; then
  echo "site should default the aside image position to aside"
  exit 1
fi

if ! sed -n '/site-aside-image-slot/,/<\/div>/p' "$feeds_index" | grep -q '<img src="/img/hornet-bg.png"'; then
  echo "default aside position should render the image in the aside slot"
  exit 1
fi

if ! grep -q 'class="feed-year-heading">2026<' "$feeds_index"; then
  echo "feeds list should render a 2026 year heading"
  exit 1
fi

if ! grep -q 'class="feed-year-heading">2023<' "$feeds_index"; then
  echo "feeds list should render a 2023 year heading"
  exit 1
fi

year_2026_line="$(grep -n 'class="feed-year-heading">2026<' "$feeds_index" | head -n 1 | cut -d: -f1)"
year_2023_line="$(grep -n 'class="feed-year-heading">2023<' "$feeds_index" | head -n 1 | cut -d: -f1)"
if [ "$year_2026_line" -ge "$year_2023_line" ]; then
  echo "feeds list should order year groups newest first"
  exit 1
fi

for feed_page in "$out_dir"/feeds/*/index.html; do
  if grep -Eq '<h1[^>]*>[^<]*随手记|<h[2-6][^>]*class="feed-card-title"' "$feed_page"; then
    echo "feed pages should not render feed titles"
    exit 1
  fi
done

sed "s/^asideImagePosition = .*/asideImagePosition = 'page-lower-left' # aside | page-lower-left/" "$site_dir/hugo.toml" > "$switch_config"
hugo --quiet --source "$site_dir" --config "$switch_config" --destination "$switch_out_dir"
switch_feeds_index="$switch_out_dir/feeds/index.html"

if ! grep -q 'data-aside-image-position="page-lower-left"' "$switch_feeds_index"; then
  echo "site should support switching the image position to page-lower-left"
  exit 1
fi

if ! sed -n '/site-page-lower-left-image-slot/,/<\/div>/p' "$switch_feeds_index" | grep -q '<img src="/img/hornet-bg.png"'; then
  echo "page-lower-left position should render the image in the page slot"
  exit 1
fi
