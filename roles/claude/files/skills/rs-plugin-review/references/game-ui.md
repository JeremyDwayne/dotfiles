# Game UI

Read during step 5 for any change a player sees or touches. The picked mock sets the look; read it when the plan links one. These are the behaviours a static mock never shows.

## Accessibility first

- Colour vision: no signal relies on red against green, green against brown, blue against purple, or light green against yellow alone. Pair the colour with text, position, shape, line style or an icon.
- Contrast: light on very dark or dark on light, never mid tones on mid tones. Text over the game world gets a shadow or a dark backing. Text over a bar fill changes colour once the fill passes under it.
- Size: nothing smaller than `NOTOSANS_10` or `NOTOSANS_BOLD_10`. Numbers read mid-fight use a 13 pt font or larger. The API skill's `references/observed/fonts.md` lists the ids.

## Over the game world

- HUD elements let clicks through to the world unless they are controls. A HUD that swallows clicks makes the player miss a walk or an attack. Hover hooks still fire on components with `clickthrough = true`.
- Alpha 0 is not hidden. A transparent game interface still takes the clicks it took before; report it as a click zone change.
- Positions anchor to fractions of the game window through `SetPos` anchors, so a resize keeps elements on screen. Anything movable has a reset to defaults.
- The HUD updates on the tick and holds still between ticks. No flashes, pulses or tweens.

## Input

- Every drag ends. The client sends `ONRELEASE` as soon as the cursor leaves the pressed component, so a drag keeps that component under the cursor. ESC cancels, and closing or hiding the window mid-drag clears the drag state.
- ESC closes the topmost plugin layer first: edit mode before the options window.
- Hooks cannot tell mouse buttons apart, so a right click fires `ONCLICK` too. A destructive action needs a second step, such as a menu row.
- A `KeyDown` handler acts only on its own key and leaves game keys alone.

## Tooltips and popups

- Raised above every element by a `MoveToFront` on its first show, never while hidden, since the client stops drawing a component moved to the front while hidden. Kept on screen: flipped below the icon when there is no room above, clamped at the side edges.
- Hidden on leave, and hidden or updated when the hovered slot empties or changes during a tick.
- One popup open at a time. Opening a page or another popup closes the rest.

## States

- An empty state says what to do, such as "Use an ability to add it here". A pending state says what is pending, such as "Looking up name".
- Player and target elements hide when their data is gone: logged out, no target, or the source interface unloaded. They never show stale values or zeros.
- Numbers follow the game's formats: commas below 10,000, then K and M, rounded down so they never overstate.
