#!/usr/bin/env sh
set -eu

site_dir="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
out_dir="$site_dir/tmp/test-no-tags-public"

rm -rf "$out_dir"
trap 'rm -rf "$out_dir"' EXIT

if rg -n '^tags\s*=' "$site_dir/content" "$site_dir/archetypes"; then
  echo "content and archetypes should not define tags"
  exit 1
fi

hugo --quiet --source "$site_dir" --destination "$out_dir"

if [ -e "$out_dir/tags" ]; then
  echo "site should not generate tag taxonomy pages"
  exit 1
fi

if rg -n 'post-taxonomy-tag|feed-card-tags|/tags/' "$out_dir"; then
  echo "generated pages should not render tag UI or tag links"
  exit 1
fi
