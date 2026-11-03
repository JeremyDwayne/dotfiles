# API contract

Read during step 5 with `runescape-plugin-api` loaded. The rule: every API name and call form in the change appears in a reference file. One that does not is a MAJOR finding until a client run confirms it.

## Call forms

- Events take a dot call with a reference name: `Event.X.Subscribe("name", fn)`. A name is unique per event per plugin, and reusing one silently replaces the earlier handler. Check each new name against the others on the same event.
- Component methods and hooks take a colon: `c:SetPos(x, y)`, `c:Subscribe(ui.Hook.ONCLICK, fn)`. A hook on a game component subscribes by name, `c:Subscribe(hook, name, fn)`, and `c:Unsubscribe(hook, name)` drops it on shutdown.
- Static functions take a dot: `Player.IsAvailable()`, `Mouse.GetX()`, `Inventory.Find(id)`, `config.Struct.FromID(id)`.
- Singletons with methods take a colon: `ui.Interfaces:GetComponent(...)`, `PersistentDB:GetStructuredData(key)`.
- `ui.Interfaces:GetComponent` refuses a nil in any argument given and raises "no matching function call". A top-level layer takes its id alone, a static component two ids and a dynamic child four. Check that no call site can pass nil.
- `AlignTo(horizontal, vertical)` takes two alignment modes.
- Name each `<!-- VERIFY -->` detail the change depends on in the report as unverified, with the `prl` check that would settle it.
- `OBSERVED` notes outrank the docs. Examples: an inventory's `valid` reads nil, `ONDRAG` never fires, and `GetParamValue` on some params logs a conversion error.

## Proxy reads

- A game proxy can raise on a missing field or return nil. Client reads live in one adapter module that wraps them in `pcall` and returns plain tables. Models and views never touch the client, which is also what lets busted specs run. A new client read outside the adapter is a finding. Three things are exempt: `Mouse.GetX` and `GetY` in input handlers, fields of an event payload, and properties of the plugin's own components such as `layer.x`.
- Treat every read as possibly nil, including the ones that always seem to exist. Interfaces unload: the target panel unloads while a target is still set. Vars are nil before login, and `Player.GetEntity()` is nil while loading.
- A failed read logs once per session, not once per tick.

## Lifecycle and restore

- `main.lua` reruns on every `prl` and on enable. Module state starts fresh, and anything that must survive goes through PersistentDB.
- `PluginShutdown` destroys every component the plugin put on the plugin layer. It also restores every game interface property the plugin changed, such as alpha, hidden, colour or text, and drops every hook it put on a game component. Check that each write to a game component has a restore path, including turning the option off mid-session. The fake client's `fake.shutdown()` lists what was left.
- A game interface the plugin changes can reload and reset itself. A cheap per-tick check reapplies the change; it must not rescan the whole interface every tick.
- A hook on a client-owned component, such as the ribbon layer from `ContentLayerReady`, fires each time the client builds that layer. Its handler must not pile up state across calls.

## Components

- Every component gets an explicit `SetSize` and `SetPos` before it is first shown. `ui.Text` needs `font` before it shows, and styled components need `stylesheetID`.
- Plain components start with `enabled = false` and `clickthrough = true`, so clicks pass through them to the game world. Give each clickable thing one hit area with `enabled = true` and `clickthrough = false`. Components drawn over it keep the defaults.
- Stacking follows creation order. Something that must stay on top calls `MoveToFront` after everything else is built, and only while it and its parents are shown: the client never draws a component moved to the front while hidden. The fake client prints a warning for it.
- The client sends `ONRELEASE` as soon as the cursor leaves the pressed component, with the button still held. A drag moves the pressed component, or a layer holding it, with the cursor until the release.
- `Mouse.GetX` and `GetY` are physical pixels, twice the UI units on a Retina display. Code that mixes the mouse with component positions converts with the ratio of the mouse to `xyGlobal` plus the hook position, taken in a press or hover hook.
- `pairs` order is undefined. Components built in a `pairs` loop stack differently on each load, so build from an ordered list whenever stacking or layout order shows.

## Persistence

- PersistentDB returns numbers as floats. Convert with `math.tointeger` before using one as a list index or comparing it with an integer.
- Validate saved data on load. Drop wrong types and unknown keys and fill defaults, so an old or corrupted record cannot raise.
- Renaming a key or changing its shape needs a migration, or it silently drops user settings. The manifest `name` keys the store, so renaming the plugin loses everything.

## Lua 5.4

- `/` always returns a float, so `tostring(6 / 2)` is "3.0". Show players whole numbers with `//`, `math.floor` or `%d`.
- Bit operators need integer representations. A float from a var raises "number has no integer representation".
- `#t` on a list with holes is undefined, and `ipairs` stops at the first nil.
- Any new global goes in `.luacheckrc`. An assignment missing `local` creates a global shared by every module.
- Concatenating nil raises. Wrap client values in `tostring` before building strings from them.
