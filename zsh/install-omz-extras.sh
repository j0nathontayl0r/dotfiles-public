#!/usr/bin/env bash
# Install the oh-my-zsh theme + plugins referenced in zsh/.zshrc.
#
# These live in $ZSH_CUSTOM (git clones) rather than as Homebrew formulas so the
# setup is identical on macOS and Linux. oh-my-zsh only discovers themes/plugins
# from its custom dir, so `brew install` of these would not be picked up by the
# `ZSH_THEME=...` / `plugins=(...)` mechanism in .zshrc.
#
# Idempotent: re-running pulls the latest for anything already cloned.
set -euo pipefail

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

clone_or_update() {
  local repo="$1" dest="$2"
  if [[ -d "$dest/.git" ]]; then
    echo "Updating $dest"
    git -C "$dest" pull --ff-only --quiet
  else
    echo "Cloning $repo -> $dest"
    git clone --depth=1 "$repo" "$dest"
  fi
}

clone_or_update https://github.com/romkatv/powerlevel10k.git \
  "$ZSH_CUSTOM/themes/powerlevel10k"
clone_or_update https://github.com/zsh-users/zsh-autosuggestions.git \
  "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
clone_or_update https://github.com/zsh-users/zsh-syntax-highlighting.git \
  "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"

# Make zsh the login shell — done LAST, so it only happens once the zsh env above
# is set up (avoids logging into a shell that errors on a half-configured .zshrc).
# Guarded + cross-platform: only if zsh is installed, in /etc/shells, and not
# already the login shell. Uses sudo if available (non-interactive), else falls
# back to plain chsh (prompts for the password).
zsh_path="$(command -v zsh || true)"
current_shell="$(dscl . -read "/Users/$USER" UserShell 2>/dev/null | awk '{print $2}')"
[[ -z "$current_shell" ]] && current_shell="$(getent passwd "$USER" 2>/dev/null | cut -d: -f7)"
[[ -z "$current_shell" ]] && current_shell="${SHELL:-}"
if [[ -n "$zsh_path" ]] && grep -qxF "$zsh_path" /etc/shells 2>/dev/null \
   && [[ "$current_shell" != "$zsh_path" ]]; then
  echo "Setting default login shell to $zsh_path for $USER"
  sudo chsh -s "$zsh_path" "$USER" 2>/dev/null || chsh -s "$zsh_path" "$USER" || \
    echo "  (chsh failed — set it manually: chsh -s $zsh_path)"
fi

echo "Done. Restart your shell (exec zsh) to load them."
