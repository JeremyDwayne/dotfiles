---
name: rs-plugin-review
description: Review a RuneScape 3 Lua plugin branch, PR or diff for frame cost, client API misuse, Jagex moderation rules and game UI, then fix confirmed findings in their own commits. Use instead of deep-review whenever the code under review is an RS3 plugin (a main.lua and plugin.json the client loads).
---

# RS3 plugin review

A plugin runs inside the game client's frame. Every component write, client read and allocation in a handler is paid in the player's frame time. The API is thinly documented, Jagex moderates every release, and Lua has no type checker. The bugs a normal review misses sit on the *hot path*, in a call form nobody confirmed, and in game state the plugin changed and never restored. The review runs on the local branch, so the plugin is right before it is pushed or submitted.

Run the `deep-review` skill's workflow, `../deep-review/SKILL.md` from this skill's folder, including its ledger, refutation pass and report. Each step below adds to deep-review's step of the same number; where the two disagree, this file wins. Load `runescape-plugin-api` as well: every API name and call form in the change is checked against its references.

## Step 1, scope

Add to the reading list `plugin.json`, `.luacheckrc`, `.stylua.toml`, every module `main.lua` requires, and the repo's client notes, the doc that lists client behaviour found by testing (`docs/client-notes.md` in RuneUI). Read a plugin under about 3,000 lines in full: a handler's cost is the sum of its call tree, so a one-line change in a tick handler is judged against everything it reaches.

- Record `git rev-parse HEAD` before reading and check it again before the report. Review any commits that landed between.
- When the branch is gone or equals its base, take the base from the parent of the first commit the plan lists, or the reflog. For a whole-plugin review, use the root commit and say so.
- A plan step left unticked that the branch does not claim is open, not missing. List it under "Plan and spec" as open.
- When the plan links a picked mock, read it with the Artifact tool before judging look, layout or copy.
- The ledger's "Frame budget" section holds the steady numbers the last review measured per hot path handler. Keep them as the baseline for step 6.

## Step 2, change map and hot path map

`change_map.py` finds Lua `function` and `local function` definitions. Trace fields assigned as `M.name = ...` and functions returned inside tables by hand with `rg`. Skip it when the whole plugin is read in full.

Then map the hot path: every `Event.<Name>.Subscribe` and every `:Subscribe(ui.Hook...)`, its rate, and the functions it reaches. The fake client in step 6 prints the subscriptions to check the map against.

- `Event.Draw` runs every rendered frame. RuneUI measured about 30 a second; the client can draw at the display's rate.
- `Event.Logic` runs 50 times a second.
- `Event.ServerLogic` runs every 0.6 s.
- `Event.VarTransmit` and the inventory events arrive in bursts, many per tick in combat.
- `ONMOUSEREPEAT`, `ONHOLD` and `ONCLICKREPEAT` repeat while the cursor hovers or holds. Other hooks fire once per user action.

Everything reachable from the first four is hot path.

## Step 4, plan and spec

Grade a requirement "needs a client run" when only the real client can settle it: rendering, layout, font metrics, the frame cost of a client call, or how a game interface behaves. Name the `prl` check that settles it.

## Step 5, checklists

Walk the four references in place of deep-review's stack files, and answer each item with "checked, fine because ..." or "finding". Keep deep-review's `references/bug-classes.md` for nil, boundaries and copy drift.

- `references/frame-budget.md`: hot path writes, client reads, allocation and idle handlers.
- `references/api-contract.md`: call forms, proxy reads, lifecycle and restore, components, persistence, Lua 5.4.
- `references/game-ui.md`: accessibility, play over the game world, input, tooltips and states.
- `references/moderation.md`: Jagex plugin rules per feature, and what a player or moderator reads.

## Step 6, execute

From the plugin root, with `eval "$(luarocks --lua-version 5.4 path)"` and `~/.luarocks/bin` on `PATH`:

