# dotfiles

Dotfiles were set up largely using the GNU stow instructions from this video:

https://www.youtube.com/watch?v=90xMTKml9O0

## oh-my-zsh theme + plugins

The Powerlevel10k theme and the `zsh-autosuggestions` / `zsh-syntax-highlighting`
plugins are loaded via oh-my-zsh, so they must live in `$ZSH_CUSTOM`
(`~/.oh-my-zsh/custom`) as git clones rather than as Homebrew formulas — this
keeps the setup identical on macOS and Linux, and avoids git submodules. On a
fresh machine run:

```sh
zsh/install-omz-extras.sh
```

The script is idempotent (clones what's missing, pulls updates for the rest).

## Moving or relocating the repo

The scripts self-locate (`$(dirname "$0")`), so day-to-day they don't care where
the repo lives. But **stow symlinks** bake in the path **at creation time** —
every `~/.foo -> …/dotfiles/…` link becomes dangling if the repo moves (e.g.
`~/repos/dotfiles` → `~/src/dotfiles`).

Recovery, per host (idempotent — done ad hoc; deliberately *not* a maintained
script, since a move is a rare one-off):

```sh
cd ~/src/dotfiles                                         # the NEW location
find ~ -maxdepth 4 -xtype l -lname '*dotfiles*' -delete   # drop stale links
stow -R -t ~ git zsh tmux config ssh                       # restow that host's packages (ssh = ~/.ssh/rc forwarded-agent symlink helper)
./claude/install.sh                                       # re-stow ~/.claude (config only)
```

`~/.claude/memory/` and `~/.claude/projects/` are unaffected by a repo move —
they're plain host-local directories, not stow symlinks into the repo.

Gotchas:

- `-t ~` is required — the repo isn't directly in `$HOME`, so stow's default
  target (`~/src`) is wrong.
- If a package target is a **real file** (a stale, non-stowed copy — e.g. an old
  `~/.tmux.conf` or `~/.gitconfig`), back it up and remove it first, or stow
  refuses with a conflict.
- The package set differs per host (headless boxes skip `wezterm`/`alacritty`).
- Verify: `find ~ -maxdepth 4 -xtype l -lname '*dotfiles*'` prints nothing. A
  genuinely *broken* link is `find ~ -xtype l`; a normal (coloured) symlink is
  not broken. Or just run `./stow-check` (see "Checking stow health" below).

## Checking stow health

`./stow-check` is a read-only audit of every stow package. It classifies each
target the package provides (linked, dangling, conflict, absolute-symlink,
missing — a package with *no* targets present is reported once as "never
stowed", which is informational, since some packages are intentionally skipped
per host), diffs conflicting real files against the repo copy so you can see
whether deleting the local file is safe, and prints the exact copy-paste
command to fix each problem. It executes nothing itself — every stow call it
makes is a dry run (`-n`).

```sh
./stow-check              # audit every package
./stow-check git ssh      # audit only the named packages
```

Exit codes: `0` — every package fully linked or never stowed (warnings such as
hand-made absolute symlinks are allowed); `1` — at least one real problem
(conflict, dangling or missing target); `2` — usage error (unknown package
name, or stow not installed).

## AI "team" workflow

A "team of AI" workflow — Product Owner, Architect, Developer, QA Engineer,
Code Reviewer, Tech Writer — where each role has a single responsibility and
hands off to the next through files (`specs/` → `plans/` → implementation →
`qa/` → `review/` → docs). The Code Reviewer exists only in the Claude Code
form.

It ships in two forms:

- **Amp** — the role *skills* are stowed globally to `~/.config/agents/skills/`
  from `config/.config/agents/skills/`.
- **Claude Code** — the same roles ported to subagents and slash commands under
  [`claude/.claude/`](./claude/.claude/), stowed to `~/.claude/`. Provides the
  agents `product-owner`, `architect`, `developer`, `qa`, `reviewer`,
  `tech-writer` and the commands `/spec`, `/plan`, `/qa`, `/docs`, plus a global `CLAUDE.md`.

Tracked and synced across all hosts via git: configuration and the AI-team
agents/commands. Still local-only: credentials, `history.jsonl`, `sessions/`,
daemon and cache state (see `.gitignore`).

**Memory** (`~/.claude/memory/`, imported by `CLAUDE.md`) and conversation
**transcripts** (`~/.claude/projects/`) are *not* part of the git repo and are
not synced anywhere — they stay on the host that created them. Transcripts
capture arbitrary pasted text and can't safely be secret-scanned (scanning
them would be almost all false positives), so shipping them through git would
mean a pasted credential lands in shared history with zero scanning and no
clean way to purge it — keeping them host-local sidesteps that entirely.

