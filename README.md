# Deno Node.js fs.close compatibility issue with postinstall scripts

**Bug Report**: `TypeError: callback is not a function` in Deno's Node.js fs compatibility layer when running npm package postinstall scripts.

## Error

```
error: Uncaught TypeError: callback is not a function
    at ext:deno_node/_fs/_fs_close.ts:17:5
    at callback (ext:deno_web/02_timers.js:58:7)
    at eventLoopTick (ext:core/01_core.js:214:13)
```

## Reproduction

This occurs when packages with native postinstall scripts interact with Deno's Node.js fs compatibility layer. The error can manifest either:

- During `deno install --allow-scripts` (build-time failure)
- When running `deno task dev` (runtime failure)

### Steps

1. Clone this repo
2. Run: `docker build . -t deno-tailwind-bug`

### Expected

Installation succeeds without errors

### Actual

Build fails during postinstall scripts with the fs.close TypeError above.

## Environment

- **Deno**: 2.5.0
- **Platform**: Docker (denoland/deno:2.5.0 image)
- **Command**: `deno install --allow-scripts`

## Minimal Setup

This repo contains the minimal dependencies needed to reproduce the issue:

- `@tailwindcss/vite` (which depends on `@tailwindcss/oxide`)
- Basic SvelteKit setup

All versions are pinned and `deno.lock` is included for exact reproducibility.

## Root Cause

Deno's Node.js fs compatibility layer's `fs.close()` implementation expects a callback function parameter, but the native postinstall scripts from these packages appear to call it in a way that Deno's polyfill doesn't support.
