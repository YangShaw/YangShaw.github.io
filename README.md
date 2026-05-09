## Home feed command

Create a homepage feed entry with the current date/time filename and the `home`
category:

```sh
./bin/hugo new-home "这里写首页文字"
```

This creates `content/feeds/YYYYMMDD-HHMM.md` with:

```toml
categories = ['home']
```

Home entries live under `content/feeds/`, but they are hidden from `/feeds/`.
They remain discoverable from `/categories/home/`, and the latest one becomes
the homepage text.

To use the shorter `hugo new-home ...` form inside this repo, put the repo-local `bin`
directory before the system Hugo binary in your shell:

```sh
export PATH="$PWD/bin:$PATH"
hugo new-home "这里写首页文字"
```

All other Hugo commands are passed through to the system Hugo binary, so
`hugo server`, `hugo new ...`, and `hugo --quiet` continue to work through the
wrapper.

## Homepage font

Homepage text styling is controlled in `static/css/custom.css`:

```css
:root {
  --home-copy-font: "Noto Serif CJK SC", "Source Han Serif SC", Songti SC, STSong, serif;
}
```

To use a local font, put the font file under `static/fonts/`, add an
`@font-face` rule in `static/css/custom.css`, then set `--home-copy-font` to the
new font family.
