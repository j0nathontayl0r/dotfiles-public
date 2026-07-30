# ~/.zshenv — sourced for EVERY zsh: login, interactive, AND non-interactive.
# That last case matters: `ssh host <cmd>` sources ONLY .zshenv — not .zshrc/.zprofile.
# So user-bin PATH belongs here, not in .zshrc, to be found by remote commands.
# Guarded so nested/subshell zsh invocations don't duplicate the entry.
[[ ":$PATH:" == *":$HOME/.local/bin:"* ]] || export PATH="$HOME/.local/bin:$PATH"

alias assume=". assume"

# Disable AWS CLI v2's default output paging (spawns `less`) — print
# straight to stdout instead.
export AWS_PAGER=""
