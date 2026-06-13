# CLAUDE.md

## Git

When I ask for a commit, go straight to `main`; branch only if I ask. Never `git add` on your own —
staging is my review workflow; leave edits unstaged. Staging is fine only as part of a commit I
asked for.

## Concurrent agents

Other agents may be working in this repo at the same time. A change appearing in — or vanishing
from — the working tree isn't necessarily my decision; I may not even know about it. If something
you wrote was reverted or overwritten — especially a real fix — don't assume intent either way:
surface it and ask me before re-applying it or adapting to the change.

## Comments

- Fewer comments are better. A comment exists to help understand the file, to explain a magic
  number, or to record a non-obvious decision — nothing else.
- Comments are not a decision log and not a record of our sessions: timeless, impersonal,
  evidence-based. No names, no dates, no quotes, no pointers to documents or conversations.
- The code is the single source of truth. If something matters but doesn't belong in code, say it
  in the chat instead of writing it into the repo.

## Code

- **Type strictly.** No `any` (use `unknown` + narrowing), no `as`/`!` to silence the compiler.
  Model illegal states out with unions and literals; prefer `readonly`.
- **Small modules.** One concern per file, export the minimum.
- **No new dependencies.** Build on what's already here and Web APIs; ask before adding any.
- **House style.** 2-space indent, ≤100 cols, `import type` for types, `.ts` on relative imports.

## Tests

- Built-ins only: `node:test` for the runner, `node:assert/strict` for assertions. No external
  framework — Node strips the types at runtime, so there's no `tsx`/build step (but `tsc` still
  type-checks the test files).
- Colocate each test next to its module with a `.test.ts` extension: `foo.ts` → `foo.test.ts`.
- Keep tests pure where the code is pure.

## Stack

Client-side Preact + signals app, validated with Zod, type-checked by TypeScript, bundled by Vite,
deployed to GitHub Pages. No backend we control — every external input is untrusted.

### Commands

- `npm start` — dev server.
- `npm run build` — `tsc` (the type gate) then `vite build`.
- `npm test` — runs the test suite.
- `npm run ci` — `npm run build` then `npm test`.

**Run `npm run ci` after every code change; a clean run is the bar to clear.**

### Rules

- **Logic out of components.** Domain logic, calculations, and parsing live in pure modules (no
  Preact/signals imports). Components read state and render; they delegate every decision.
- **Validate at the boundary.** Parse all external input with a Zod schema — `fetch`, storage, URL
  params, imported files, anything `JSON.parse`d. Derive the type via `z.infer`; never hand-write a
  parallel `interface`.
- **Test the boundary offline.** Stub `globalThis.fetch` and pass a `baseUrl` rather than hitting
  the network.

### Structure

Dependencies point inward toward `domain`; `domain` imports nothing of ours.

- `src/domain/` — pure logic, types, Zod schemas (Zod only)
- `src/connectors/` — external API clients: fetch + Zod-validate at the boundary, map wire → domain
- `src/state/` — signals + actions wiring connectors/domain to reactive state
- `src/ui/` — presentational components
- `src/app.tsx` — composition root
