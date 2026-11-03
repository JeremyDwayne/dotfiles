# Moderation

Read during step 5 when the change adds or alters a feature a player sees, a game interface the plugin touches, or a doc. The rules live in the `runescape-plugin-api` skill's `references/guide/submission-guidelines.md`. This file holds the review questions.

Classify each feature in the change as Allowed, Subject to review or Prohibited, and put the class in the report. A prohibited feature is a BLOCKER. A subject-to-review feature with no plain explanation in the plugin's description is MINOR. The description lives in the repo README until submission, then in the mod.io listing too.

- Does it act for the player, by sending input, choosing an option, clicking, or adding a menu entry that sends an action? Prohibited.
- Does it show anything the player could not see or know, such as hidden or future state, an NPC's next attack or target, or a timer for a mechanic the game never shows? Prohibited, unless it matches a display the game already has for other content. For every piece of combat information shown, name the visible source in the game: a native panel's icons, the vars behind a native overlay, the game's own tooltips.
- Does it change a game interface? Hiding and recolouring are customisation. Unhiding hidden components is prohibited. So is moving or resizing the click zones of action bars, inventory, worn equipment, familiar interfaces or 3D components. A transparent interface that still takes clicks changes its effective click zone, so report it.
- Is it a combat overlay, an enemy timer or combat state? Subject to review. A recommendation such as "use X now" gets stricter review than a display.
- Does it read another player's information? Subject to review. Exporting it is prohibited.
- Does it need a permission? Every permission used is declared in `plugin.json`, and HTTP goes only to the manifest's `urls`. Data sent off the device needs the adequacy case in the description, per `references/guide/submission-adequacy.md`.
- Can a brand-new player follow the README? It says what each element shows, how to open the options, and what the plugin reads, in short plain sentences that name no source files. A user-visible change that leaves it stale is MINOR.
- Can a moderator follow the code? Each module's first comment says what it does and how it is used. A comment explains a non-obvious client trick, such as alpha instead of hidden, in game terms. The repo's client notes list each client behaviour the plugin depends on, with no dates, sources or history. Generated, minified or obfuscated code is rejected.