### Fresh machine setup

Run **once** per new machine, after cloning the repo to `~/src/dotfiles`:

```sh
brew bundle --file ~/src/dotfiles/homebrew/Brewfile
~/src/dotfiles/claude/install.sh
stow -R -t ~ git zsh tmux config ssh    # everything outside ~/.claude
```

Afterwards, `~/src/dotfiles/stow-check` verifies the links landed (see
"Checking stow health" above).

The Brewfile carries every CLI tool the workflows assume (including
`direnv`, `pre-commit`, `just`, `opentofu`, `gitleaks` for
terraform-platform local dev); `brew bundle` is idempotent too.

This is idempotent and:

1. Stows `claude/.claude/` into `~/.claude` with `--no-folding` (per-file
   symlinks). Covers config only — `settings.json`, `CLAUDE.md`, `agents/`,
   `commands/` — leaving Claude's runtime state (sessions, history,
   credentials) and the host-local `memory/`/`projects/` untouched. It also
   backs up and replaces any real `settings.json` that Claude Code created
   before the first stow.
2. Points `~/.claude/memory/host.md` at this host's notes file
   (`host-<hostname>.md`), creating an empty one if this machine doesn't have
   notes yet.
3. Enables the pre-commit secret-scan hook (`core.hooksPath=git/hooks`), which
   is **not** carried by a clone and so must be set per machine.

> **Why a script and not plain `stow claude`?** This repo lives at
> `~/src/dotfiles`, so stow's default target is the parent `~/src`, not `~`.
> The script always passes `-t "$HOME"`. If a machine's
> `ls -l ~/.claude/settings.json` ever shows a regular file instead of a
> symlink (a TUI action like `/theme` can atomically replace it), just re-run
> `install.sh` to restow.

Until this has been run, `.zshrc` prints a one-line reminder on shell start.

#### Per-host files stow deliberately does not carry

Five things are gitignored or host-local by design, so a fresh machine has to
set them up by hand. Stow completing without error does **not** mean these are
done — nothing warns you if they're missing.

1. **`~/.ssh/config`** — gitignored entirely (host definitions, identity pins
   and agent paths are per-machine and don't belong in a public repo). If you
   split shared host blocks into `~/.ssh/config.d/*.conf`, the `Include` line
   must sit **above every `Host` line in the file**: an `Include` placed after
   one is scoped to *that* block — OpenSSH treats it as conditional inclusion —
   so it silently applies to a single host instead of all of them. Use
   `ssh -G <alias>` to check, not eyeballing.

2. **`~/.gitconfig.local`** — included last by the stowed `~/.gitconfig`, so it
   wins. Carries whatever is machine-specific about signing: the macOS/Linux
   `op-ssh-sign` path on hosts that sign via 1Password, or a `user.signingkey`
   pointing at that host's own key on hosts that don't (see below).

3. **`~/.ssh/rc`** — on headless hosts, refreshes the stable
   `~/.ssh/agent.sock` symlink for a forwarded agent. It's in the `ssh`
   package, but where a real file already exists stow won't overwrite it.

4. **`~/.config/gh/hosts.yml`** — run `gh auth login` per host. `gh` writes a
   live `oauth_token` into this file, so it can never be a tracked dotfile;
   the `config` package ships `gh/config.yml` (preferences) but not this.

5. **`~/.granted/config`** — let `granted` create it on first run, then edit
   to taste. It's host-specific app state (e.g. a browser path), not shipped.

**Headless hosts should not depend on a forwarded or GUI-gated SSH agent for
git.** mosh forwards no agent at all, and 1Password's agent can only sign while
its desktop app is unlocked — either way, git fails with `Couldn't get agent
socket?` or `Permission denied (publickey)` the moment nothing is holding a
live session open. Every non-workstation host here instead has its own
passphrase-less key (`~/.ssh/github_<host>`), pinned in `~/.ssh/config` with
`IdentitiesOnly yes` and `IdentityAgent none` **scoped to the github.com block
only**, registered on GitHub as both an authentication and a signing key, and
listed in [`git/.config/git/allowed_signers`](./git/.config/git/allowed_signers).

### Secret-scan guard

The `pre-commit` hook (`git/hooks/pre-commit`, enabled by `install.sh`) blocks
any commit containing credential-shaped strings. Bypass a false positive with
`git commit --no-verify`.