#!/usr/bin/env sh
set -eu

site_dir="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
out_dir="$site_dir/tmp/test-homepage-public"
test_feed="$site_dir/content/feeds/20990509-homepage-test.md"

rm -rf "$out_dir"
trap 'rm -rf "$out_dir"; rm -f "$test_feed"' 0
printf "%s\n" \
"+++" \
"date = '2099-05-09T09:00:00+08:00'" \
"draft = false" \
"title = 'Homepage Feed Test'" \
"description = 'should replace home text'" \
"tags = ['home']" \
"categories = ['home']" \
"+++" \
"" \
"这是一条自动替换首页文字的测试内容。" > "$test_feed"
hugo --quiet --buildFuture --source "$site_dir" --destination "$out_dir"

home_index="$out_dir/index.html"

if ! grep -q 'href="/" title="Home page"' "$home_index"; then
  echo "homepage should expose a Home tab in the main navigation"
  exit 1
fi

if ! grep -q 'home-landing' "$home_index"; then
  echo "homepage should render a dedicated landing content block"
  exit 1
fi

if grep -q '/posts/20260506-film-learning/' "$home_index"; then
  echo "homepage should not render post summaries by default"
  exit 1
fi

if ! grep -q '这是一条自动替换首页文字的测试内容。' "$home_index"; then
  echo "homepage should render the latest feed content tagged with the home category"
  exit 1
fi
