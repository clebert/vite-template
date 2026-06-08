# CLAUDE.md

## Commands

After code changes, always run:

```sh
npm run build
```

## Git

Commit to `main` directly — do not create a new branch for a commit unless I explicitly ask for one.

Never stage changes (`git add`) on your own. Staging is my review workflow: I stage between turns so
I can diff exactly what you changed next, and unexpected staging makes it unclear how files got
there. Leave your edits unstaged. The one exception: when I ask you to commit, staging the relevant
changes as part of that commit is fine.
