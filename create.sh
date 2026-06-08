#!/bin/sh
# Scaffold a new project from clebert/vite-template into the current directory.
#
# Usage (run from an empty directory):
#   sh -c "$(curl -fsSL https://raw.githubusercontent.com/clebert/vite-template/main/create.sh)" -- my-app
#
# If you omit the name you'll be prompted, defaulting to the current dir name.
# The name becomes the npm package name AND the Vite `base` path, so it must
# match your GitHub repo name for GitHub Pages to resolve assets correctly.

set -eu

REPO="clebert/vite-template"
BRANCH="main"

die() {
  echo "create: $1" >&2
  exit 1
}

# --- resolve project name ---------------------------------------------------
name="${1:-}"
default_name="$(basename "$PWD")"

if [ -z "$name" ]; then
  if [ -r /dev/tty ]; then
    printf 'Project name [%s]: ' "$default_name" > /dev/tty
    read -r name < /dev/tty || name=""
  fi
  [ -n "$name" ] || name="$default_name"
fi

# Must be a valid npm package name and URL path segment: lowercase only, and
# not starting with '.', '_' or '-' (rejects '', '.', '..', '-rf', '_foo', …).
case "$name" in
  "") die "project name is empty" ;;
  [._-]*) die "name '$name' cannot start with '.', '_' or '-'" ;;
  *[!a-z0-9._-]*) die "name '$name' may only contain lowercase letters, digits, '.', '_' or '-'" ;;
esac

# --- refuse to scaffold into a non-empty directory --------------------------
[ -z "$(ls -A 2>/dev/null)" ] || die "current directory is not empty — run from an empty directory"

# --- download the template --------------------------------------------------
command -v curl > /dev/null 2>&1 || die "curl is required"
command -v tar  > /dev/null 2>&1 || die "tar is required"

echo "Downloading $REPO ($BRANCH)…"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
archive="$tmp/template.tgz"
# Download and extract as two checked steps: POSIX sh has no pipefail, so a
# piped `curl | tar` would hide curl's exit status behind tar's.
curl -fsSL "https://codeload.github.com/$REPO/tar.gz/refs/heads/$BRANCH" -o "$archive" \
  || die "failed to download template — is $REPO (branch $BRANCH) reachable?"
tar -xzf "$archive" -C "$tmp" || die "failed to extract the downloaded template archive"
src="$tmp/$(basename "$REPO")-$BRANCH"
[ -d "$src" ] || die "unexpected archive layout"

# Copy everything (incl. dotfiles), then drop files that are template-only.
cp -R "$src/." .
rm -f create.sh README.md

# --- replace the placeholder name -------------------------------------------
replace() { # <file> <sed-expression>
  sed "$2" "$1" > "$1.tmp" && mv "$1.tmp" "$1" || { rm -f "$1.tmp"; die "failed to rewrite $1"; }
}

replace vite.config.js "s|/vite-template/|/$name/|g"
replace package.json   "s|\"name\": \"vite-template\"|\"name\": \"$name\"|"
replace index.html     "s|<title>vite-template</title>|<title>$name</title>|"
printf '# %s\n' "$name" > README.md

echo "Renamed template → $name"

# --- git init (on branch main, matching CI) + install -----------------------
if command -v git > /dev/null 2>&1; then
  git init -q
  # Force branch `main`: CI/Pages only trigger on `main`, but a fresh git
  # install defaults to `master` unless init.defaultBranch is set. symbolic-ref
  # works on every git version (no commits exist yet), unlike `init -b`.
  git symbolic-ref HEAD refs/heads/main
  echo "Initialized empty git repository on branch main (files left unstaged for review)."
else
  echo "git not found — skipping git init." >&2
fi

if command -v npm > /dev/null 2>&1; then
  echo "Installing dependencies…"
  npm install || die "dependencies failed to install — fix the error above, then run 'npm install' in this directory"
else
  echo "npm not found — run 'npm install' yourself." >&2
fi

echo
echo "Done. Start the dev server with:  npm start"
