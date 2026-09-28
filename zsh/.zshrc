# ============================================================================
#  Cross-platform .zshrc  —  macOS + Linux (CachyOS)
#  Oh My Zsh + Powerlevel10k. OS-specific bits guarded with [[ "$OSTYPE" == darwin* ]].
# ============================================================================

# --- Startup nudges: MUST print ABOVE the instant-prompt preamble -----------
# p10k forbids console I/O AFTER the preamble (below); any echo goes here.
# Both blocks only stat a file — no dependency on Oh My Zsh or p10k.

# Nudge if the Claude dotfiles bootstrap hasn't been run on this machine.
# One stat, no side effects; self-erases once ~/src/dotfiles/claude/install.sh runs.
[[ -L ~/.claude/CLAUDE.md ]] || \
  echo "⚠️  Claude dotfiles not installed — run: claude/install.sh, found in your dotfiles"

# --- Powerlevel10k instant prompt (keep near the top) -----------------------
# Anything that needs console input (password/[y/n] prompts) must go ABOVE this.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# --- Oh My Zsh --------------------------------------------------------------
export ZSH="$HOME/.oh-my-zsh"

# Powerlevel10k as an Oh My Zsh custom theme on BOTH macOS and Linux (one mechanism).
# One-time install per machine (official OMZ method):
#   git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \
#     "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
ZSH_THEME="powerlevel10k/powerlevel10k"

# Plugins. macOS needs zsh-autosuggestions + zsh-syntax-highlighting installed
# (`brew install zsh-autosuggestions zsh-syntax-highlighting`, or as OMZ custom
# plugins). A missing plugin only warns; it won't break the shell.
plugins=(git sudo zsh-autosuggestions zsh-syntax-highlighting colored-man-pages command-not-found extract fzf)

source "$ZSH/oh-my-zsh.sh"

# ============================================================================
#  Personal polish
# ============================================================================

# --- History ----------------------------------------------------------------
HISTSIZE=50000
SAVEHIST=50000
setopt SHARE_HISTORY        # share history across open shells
setopt HIST_IGNORE_ALL_DUPS # drop older duplicate commands
setopt HIST_IGNORE_SPACE    # don't record commands starting with a space
setopt HIST_REDUCE_BLANKS   # tidy whitespace before saving
setopt INC_APPEND_HISTORY   # write each command as it's entered

# --- Preferred editor (best available) --------------------------------------
if command -v nvim >/dev/null; then export EDITOR=nvim
elif command -v vim >/dev/null; then export EDITOR=vim
else export EDITOR=nano; fi
export VISUAL="$EDITOR"

# --- Modern CLI replacements (only if installed) ----------------------------
if command -v eza >/dev/null; then
  alias ls='eza --group-directories-first'
  alias ll='eza -lah --group-directories-first --git'
  alias la='eza -a --group-directories-first'
  alias lt='eza --tree --level=2 --group-directories-first'
fi
command -v bat     >/dev/null && alias cat='bat --paging=never --style=plain'
command -v colorls >/dev/null && alias lc='colorls -lA --sd'   # macOS: gem install colorls

# --- Quality-of-life aliases ------------------------------------------------
alias ..='cd ..'
alias ...='cd ../..'
alias grep='grep --color=auto'
alias df='df -h'
alias du='du -h'
alias free='free -h'
command -v pip3    >/dev/null && alias pip='pip3'
command -v python3 >/dev/null && alias python='python3'

# workmux (git worktrees + tmux windows, https://workmux.raine.dev/)
command -v workmux >/dev/null && alias wm='workmux'

# --- Homelab VM shortcuts (per-machine, gitignored) --------------------------
# mosh + tmux aliases for the homelab hosts live in ~/.zshrc.local (sourced
# below) — host names, users and IPs don't belong in a public repo.
# Pattern: _mosh_tmux() { mosh --server="env LC_ALL=C.UTF-8 mosh-server" "$1" -- tmux new -A -s main }
#          alias myhost='_mosh_tmux user@myhost.example'

# Local persistent tmux session on THIS machine (no ssh). Attaches to "localdev"
# if it exists, else creates it. Same command on Mac + CachyOS, but each machine
# keeps its own independent session.
alias localdev='tmux new -A -s localdev'

# workmux dashboard inside the localdev session: attach if it exists, else
# create it running the dashboard. Run from a repo directory.
command -v workmux >/dev/null && alias wmd='tmux new -A -s localdev "workmux dashboard"'

# late.sh (SSH game, https://late.sh/). Unlike dev/backup, tmux runs LOCALLY
# here — it keeps the ssh client to the game alive so you can detach (C-a d)
# and re-attach later. Attach if the "late" session exists, else create it
# running the game. When the ssh connection ends, the session closes.
alias late='tmux new -A -s late "ssh late.sh"'

