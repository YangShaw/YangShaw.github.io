# Homepage Landing Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Replace the current root posts listing with a standalone homepage that shows editable text and normal section links.

**Architecture:** Add a local `layouts/index.html` override so the site root no longer uses the theme's default posts aggregation. Store homepage copy in `content/_index.md`, add a `Home` menu item in `hugo.toml`, and render quick links from the existing main menu so homepage navigation stays in sync with the tab bar.

**Tech Stack:** Hugo templates, Markdown content files, site config, shell-based regression tests

---

### Task 1: Homepage regression coverage

**Files:**
- Create: `scripts/test-homepage.sh`

**Step 1: Write the failing test**

Check that:
- the homepage contains a `Home` tab
- the homepage contains a dedicated landing block
- the homepage does not render a known post summary link

**Step 2: Run test to verify it fails**

Run: `scripts/test-homepage.sh`
Expected: FAIL because the current homepage has no `Home` menu item and still renders posts.

### Task 2: Add homepage navigation and content source

**Files:**
- Modify: `hugo.toml`
- Create: `content/_index.md`

**Step 1: Add the `Home` tab**

Insert a `menu.main` entry for `/` and move the existing entries down one weight.

**Step 2: Add editable homepage content**

Create root homepage content in `content/_index.md` with a short intro in Chinese that can be edited later without touching templates.

### Task 3: Override root homepage rendering

**Files:**
- Create: `layouts/index.html`
- Modify: `static/css/custom.css`

**Step 1: Render homepage copy**

Use `.Content` inside a dedicated `home-landing` block.

**Step 2: Render normal links**

Build homepage links from `.Site.Menus.main`, excluding the `Home` item itself.

**Step 3: Add minimal styling**

Add restrained homepage-specific styles that fit the existing Tokiwa look.

### Task 4: Verify

**Files:**
- Verify: `scripts/test-homepage.sh`
- Verify: `scripts/test-feeds-ui.sh`

**Step 1: Run homepage regression**

Run: `scripts/test-homepage.sh`
Expected: PASS

**Step 2: Run existing feeds regression**

Run: `scripts/test-feeds-ui.sh`
Expected: PASS

**Step 3: Run full site build**

Run: `hugo --quiet`
Expected: PASS
