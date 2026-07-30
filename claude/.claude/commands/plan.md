---
description: Architect — turn a spec into an implementation plan
argument-hint: <path to specs/*.md>
---

Use the **architect** subagent to turn the spec at `$ARGUMENTS` into a plan at
`plans/<same-kebab-name>.md`, following its role instructions exactly. If no
path is given, use the most recent file under `specs/`.