1. `busted`, `luacheck .`, `luac5.4 -p` on every `.lua` file, and `stylua --check` on the paths CI checks. Paste the results. A StyLua failure is MINOR. Run `stylua` on each file a fix touches and repeat until `--check` passes, since one pass does not always settle a table.
2. The `runescape-plugin-api` skill's `scripts/no-doc-refs.sh --range <base>`. It fails on an added line that cites the skills or the Jagex docs or carries an em dash, and on a commit message that does so or carries a Claude session or co-author line. Check that the repo has it installed as `pre-commit` and `commit-msg`. Install it if not, or report it in a report-only run.
3. Run the fake client, `scripts/fake_client.lua` beside this file: `lua5.4 <this skill's folder>/scripts/fake_client.lua <plugin dir> [scenario.lua]`. With no scenario it ticks against an empty game. For a change that draws, write a scenario in the scratchpad: set the vars and game components the change reads, as named in the plugin's adapter and the API skill's `references/observed/`, call `fake.load()`, tick until the state settles, then measure two unchanged ticks, a hover, a click, an idle Logic tick, and any window the change touches through `fake.ribbon`, `fake.button` and `fake.confirm`. The script header lists the calls. Scenarios are scratch checks, never committed.
4. Hold the *steady tick* bar: a tick where no game state, cursor or hover changed makes 0 writes. "writes by field" names the property that keeps changing. An idle steady tick above 0 on a hot path is MAJOR. Writes while the player drags or configures are expected, per frame-budget.md's "Configuring versus playing"; a drag that follows the cursor slower than every frame is the finding there. Compare each handler's client reads and KB allocated with the ledger's baseline; growth the change does not explain is a finding.
5. End the scenario with `fake.shutdown()`. It must report 0 plugin layer children left and 0 game component properties left changed.
6. When the change claims a cost improvement, run the same scenario on the commit before the claim's commit and report both. Extract it with `git archive <sha> | tar -x -C <scratch dir>`, which leaves the repo untouched.

The fake client proves counts, allocation and Lua errors. It does not prove rendering, layout or real client behaviour. Mark anything that depends on the client as unverified, such as a position or the frame cost of a client call, and name the `prl` check that would settle it. When the repo has a `verify-*` skill, drive each user-facing change through it. When a client run confirms a fact, record it per the API skill's "Recording discoveries".

## Step 7, refute and triage in game terms

A claim's trigger is a game state or player action: a combat burst of `VarTransmit`, an interface that unloads or reloads, logging out or a loading screen, `prl` or a re-enable, the option turned off mid-session, a drag released off the component, a Retina display, saved data from an older version.

For the refutation, give the fresh subagent the plugin directory, the base ref, `scripts/fake_client.lua`, and the `runescape-plugin-api` references, and leave out your notes. A claim about counts, allocation or a Lua error is settled by a fake client scenario, not by reading. A claim about the real client that no reading or scenario settles stays only when its impact is high, marked unverified with its `prl` check.

These stay out of the report: luacheck or StyLua output a fix already resolves, "cache this" without a steady tick count behind it, a call form the references confirm, and an API name you could settle by opening the reference.

Write the failure scenarios as a player or a moderator meets them. What catches each one: a busted spec, a fake client scenario, luacheck, the `no-doc-refs.sh` hook, Jagex moderation, or a player report.

Severity in game terms:

- **BLOCKER**: an error raised from a hot path handler, which repeats every tick. A game interface left invisible, broken or recoloured after shutdown, reload or the option turning off. A prohibited feature under moderation. Saved settings lost through a renamed key or a load that raises on old data.
- **MAJOR**: an idle steady tick above 0 writes. Client reads or allocation that grow with session length or loop without a bound, including a scan over config structs at runtime. A Draw or Logic handler that works while idle. An API name or call form missing from the references. A `GetComponent` call that can receive nil. A game change with no restore path. A combat feature with no visible source in the game. A signal carried only by a forbidden colour pair. A comment, doc or commit message citing the skills or the Jagex docs, or a commit message carrying an attribution line.
- **MINOR**: a player-facing doc left stale by the change, or one that names source files. Otherwise MINOR and NOTE follow deep-review.

## Step 8, fix

Each fix commit passes `no-doc-refs.sh`, `luacheck`, `stylua --check` and `busted`, and re-runs the scenario that found it. Fix commits stay local. Nothing is uploaded to mod.io or submitted for moderation; the person does that after reading the report.

## Step 9, report additions

The ledger is `.scratch/<branch>/review.md` with deep-review's `Reviewed:` line, so `file-pr` reads it the same way. In a report-only run, "Fixed" says so, and each open finding carries its suggested fix.

Add a "Frame budget" section after "Fixed": one line per hot path handler with its rate and the fake client's steady numbers (writes, client reads, KB allocated) beside the last review's, then the shutdown result, then the fake client output. Add a "Moderation" section listing each user-visible feature the change adds or alters, with its class from `references/moderation.md`.
