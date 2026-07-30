---
description: Tech Writer — document a shipped feature
argument-hint: <path to specs/*.md>
---

Use the **tech-writer** subagent to document the feature specified at
`$ARGUMENTS`, grounded in its spec, plan, and the staged/merged diff, following
its role instructions exactly. If no path is given, use the most recent file
under `specs/`.
