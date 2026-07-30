# Global memory

Personal conventions that apply to every project unless a repo's own
`CLAUDE.md` overrides them.

## Voice & style
- British English spelling ("optimise", "colour", "behaviour").
- Be concise. Prefer the smallest correct change over the cleverest one.
- Show file paths clearly when working with files.

## The "team" workflow
This machine ships a five-role, spec-driven workflow as subagents and slash
commands. The single source of truth for behaviour flows through files:

```
specs/<feature>.md   ← Product Owner  (/spec)
plans/<feature>.md   ← Architect      (/plan)
<implementation>     ← Developer
qa/<feature>.md      ← QA Engineer    (/qa)
docs updates         ← Tech Writer    (/docs)
```

Hand-offs are explicit: each role writes its file, prints a hand-off line, and
stops. Do not skip ahead (e.g. don't start coding during planning).

- Keep the kebab-case feature name identical across `specs/`, `plans/`, `qa/`.
- The Architect decomposes work into **independent** tasks so the Developer can
  run them as parallel `Task` subagents.
- Never claim tests pass without running them.

## Coding defaults
- Read a neighbouring file first to match existing style before writing.
- Prefer extending existing modules over creating new ones.
- Look for project commands (lint / test / typecheck) in `AGENTS.md`,
  `package.json`, `Makefile`, or `justfile` before inventing your own.

## Secrets
Never write secrets, tokens, or credentials into tracked files. Use 1Password
references / `op run` for anything sensitive.

## Host-specific memory
`~/.claude/memory/` is host-local — not tracked in git, not synced to any
other machine (transcripts and memory capture arbitrary pasted text that
can't safely be secret-scanned, so neither ever goes through git).
`claude/install.sh` links `~/.claude/memory/host.md` to this host's
`host-<hostname>.md` purely as a naming convention matching the import below.
Add this host's notes as `~/.claude/memory/host-<hostname>.md`, then re-run
`claude/install.sh`.
@memory/host.md

## New-machine setup
This config is stowed from `~/src/dotfiles`. On a fresh machine, run
`~/src/dotfiles/claude/install.sh` once (stows `~/.claude` and enables the
secret-scan git hook). Authoritative runbook: the "Fresh machine setup"
section of the dotfiles `README.md`.

## Moving the repo
Scripts self-locate, but **stow symlinks** bake in the repo path at creation
time and go dangling if the repo moves. Per host, ad hoc (not a maintained
script): `find ~ -maxdepth 4 -xtype l -lname '*dotfiles*' -delete`, then
`stow -R -t ~ <pkgs>`, `./claude/install.sh`. Back up any **real** (non-symlink)
file blocking stow first. `-t ~` is required. Full recipe: README → "Moving or
relocating the repo".
