# Home Feed Sync Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Make homepage text update automatically from the latest feed entry categorized as `home`.

**Architecture:** Keep the standalone homepage tab and its layout, but change the content source. The homepage template will query `feeds` pages whose `categories` include `home`, sort by date descending, and render the newest one. If none exists, it will fall back to `content/_index.md`.

**Tech Stack:** Hugo templates, Markdown front matter, shell-based regression tests

---

### Task 1: Add failing regression coverage

**Files:**
- Modify: `scripts/test-homepage.sh`

**Step 1: Write the failing test**

Create a temporary feed entry with `categories = ['feeds', 'home']` and assert its body appears on `/`.

**Step 2: Run the test to verify it fails**

Run: `scripts/test-homepage.sh`
Expected: FAIL because the current homepage still renders only `content/_index.md`.

### Task 2: Switch homepage content source

**Files:**
- Modify: `layouts/index.html`

**Step 1: Query home feeds**

Filter `site.RegularPages` to `Type == feeds` and `Params.categories` intersecting `home`.

**Step 2: Render latest matching feed**

Sort descending by date and render the newest content block.

**Step 3: Preserve fallback**

If no matching feed exists, render `.Content` from `content/_index.md`.

### Task 3: Document authoring convention

**Files:**
- Modify: `archetypes/feeds.md`
- Modify: `content/_index.md`

**Step 1: Note the `home` category convention**

Add a short comment in the feed archetype so future posts can opt into homepage sync.

**Step 2: Reframe root content as fallback**

Keep `content/_index.md` as fallback copy rather than the primary source.

### Task 4: Verify

**Files:**
- Verify: `scripts/test-homepage.sh`
- Verify: `scripts/test-feeds-ui.sh`

**Step 1: Run homepage regression**

Run: `scripts/test-homepage.sh`
Expected: PASS

**Step 2: Run feeds regression**

Run: `scripts/test-feeds-ui.sh`
Expected: PASS

**Step 3: Run full site build**

Run: `hugo --quiet`
Expected: PASS
