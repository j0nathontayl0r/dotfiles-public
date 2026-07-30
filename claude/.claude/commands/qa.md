---
description: QA Engineer — verify the implementation against the spec
argument-hint: <path to specs/*.md>
---

Use the **qa** subagent to verify the current working tree against the spec at
`$ARGUMENTS` and write a report at `qa/<same-kebab-name>.md`, following its role
instructions exactly. If no path is given, use the most recent file under
`specs/`.
