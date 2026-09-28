#!/usr/bin/env bash
# Bootstrap the Claude Code dotfiles on a new machine. Run ONCE per machine.
#
# What it does (all idempotent):
#   1. Stows claude/.claude/ into ~/.claude with --no-folding, so per-file
#      symlinks are created and Claude's runtime state (sessions, history,
#      credentials) is left untouched. This covers config only — settings.json,
#      CLAUDE.md, agents/, commands/.
#   2. Points ~/.claude/memory/host.md at this host's notes file, and merges
#      claude/settings.shared.json into the host-local ~/.claude/settings.json.
#   3. Enables the repo's pre-commit secret-scan hook (core.hooksPath lives in
#      .git/config, which is NOT carried by a clone, so it must be set locally).
#
# memory/ and projects/ are NOT part of this package and are NOT synced
# anywhere — each host's Claude memory and conversation transcripts stay on
# that host only. Transcripts capture arbitrary pasted text that can't safely
# be secret-scanned, so they never touch git either way.
#
# Safe to re-run: `stow -R` restows, and setting hooksPath again is a no-op.
#
# Note: this repo lives at ~/src/dotfiles, so stow's DEFAULT target would be
# ~/src (the parent), not ~. We therefore always pass `-t "$HOME"` explicitly.
set -euo pipefail

# Resolve $0 through symlinks (e.g. a `~/install.sh -> src/dotfiles/claude/install.sh`
# convenience link on every host) so repo_root is correct no matter how this
# script is invoked — plain `dirname "$0"` only reflects the invocation path,
# not the real one, and silently computes the wrong repo_root through a symlink.
resolve_script_dir() {
  local src="$1" dir target
  while [ -L "$src" ]; do
    dir="$(cd -P "$(dirname "$src")" && pwd)"
    target="$(readlink "$src")"
    case "$target" in
      /*) src="$target" ;;
      *) src="$dir/$target" ;;
    esac
  done
  cd -P "$(dirname "$src")" && pwd
}

repo_root="$(cd "$(resolve_script_dir "$0")/.." && pwd)"
cd "$repo_root"

command -v stow >/dev/null || { echo "error: GNU stow not installed." >&2; exit 1; }

# 1. If Claude Code has already been launched, it may have created REAL files
#    (settings.json, CLAUDE.md, agents/*, commands/*) that would block stow.
#    For every file this package provides (except memory/ and projects/, which
#    aren't part of this package at all), back up and remove any real file
#    (not already a symlink) at the corresponding ~/.claude path so stow can
#    own it.
pkg_dir="$repo_root/claude/.claude"
backup_dir="$HOME/.claude/pre-stow-backup.$(date +%Y%m%d%H%M%S)"
while IFS= read -r src; do
  rel="${src#"$pkg_dir"/}"          # e.g. agents/architect.md
  target="$HOME/.claude/$rel"
  if [[ -e "$target" && ! -L "$target" ]]; then
    mkdir -p "$backup_dir/$(dirname "$rel")"
    echo "Backing up existing real $rel -> ${backup_dir#"$HOME"/}/$rel"
    mv "$target" "$backup_dir/$rel"
  fi
done < <(find "$pkg_dir" -type f -not -path "*/memory/*" -not -path "*/projects/*")

# 2. Stow config (restow is idempotent). memory/ and projects/ are ignored —
#    they're plain host-local directories, not part of this package.
stow -R --no-folding --ignore='memory' --ignore='projects' -t "$HOME" claude
echo "Stowed claude/.claude (config) -> ~/.claude"

# 2b. Per-host memory: point ~/.claude/memory/host.md at THIS host's notes file
#     (host-<hostname>.md), matching the naming convention CLAUDE.md's
#     @memory/host.md import expects. Nothing syncs between hosts, so this is
#     purely local bookkeeping, not isolation from other machines' data.
mkdir -p "$HOME/.claude/memory"
host_mem="host-$(hostname -s).md"
if [ -f "$HOME/.claude/memory/$host_mem" ]; then
  ln -sfn "$host_mem" "$HOME/.claude/memory/host.md"
  echo "Linked ~/.claude/memory/host.md -> $host_mem"
else
  : > "$HOME/.claude/memory/host.md"   # no host notes yet for this machine: empty (import is a no-op)
  echo "No memory/$host_mem for this machine yet; created empty ~/.claude/memory/host.md"
fi

# 2c. Shared settings: settings.json is host-local and untracked (it holds
#     host paths, hooks and auto-mode notes), so the few keys every host should
#     share live in claude/settings.shared.json and are merged in here. Shared
#     keys win; everything else in the host file is kept. Written with `cat >`
#     so a stow symlink at ~/.claude/settings.json stays a symlink.
settings="$HOME/.claude/settings.json"
if command -v jq >/dev/null; then
  [ -s "$settings" ] || echo '{}' > "$settings"
  merged="$(jq -s '.[0] * .[1]' "$settings" "$repo_root/claude/settings.shared.json")"
  printf '%s\n' "$merged" > "$settings"
  echo "Merged claude/settings.shared.json -> ~/.claude/settings.json"
else
  echo "warning: jq not installed; skipped merging claude/settings.shared.json" >&2
fi

# 3. Enable the secret-scan pre-commit hook for this clone.
git config core.hooksPath git/hooks
echo "Enabled pre-commit secret-scan hook (core.hooksPath=git/hooks)"

echo "Claude dotfiles installed for $(hostname)."
