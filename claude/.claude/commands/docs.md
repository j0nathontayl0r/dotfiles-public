---
description: Tech Writer — document a shipped feature
argument-hint: <path to specs/*.md>
---

Use the **tech-writer** subagent to document the feature specified at
`$ARGUMENTS`, grounded in its spec, plan, and the staged/merged diff, following
its role instructions exactly. If no path is given, use the most recent file
under `specs/`.

## Living specs

Only when the repo has a `specs/current/` folder (its `CLAUDE.md` may map
`specs/` elsewhere, e.g. `docs/specs/`). Otherwise skip this section.

1. **Before dispatch**, find the merged PRs that implemented the spec. The
   agent cannot run `gh`, so you do. Use `gh pr list --state merged --search
   <spec stem>`, issue references in the spec, and `git log --oneline --
   <paths the plan names>`. Give the commit SHA for work with no PR. Pass the
   list in the dispatch, with the acceptance criteria each PR covers where the
   spec or plan makes that clear.
2. **After the agent returns**, run the repo's living-spec check: the test
   documented for `specs/current/` in `CLAUDE.md`, `AGENTS.md`, `justfile` or
   `Makefile`, or `tests/test_living_specs.py` when present. Quote the command
   and its output. Run `git diff --stat` and confirm only docs changed.
3. **On failure**, send the quoted failures back to the same tech-writer once,
   re-run the check, and quote the result. If it fails again, stop and report
   to the user with the output. Do not fix the fold by hand. Never claim the
   check passed without running it.
