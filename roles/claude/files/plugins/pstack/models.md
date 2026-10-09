# pstack models

One line per role. A skill reads the role's line and passes the value as the Agent tool's `model`. Values are `opus`, `sonnet`, `haiku`, `fable`, or `inherit`. `inherit` means omit `model` so the role runs on the parent's model. A panel role takes a list, and one subagent runs per entry, so the list length sets the panel size. Edit a line to change a role.

| Role | Model |
|---|---|
| feature, refactoring | sonnet |
| bug-fix | sonnet |
| perf-issue | sonnet |
| hillclimb | sonnet |
| judgment and prose | opus |
| hardest tasks | opus |
| how explorer | sonnet |
| how explainer | opus |
| why investigators | sonnet |
| why synthesizer | opus |
| recall miners | haiku |
| reflect tooling | sonnet |
| reflect judgment, divergent, synthesizer | opus |
| arena runners | opus, sonnet |
| arena cross-judge pool | opus, sonnet |
| swarm workers | sonnet |
| architect runners | opus, sonnet |
| interrogate reviewers | opus, sonnet |

A panel gets its diversity from different models in the list. Prefer a judge or verifier on a different model from the agent whose work it checks.