# --- Terminal recovery: stale mouse reporting --------------------------------
# tmux turns on mouse tracking in the TERMINAL (DECSET 1000/1002/1003 + 1006 SGR
# coords) and turns it off again on exit. If a remote tmux dies without cleanup
# (connection reset / broken pipe / SIGKILL), the reset bytes never arrive and
# WezTerm keeps encoding pointer events as ESC[<b;x;yM -- straight into the local
# shell, which echoes them as junk like "35;14;2M". Clearing the modes before
# every prompt makes the next Enter self-heal it.
# The $TMUX guard is essential: inside a LOCAL tmux this would disable that
# session's own mouse support on every prompt.
_reset_mouse_reporting() {
  [[ -n $TMUX || ! -t 1 || $TERM == (dumb|linux) ]] && return
  printf '\033[?1000l\033[?1002l\033[?1003l\033[?1006l\033[?1015l'
}
precmd_functions+=(_reset_mouse_reporting)

# --- Git helper: prune merged / deleted branches ----------------------------
git_prune_all() {
  echo "🔍 Fetching remote changes..."
  git fetch -p
  echo "✂️  Pruning origin's deleted remote-tracking branches..."
  git remote prune origin
  echo "🧹 Cleaning up local branches merged to master/main..."
  local base
  for base in master main; do
    git rev-parse -q --verify "refs/heads/$base" >/dev/null || continue
    # A base is always "merged" into itself; skip long-lived branches whatever is checked out.
    git for-each-ref --merged "$base" --format='%(refname:short)' refs/heads/ \
      | grep -vxE 'main|master|develop' \
      | xargs -n 1 git branch -d 2>/dev/null
  done
  echo "✅ Git pruning completed!"
}
alias gprune='git_prune_all'

# --- Linux-only: low-priority builds (keep desktop smooth during compiles) --
# Uses ionice + systemd-run, which don't exist on macOS.
#   nbuild paru -S <pkg>   (nice + idle IO)
#   sbuild paru -S <pkg>   (adds a hard CPU-weight cap via a user cgroup)
if [[ "$OSTYPE" != darwin* ]]; then
  nbuild() { nice -n19 ionice -c3 "$@"; }
  sbuild() { systemd-run --user --scope -p CPUWeight=20 nice -n19 ionice -c3 "$@" 2>/dev/null || nbuild "$@"; }
fi

# --- SSH agent for git/ssh signing (Linux only; macOS handled by 1Password itself) ---
# Prefer a LOCAL 1Password agent when it's actually running (GUI hosts: Balder).
# Otherwise fall back to a stable symlink (headless hosts: dev, backup — no local
# 1Password agent there; auth comes from an agent FORWARDED over SSH instead). A
# forwarded socket's path is different every connection, and reattaching to an
# existing tmux pane never refreshes an already-running shell's SSH_AUTH_SOCK — so
# point at a stable symlink instead. ~/.ssh/rc rewrites that symlink to the live
# socket on every new SSH connection, so even old panes keep working.
if [[ -S ~/.1password/agent.sock ]]; then
  export SSH_AUTH_SOCK=~/.1password/agent.sock
elif [[ "$OSTYPE" != darwin* ]]; then
  export SSH_AUTH_SOCK="$HOME/.ssh/agent.sock"
fi

# --- Claude Code: default model for unpinned subagents ----------------------
# Roles with a `model:` in ~/.claude/agents/*.md (architect + reviewer on Fable,
# the other four on Opus) override this; it only catches the rest —
# general-purpose, plugin agents, skill sub-agents (Explore and fork inherit the
# session model unless CLAUDE_CODE_SUBAGENT_MODEL_FORCE=1). Lives here, not in
# settings.json: that file is host-local and untracked, so this is the only way
# the default reaches every machine.
export CLAUDE_CODE_SUBAGENT_MODEL="opus[1m]"

# --- Claude Code: 1Password service account (macOS only) ---------------------
# op's Touch ID app integration re-prompts once per Claude session. A service
# account token (login keychain item "1PasswordServiceToken", scoped read-only
# to the vaults Claude needs) removes the prompt. Scoped to the claude process
# only, so interactive `op` keeps using the full app integration.
if [[ "$OSTYPE" == darwin* ]] && command -v op >/dev/null; then
  claude() {
    local t; t=$(security find-generic-password -s 1PasswordServiceToken -w 2>/dev/null)
    if [[ -n $t ]]; then OP_SERVICE_ACCOUNT_TOKEN=$t command claude "$@"
    else command claude "$@"; fi
  }
fi

# --- PATH additions (added only if the target actually exists) --------------
[[ -d "$HOME/.codeium/windsurf/bin" ]] && export PATH="$HOME/.codeium/windsurf/bin:$PATH"  # Windsurf
[[ -d "$HOME/bin" ]] && export PATH="$PATH:$HOME/bin"                                       # tfswitch / personal bins

# --- Smart cd (only if installed) -------------------------------------------
command -v zoxide >/dev/null && eval "$(zoxide init zsh)"   # adds `z <dir>`

# --- Per-machine overrides (gitignored; put secrets / one-off PATHs here) ----
[[ -r ~/.zshrc.local ]] && source ~/.zshrc.local

# --- Powerlevel10k prompt config (per-OS so each machine keeps its look) -----
if [[ "$OSTYPE" == darwin* ]]; then
  [[ -f ~/.p10k.zsh ]]       && source ~/.p10k.zsh          # macOS prompt
else
  [[ -f ~/.p10k.linux.zsh ]] && source ~/.p10k.linux.zsh    # Linux prompt
fi
