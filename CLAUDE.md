# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a personal blog/website built with **Hexo** (Node.js static site generator) using the **NexT theme**. The site is automatically deployed to GitHub Pages via GitHub Actions when pushing to the `main` branch.

### Tech Stack

- **Hexo 8.1.1** - Static site generator
- **NexT theme** (Gemini scheme with light-dark mode)
- **Node.js 22** - Runtime environment
- **GitHub Actions** - CI/CD pipeline
- **GitHub Pages** - Hosting

## Common Commands

### Local Development

```bash
# Start local development server (cleans cache first)
npm run server

# Clean cache and generated files
npm run clean

# Generate static site
npm run build
```

### Git Workflow (via Makefile)

```bash
make br_main      # Checkout to main branch
make commit       # Stage all files and commit (empty message)
make info         # Display project information
```

### Creating New Posts

```bash
# Create a new post using scaffold
hexo new post "Post Title"

# Then manually organize into category subdirectory:
# - Move file to source/_posts/[category]/Post-Title.md
# - Create image directory at source/images/[category]/Post-Title/
# - Update front matter with category
```

## Branch Strategy

- **feat/articles** - Article publishing (only add to source/ subdirectories for categorization)
- **fix/somefunction** - Bug fixes
- **main** - Protected branch, PRs only, no direct push
- **gh-pages** - Auto-managed by GitHub Actions, avoid manual changes

## Architecture

### Directory Structure

```
source/
├── _posts/              # Blog posts organized by category
│   ├── algos/          # Algorithm & DSA posts
│   ├── android/        # Android development posts
│   └── something/      # General posts
├── images/             # Image assets (mirrors _posts/ structure)
│   ├── algos/
│   └── android/
├── l2dmodels/          # Live2D model files
├── categories/         # Auto-generated category index
└── tags/               # Auto-generated tag index

themes/
└── next/               # NexT theme (Git submodule)
```

### Theme Configuration

The NexT theme is managed as a **Git submodule** forked from `hexo-theme-next`. Important notes:

- Active config: `themes/next/_config.yml` (Gemini scheme, light-dark mode)
- Backup config: `_config.next.bak.yml` (Pisces scheme, dark mode - not active)
- To update theme: `cd themes/next && git pull origin master`
- When cloning this repo: use `git clone --recursive` or run `git submodule update --init --recursive`

### Content Structure

**Post Front Matter Pattern:**
```yaml
---
title: DSA-Day02-1.两数之和
date: 2026-1-16 00:00:00
categories: 数据结构与算法
---

Summary content...

<!--more-->

Detailed content...
```

**Key Points:**
- Use `<!--more-->` tag to create post excerpts for index pages
- Images referenced from `/images/category/post-name/filename.ext`
- Permalink structure: `:title/` (based on title field)
- Categories: 数据结构与算法, Android

### CI/CD Pipeline

Triggered on push to `main` branch:

1. Checkout with submodules (recursively fetches `themes/next`)
2. Setup Node.js 22
3. Install dependencies
4. Run `hexo clean && hexo generate`
5. Deploy `public/` directory to `gh-pages` branch using `peaceiris/actions-gh-pages@v4`

## Key Features & Plugins

- **Local Search**: `hexo-generator-searchdb` (generates search.xml)
- **Comments**: Giscus (GitHub Discussions based) on `nexa1024/nexa1024.github.io`
- **Live2D Characters**: Two models (PermansorTerrae, Cyrene) with hitokoto.cn integration
- **Word Count**: `hexo-wordcount` displays reading time and word counts
- **Pinned Posts**: `hexo-generator-index-pin-top`
- **Syntax Highlighting**: highlight.js with line numbers

## Image Management

Images must be stored in `source/images/` to be included in the build. Reference them in posts using absolute paths from the `/images/` root.

**Example:**
```
Post: source/_posts/algos/Day02-Two_Sum.md
Image: source/images/algos/Day02-Two_Sum/diagram.png
Reference in markdown: ![](/images/algos/Day02-Two_Sum/diagram.png)
```

## Important Notes

1. **Theme is a submodule**: Always check `themes/next/_config.yml` for active theme configuration
2. **Clean cache**: If changes don't appear, run `npm run clean` before building
3. **Deployment is automatic**: Only push to `main` branch, never manually commit to `gh-pages`
4. **Post organization**: Follow existing pattern of organizing posts by category in subdirectories
5. **Image paths**: Always use absolute paths starting with `/images/`
