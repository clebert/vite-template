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

# Restrict to characters valid in both an npm package name and a URL path.
case "$name" in
  *[!A-Za-z0-9._-]*) die "name '$name' may only contain letters, digits, '.', '_' or '-'" ;;
esac

# --- guard against clobbering an existing project ---------------------------
[ -e package.json ] && die "package.json already exists here — refusing to overwrite"
[ -e .git ] && die ".git already exists here — refusing to overwrite"

# --- download the template --------------------------------------------------
command -v curl > /dev/null 2>&1 || die "curl is required"
command -v tar  > /dev/null 2>&1 || die "tar is required"

echo "Downloading $REPO ($BRANCH)…"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
curl -fsSL "https://codeload.github.com/$REPO/tar.gz/refs/heads/$BRANCH" | tar -xz -C "$tmp" \
  || die "failed to download template"
src="$tmp/$(basename "$REPO")-$BRANCH"
[ -d "$src" ] || die "unexpected archive layout"

# Copy everything (incl. dotfiles), then drop files that are template-only.
cp -R "$src/." .
rm -f create.sh

# --- replace the placeholder name -------------------------------------------
replace() { # <file> <sed-expression>
  sed "$2" "$1" > "$1.tmp" && mv "$1.tmp" "$1"
}

replace vite.config.js "s|/vite-template/|/$name/|g"
replace package.json   "s|\"name\": \"vite-template\"|\"name\": \"$name\"|"
replace index.html     "s|<title>Vite Template</title>|<title>$name</title>|"
printf '# %s\n' "$name" > README.md

echo "Renamed template → $name"

# --- git init + install -----------------------------------------------------
if command -v git > /dev/null 2>&1; then
  git init -q
  echo "Initialized empty git repository (files left unstaged for review)."
else
  echo "git not found — skipping git init." >&2
fi

if command -v npm > /dev/null 2>&1; then
  echo "Installing dependencies…"
  npm install
else
  echo "npm not found — run 'npm install' yourself." >&2
fi

echo
echo "Done. Start the dev server with:  npm start"
