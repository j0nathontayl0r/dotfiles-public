# ~/.zprofile — login-shell setup. macOS-only tools are guarded so this file is
# a harmless no-op on Linux.

if [[ "$OSTYPE" == darwin* ]]; then
  # Homebrew (Apple Silicon)
  eval "$(/opt/homebrew/bin/brew shellenv)"

  # OrbStack: command-line tools and integration (macOS Docker/Linux VMs)
  source ~/.orbstack/shell/init.zsh 2>/dev/null || :
fi
