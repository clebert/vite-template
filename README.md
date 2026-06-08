# vite-template

Minimal starter template for building a web app with Claude.

## Scaffold a new project

Create the GitHub repo first (the name matters — see [Deployment](#deployment)), then from an empty local directory run:

```sh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/clebert/vite-template/main/create.sh)" -- my-app
```

This downloads the template into the current directory, renames the placeholder in [vite.config.js](vite.config.js), [index.html](index.html) and [package.json](package.json) to `my-app`, writes a fresh README, then runs `git init` and `npm install`. Omit the `-- my-app` argument to be prompted (defaults to the current directory's name).

## Stack

- [Vite](https://vite.dev) — dev server and bundler
- [Preact](https://preactjs.com) + [`@preact/signals`](https://preactjs.com/guide/v10/signals/) — UI and state
- [Zod](https://zod.dev) — schema validation
- TypeScript in strict mode (Node version pinned in [.nvmrc](.nvmrc))

## Commands

```sh
npm install      # install dependencies
npm start        # start the dev server
npm run build    # type-check (tsc) + production build to dist/
```

## Deployment

Pushes to `main` are built and deployed to **GitHub Pages** by [.github/workflows/ci.yml](.github/workflows/ci.yml) (set the Pages source to "GitHub Actions" in the repo settings).

Project Pages are served from a subpath (`https://<user>.github.io/<repo>/`), so [vite.config.js](vite.config.js) sets Vite's `base` to the repo name for production builds — and to `/` for local dev. This is why the project name **must** match your GitHub repo name: a mismatch makes assets 404 on Pages. It's the only piece of GitHub Pages-specific config.
