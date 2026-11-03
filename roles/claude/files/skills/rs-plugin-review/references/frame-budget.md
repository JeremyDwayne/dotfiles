# Frame budget

Read during step 5. Each item is a pattern that has cost frame time in a real plugin. The *hot path* is everything reachable from `Event.Draw`, `Event.Logic`, `Event.ServerLogic` or a burst event such as `VarTransmit`.

## Writes

- A *steady tick* makes 0 writes. Every property write and every `Set*`, `Add*`, `Clear`, `Align*` or `Move*` call on the hot path goes through a helper that remembers the last value per component and skips an unchanged one. Hunt raw `c.prop =` and `c:SetPos(` inside update functions.
- Show-all-then-hide defeats the cache. A loop that unhides every part, then hides the ones the model does not need, writes `hidden` twice every tick. Set each part's final visibility once.
- Values that never compare equal defeat the cache too: `Vector4.new(...)`, a fresh table, a float with rounding noise. Cache on plain numbers, strings and booleans.
- A `ui.Canvas` redraw is `Clear()` plus every shape again. Compare the inputs first and redraw only when one changed.
- One `SetPos` or `SetSize` beats `SetX` then `SetY`: each call is a layout pass.
- `ui.<Type>.new` and `Destroy()` belong at load and on user actions. On the hot path, build once and hide the spares.

## Client reads

- Client reads are calls into the game: `GetComponent`, game component properties, vars, config lookups and inventory proxies. Fields of an event payload the handler already received are not. Count reads per tick with the fake client.
- Gate a scan over an interface's components behind one sentinel read, such as whether a panel the plugin hid reads visible again.
- Cache what cannot change in a session: config structs, param handles, names. Cache what changes on an event and clear it in that event's handler. Refresh what changes rarely and has no event, such as keybind labels, on a schedule of ticks rather than every tick.
- No scan over config structs at runtime. Names and ids come from a catalog a tool generates from a game data dump, committed with the plugin.
- A `VarTransmit` handler records the change and returns. It makes no client reads and draws nothing, because combat sends many per tick. The next `ServerLogic` redraws.

## Lua allocation

- `pcall(function() ... end)` builds a closure per call. On the hot path, pass the function and its arguments: `pcall(index, obj, field)`.
- A Draw or Logic handler allocates nothing when idle: no table, concatenation or `string.format` before its early return.
- A ServerLogic handler may build small models. Flag allocation that grows with session length, such as a list appended each tick or a cache never cleared.
- Compare the fake client's KB allocated per tick between base and branch.

## Configuring versus playing

The budget protects play. While the player configures the plugin, such as dragging in an options window or moving elements in an edit mode, a smooth response matters more than cost: follow the cursor every frame on `Event.Draw`, and spend writes freely while something moves. The same handler still costs nothing once the drag ends.

## Idle handlers

- A Draw or Logic handler returns before any client call when it has nothing to do, such as no drag under way. During a drag it also returns while the cursor holds still. `Event.<Name>.Unsubscribe` is unconfirmed in the docs, so an early return beats subscribing on demand.
- The few per-frame reads a plugin keeps exist because the client rebuilds a hidden interface between ticks. Each is commented where it happens and bounded to a few frames after a tick.
- State changes are instant property writes. A pulse, fade, tween or looping animation repaints every frame and is a finding.

## PersistentDB on the hot path

- Write only when a value changed, never per tick or per frame. A drag saves on release, not on each move.
