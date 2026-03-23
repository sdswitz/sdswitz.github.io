# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a static GitHub Pages personal site (`sdswitz.github.io`). It consists of a single `index.html` page with inline CSS and static assets in `assets/`.

## Architecture

- **No build step, no dependencies.** The site is plain HTML/CSS served directly by GitHub Pages.
- `index.html` — the entire site; contains inline `<style>` and markup.
- `assets/` — static images referenced by `index.html`.

## Deployment

Pushing to `main` automatically deploys via GitHub Pages. There is no CI, linting, or test suite.

## Preview

Open `index.html` directly in a browser to preview changes locally.
