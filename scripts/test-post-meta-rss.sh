#!/usr/bin/env sh
set -eu

site_dir="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
out_dir="$site_dir/tmp/test-post-meta-rss-public"

rm -rf "$out_dir"
trap 'rm -rf "$out_dir"' 0

hugo --quiet --source "$site_dir" --destination "$out_dir"

post_page="$out_dir/posts/20260506-film-learning/index.html"
home_page="$out_dir/index.html"

if ! grep -Eq '> *[0-9]+ *</span>' "$post_page"; then
  echo "post pages should show word count"
  exit 1
fi

if ! grep -Eq '[0-9]+ min' "$post_page"; then
  echo "post pages should show reading time"
  exit 1
fi

if [ "$(grep -c 'class="post-meta-icon"' "$post_page")" -lt 3 ]; then
  echo "post meta items should show icons for date, words, and reading time"
  exit 1
fi

if grep -Eq 'post-taxonomy-tag|/tags/' "$post_page"; then
  echo "post pages should not render tags"
  exit 1
fi

if grep -q '>RSS<' "$home_page"; then
  echo "main navigation should not render RSS as a text tab"
  exit 1
fi

if ! grep -q 'href="/index.xml"' "$home_page"; then
  echo "social links should include the site RSS feed"
  exit 1
fi

if ! grep -q 'rel="alternate"' "$home_page"; then
  echo "RSS alternate link should remain in the document head"
  exit 1
fi
