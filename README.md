# Bug Reproduction: Deno Build Fails During `postinstall` for `@tailwindcss/oxide`

This repository contains a minimal setup to reproduce a build-time failure when installing npm dependencies that have native binaries (specifically `@tailwindcss/oxide`) using `deno install` inside a Docker container.

## The Problem

When building a Docker image for a minimal SvelteKit + Tailwind CSS project, the `RUN deno install --allow-scripts` command fails.

The root cause is a `TypeError` within Deno's internal Node.js `fs` compatibility layer. This is triggered by the `postinstall` script of the `@tailwindcss/oxide` package, which is a dependency of `@tailwindcss/vite`. The installation script for Oxide uses the Node `fs` API in a way that Deno's polyfill does not currently support, causing the entire build process to crash.

The stack trace clearly points to an issue in Deno's implementation of `fs.close`:

```
error: Uncaught TypeError: callback is not a function
    at ext:deno_node/_fs/_fs_close.ts:17:5
```

This is not a runtime issue; the dependencies fail to install correctly at build time.

## How to Reproduce

1.  Clone this repository.
2.  From the root directory, run the Docker build command:

    ```sh
    docker build . -t deno-tailwind-bug
    ```

## Expected Behavior

The `deno install` command completes successfully, and the Docker image builds without errors.

## Actual Behavior

The `docker build` process fails during the `RUN deno install --allow-scripts` step. The log clearly shows the script for `@tailwindcss/oxide` failing:

```
Initialize @tailwindcss/oxide@4.1.13: running 'postinstall' script
error: script 'postinstall' in '@tailwindcss/oxide@4.1.13' failed with exit code 1
stderr:
error: Uncaught TypeError: callback is not a function
    at ext:deno_node/_fs/_fs_close.ts:17:5
    at callback (ext:deno_web/02_timers.js:58:7)
    at eventLoopTick (ext:core/01_core.js:214:13)

error: failed to run scripts for packages: @tailwindcss/oxide@4.1.13
```

This provides clear evidence of a bug in Deno's Node.js compatibility layer.
