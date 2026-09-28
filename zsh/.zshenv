# ~/.zshenv — sourced for EVERY zsh: login, interactive, AND non-interactive.
# That last case matters: `ssh host <cmd>` sources ONLY .zshenv — not .zshrc/.zprofile.
# So user-bin PATH belongs here, not in .zshrc, to be found by remote commands.
# Guarded so nested/subshell zsh invocations don't duplicate the entry.
[[ ":$PATH:" == *":$HOME/.local/bin:"* ]] || export PATH="$HOME/.local/bin:$PATH"

# nvm (Node version manager) — belongs here rather than .zshrc so npm/node are
# also found by non-interactive shells (ssh host <cmd>, and tools that shell
# out via `zsh -c` without an interactive/login session).
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

alias assume=". assume"

# Disable AWS CLI v2's default output paging (spawns `less`) — print
# straight to stdout instead.
export AWS_PAGER=""

# Default region for the AWS CLI (granted writes no `region` into ~/.aws/config).
export AWS_REGION="ap-southeast-2"

# 1Password service account inside Claude Code's own command shells. Xirp and
# VS Code start claude without the .zshrc wrapper, and Claude's shell snapshot
# keeps no exported variables, so only .zshenv reaches those `zsh -c` shells.
if [[ -n $CLAUDECODE && -z $OP_SERVICE_ACCOUNT_TOKEN && "$OSTYPE" == darwin* ]]; then
  OP_SERVICE_ACCOUNT_TOKEN=$(security find-generic-password -s 1PasswordServiceToken -w 2>/dev/null)
  [[ -n $OP_SERVICE_ACCOUNT_TOKEN ]] && export OP_SERVICE_ACCOUNT_TOKEN || unset OP_SERVICE_ACCOUNT_TOKEN
fi
