#!/usr/bin/env bash
#
# setup-local.sh — wire this Zed extension to a LOCAL copy of the
# tree-sitter-aggressor grammar so you can run it without pushing to GitHub.
#
# It makes the grammar folder a git repo with a commit (Zed needs a `rev`),
# then rewrites the [grammars.aggressor] block in extension.toml to point at
# that folder via a file:// URL pinned to the commit SHA.
#
# Usage:
#   ./setup-local.sh /absolute/path/to/tree-sitter-aggressor
#
set -euo pipefail

if [ "${1:-}" = "" ]; then
  echo "Usage: $0 /path/to/tree-sitter-aggressor" >&2
  exit 1
fi

EXT_DIR="$(cd "$(dirname "$0")" && pwd)"
GRAMMAR_DIR="$(cd "$1" && pwd)"
EXT_TOML="$EXT_DIR/extension.toml"

if [ ! -f "$GRAMMAR_DIR/grammar.js" ] || [ ! -f "$GRAMMAR_DIR/src/parser.c" ]; then
  echo "error: $GRAMMAR_DIR does not look like tree-sitter-aggressor" >&2
  echo "       (expected grammar.js and src/parser.c)" >&2
  exit 1
fi

# Ensure the grammar is a git repo with at least one commit.
if [ ! -d "$GRAMMAR_DIR/.git" ]; then
  echo "• git init $GRAMMAR_DIR"
  git -C "$GRAMMAR_DIR" init -q
fi
if ! git -C "$GRAMMAR_DIR" rev-parse HEAD >/dev/null 2>&1; then
  echo "• creating initial commit"
  git -C "$GRAMMAR_DIR" add -A
  git -C "$GRAMMAR_DIR" \
    -c user.email="dev@localhost" -c user.name="local dev" \
    commit -q -m "tree-sitter-aggressor grammar"
elif [ -n "$(git -C "$GRAMMAR_DIR" status --porcelain)" ]; then
  echo "• committing local changes to the grammar"
  git -C "$GRAMMAR_DIR" add -A
  git -C "$GRAMMAR_DIR" \
    -c user.email="dev@localhost" -c user.name="local dev" \
    commit -q -m "update tree-sitter-aggressor grammar"
fi

REV="$(git -C "$GRAMMAR_DIR" rev-parse HEAD)"
URL="file://$GRAMMAR_DIR"

echo "• grammar repo : $GRAMMAR_DIR"
echo "• grammar rev  : $REV"

# Rewrite only the lines inside the [grammars.aggressor] block.
awk -v url="$URL" -v rev="$REV" '
  /^\[grammars\.aggressor\]/ { ingrammar=1; print; next }
  /^\[/ && !/^\[grammars\.aggressor\]/ { ingrammar=0 }
  ingrammar && /^[[:space:]]*repository[[:space:]]*=/ { print "repository = \"" url "\""; next }
  ingrammar && /^[[:space:]]*rev[[:space:]]*=/        { print "rev = \"" rev "\"";       next }
  { print }
' "$EXT_TOML" > "$EXT_TOML.tmp" && mv "$EXT_TOML.tmp" "$EXT_TOML"

echo
echo "✓ extension.toml now points at your local grammar."
echo
echo "Next:"
echo "  1. Open Zed → Extensions → Install Dev Extension → choose this folder:"
echo "       $EXT_DIR"
echo "  2. Open any .cna file. (Rust via rustup must be installed; Zed builds the grammar.)"
echo
echo "If you later edit the grammar, re-run this script to re-pin the new commit,"
echo "then reload the dev extension in Zed."
