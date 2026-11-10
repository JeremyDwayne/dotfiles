-- Fake RS3 client that loads a plugin's main.lua and measures what each event costs: component writes,
-- client reads, Lua allocation, log lines and PersistentDB writes. After PluginShutdown it lists plugin
-- components left on the plugin layer and game component properties left changed. A PrettyUI stand-in
-- covers plugins that depend on it.
--
-- Usage: lua5.4 fake_client.lua <plugin dir> [scenario.lua]
--
-- Without a scenario the plugin runs three server ticks, a logic tick and a frame against an empty game.
-- A scenario file returns function(fake) and drives the run itself. Set saved data in fake.db and game
-- state before fake.load(); fake.tick loads main.lua if needed.
--
--   return function(fake)
--     fake.var("VarPlayer", "LIFEPOINTS", 9900)
--     fake.component({ 1430, 9, 0, 8 }, { content = "9,900/9,900" })
--     fake.load()
--     fake.varChange("VarPlayer", "COMBATV2_COOLDOWN_MAGIC_SUNSHINE_START", 0, 1000)
--     fake.tick("first")             -- draws everything once
--     fake.tick("steady")            -- nothing changed, so this should report 0 writes
--     fake.hook(fake.find(function(c, d) return d.hooks.ONMOUSEOVER end), "ONMOUSEOVER", 0, 0, "hover")
--     fake.logic("Logic, idle")
--     fake.ribbon()                  -- the client builds the ribbon's content layer
--     fake.button("Options")         -- presses a PrettyUI button, such as the one the ribbon shows
--     fake.press("Done")             -- clicks the plugin's own hit area under a label
--     fake.checkbox("hideCastBar")   -- toggles a choice on the shown PrettyUI checkbox
--     fake.confirm("cancel")         -- answers an open PrettyUI confirm
--     fake.key("ESCAPE")
--     fake.shutdown()
--   end
--
-- What it models and what it does not:
-- - Writes are property assignments and Set*, Add*, Clear, Move*, Align*, Destroy, UpdateLayout and Remove*
--   calls on any component. Client reads are game component property reads and method calls, var reads,
--   GetComponent, Inventory.Find and config FromID. Reads inside scenario-supplied proxies, such as an
--   inventory's GetSlots, are not counted.
-- - Allocation is everything Lua allocates inside a measurement, the scenario's own code included, so build
--   payloads and tables before calling fake.measure. The helpers below reuse prebuilt payloads.
-- - SetPos keeps x and y as given and stores the anchors beside them. Resolved screen positions, layout and
--   rendering are not modelled, and nothing fires ONMOUSELEAVE when a hovered component hides.
-- - Config and param values are auto tables: any config.<Type>.<Name> or id path is a cached table whose
--   tostring is its path, so equality works. Put structs in fake.configs.Struct[id] for FromID.

local pluginDir, scenarioPath = arg[1], arg[2]
assert(pluginDir, "usage: lua5.4 fake_client.lua <plugin dir> [scenario.lua]")

local stats
local function resetStats()
  stats = { writes = 0, reads = 0, logs = 0, db = 0, byField = {} }
end
resetStats()

local perComponent = setmetatable({}, { __mode = "k" })
local function wrote(field, c)
  stats.writes = stats.writes + 1
  stats.byField[field] = (stats.byField[field] or 0) + 1
  if c ~= nil then
    local counts = perComponent[c]
    if counts == nil then
      counts = {}
      perComponent[c] = counts
    end
    counts[field] = (counts[field] or 0) + 1
  end
end

-- Values for any enum or id path, such as id.Font.MUSEO_SANS_13PT_BOLD or GameKey.ESCAPE: one cached
-- table per path, callable as a no-op, so equality and table keys behave.
local autoCache = {}
local function auto(path)
  local cached = autoCache[path]
  if cached then return cached end
  cached = setmetatable({}, {
    __index = function(_, k) return auto(path .. "." .. tostring(k)) end,
    __call = function() return nil end,
    __tostring = function() return path end,
  })
  autoCache[path] = cached
  return cached
end

-- Components -------------------------------------------------------------------------------------------

local dataOf = setmetatable({}, { __mode = "k" })
local created, gameComponents = {}, {}
local WRITE_METHOD = { "^Set", "^Add", "^Clear$", "^Move", "^Align", "^Destroy$", "^UpdateLayout$", "^Remove" }

local function isWrite(name)
  for _, pattern in ipairs(WRITE_METHOD) do
    if name:match(pattern) then return true end
  end
  return false
end

-- Game components keep each property's value from before the plugin first wrote it, boxed so nil counts.
local function remember(data, field)
  if data.before ~= nil and data.before[field] == nil then data.before[field] = { value = data[field] } end
end

local methods = {}
local function method(name)
  if methods[name] then return methods[name] end
  local m
  if name == "Subscribe" then
    -- Subscribe(hook, fn) or Subscribe(hook, id, fn); every listener for a hook is kept.
    m = function(self, hook, a, b)
      local hookName = tostring(hook):match("[^.]+$")
      local listeners = dataOf[self].hooks[hookName] or {}
      if b ~= nil then listeners[a] = b else listeners[""] = a end
      dataOf[self].hooks[hookName] = listeners
    end
  elseif name == "SetPos" then
    m = function(self, x, y, anchorX, anchorY)
      wrote(name, self)
      local data = dataOf[self]
      remember(data, "x")
      remember(data, "y")
      data.x, data.y, data.anchorX, data.anchorY = x, y, anchorX, anchorY
    end
  elseif name == "SetSize" then
    m = function(self, w, h) wrote(name, self); dataOf[self].width, dataOf[self].height = w, h end
  elseif name == "SetWidth" then
    m = function(self, w) wrote(name, self); dataOf[self].width = w end
  elseif name == "SetHeight" then
    m = function(self, h) wrote(name, self); dataOf[self].height = h end
  elseif name == "MoveToFront" then
    -- The client stops drawing a component moved to the front while it or a parent is hidden.
    m = function(self)
      wrote(name, self)
      local c = self
      while c ~= nil and dataOf[c] ~= nil do
        if dataOf[c].hidden then
          dataOf[self].undrawn = true
          print("WARNING MoveToFront while hidden, the client will never draw it: " .. tostring(dataOf[self].source))
          return
        end
        c = dataOf[c].parent
      end
    end
  elseif name == "Destroy" then
    m = function(self)
      wrote(name, self)
      local function destroy(c)
        dataOf[c].destroyed = true
        for _, child in ipairs(dataOf[c].children) do destroy(child) end
      end
      destroy(self)
    end
  elseif name == "IterateDynamicComponents" then
    m = function(self, fn)
      stats.reads = stats.reads + 1
      for _, child in ipairs(dataOf[self].children) do
        if fn(child) then break end
      end
    end
  elseif isWrite(name) then
    m = function(self) wrote(name, self) end
  else
    m = function() stats.reads = stats.reads + 1 end
  end
  methods[name] = m
  return m
end

local componentMeta = {
  -- PascalCase keys are methods; lowercase keys are properties, nil when never set.
  __index = function(c, k)
    local data = dataOf[c]
    if type(k) == "string" and k:match("^%u") then return method(k) end
    if data.before ~= nil then stats.reads = stats.reads + 1 end
    return data[k]
  end,
  __newindex = function(c, k, v)
    wrote(k, c)
    local data = dataOf[c]
    remember(data, k)
    data[k] = v
  end,
}

-- The plugin lines that led to the constructor call, innermost first, such as
-- "src/draw.lua:88 < src/view.lua:155", for finding a component by the code that built it.
local function callerSource()
  local frames = {}
  for level = 3, 12 do
    local info = debug.getinfo(level, "Sl")
    if info == nil or #frames == 3 then break end
    local file = info.source:sub(2)
    if info.currentline > 0 and not file:match("fake_client%.lua$") then
      if file:sub(1, #pluginDir + 1) == pluginDir .. "/" then file = file:sub(#pluginDir + 2) end
      frames[#frames + 1] = file .. ":" .. info.currentline
    end
  end
  return table.concat(frames, " < ")
end

local function newComponent(kind, parent, fields)
  local c = setmetatable({}, componentMeta)
  local data = { kind = kind, parent = parent, hooks = {}, children = {}, x = 0, y = 0, width = 0, height = 0,
    alpha = 1, hidden = false }
  for k, v in pairs(fields or {}) do data[k] = v end
  dataOf[c] = data
  if parent ~= nil and dataOf[parent] then table.insert(dataOf[parent].children, c) end
  return c
end

local root = newComponent("pluginLayer")

-- Globals ----------------------------------------------------------------------------------------------

local handlers, vars, db, logs = {}, {}, {}, {}
local fake = {
  player = { available = true, entity = { displayName = "Player" } },
  mouse = { x = 0, y = 0 },
  inventories = {}, -- [inventory id] = an Inventory proxy, such as { GetSlots = function() return {} end }
  configs = {},     -- [config type name][id] = what config.<Type>.FromID(id) returns
  db = db,
  logs = logs,
  root = root,
  verbose = false,  -- true prints every log line as it happens
  quiet = false,    -- true stops measurements printing, for running many ticks
}

_G.log = function(...)
  stats.logs = stats.logs + 1
  local parts = {}
  for i = 1, select("#", ...) do parts[i] = tostring(select(i, ...)) end
  logs[#logs + 1] = table.concat(parts, " ")
  if fake.verbose then print("[log]", logs[#logs]) end
end

_G.Event = setmetatable({}, { __index = function(t, name)
  local event = {
    Subscribe = function(ref, fn)
      assert(type(ref) == "string", "Event." .. name .. ".Subscribe takes a dot call: Subscribe(refName, fn)")
      handlers[name] = handlers[name] or {}
      handlers[name][ref] = fn
    end,
    Unsubscribe = function(ref)
      if handlers[name] then handlers[name][ref] = nil end
    end,
  }
  rawset(t, name, event)
  return event
end })

local function domain(name)
  vars[name] = vars[name] or {}
  return setmetatable({}, { __index = function(_, varName)
    stats.reads = stats.reads + 1
    return vars[name][varName]
  end })
end
_G.var = setmetatable({}, { __index = function(t, name)
  local d = domain(name)
  rawset(t, name, d)
  return d
end })

_G.PersistentDB = setmetatable({}, { __index = function(_, name)
  if name:match("^Set") then
    return function(_, key, value) stats.db = stats.db + 1; db[key] = value; return true end
  elseif name == "Delete" then
    return function(_, key) stats.db = stats.db + 1; db[key] = nil; return true end
  elseif name:match("^CheckExists") then
    return function(_, key) return db[key] ~= nil end
  end
  return function(_, key) return db[key] end
end })

_G.Player = {
  IsAvailable = function() return fake.player.available end,
  GetEntity = function() return fake.player.available and fake.player.entity or nil end,
}
_G.Mouse = { GetX = function() return fake.mouse.x end, GetY = function() return fake.mouse.y end }
_G.Inventory = { Find = function(invID) stats.reads = stats.reads + 1; return fake.inventories[invID] end }
_G.config = setmetatable({}, { __index = function(t, typeName)
  local configType = setmetatable({
    FromID = function(configID)
      stats.reads = stats.reads + 1
      local byID = fake.configs[typeName]
      return byID and byID[configID]
    end,
  }, { __index = function(_, k) return auto("config." .. typeName .. "." .. tostring(k)) end })
  rawset(t, typeName, configType)
  return configType
end })

-- "interface:static" or "interface:static:category:dynamic", built without a table so lookups allocate
-- nothing that would count against the plugin.
local function componentKey(interfaceID, staticID, categoryID, dynamicID)
  local key = tostring(interfaceID) .. ":" .. tostring(staticID)
  if categoryID == nil then return key end
  return key .. ":" .. tostring(categoryID) .. ":" .. tostring(dynamicID)
end

-- The plugin layer and the game area both span the window, so both resolve to the one fake root.
local PLUGIN_LAYER = auto("id.Component.TOPLEVEL_V2__PLUGIN_BUILD_LAYER_TOP")
local GAME_AREA = auto("id.Component.TOPLEVEL_V2__GAME_AREA")
_G.ui = setmetatable({
  Interfaces = {
    GetComponent = function(_, interfaceID, staticID, categoryID, dynamicID)
      if interfaceID == PLUGIN_LAYER or interfaceID == GAME_AREA then return root end
      stats.reads = stats.reads + 1
      return gameComponents[componentKey(interfaceID, staticID, categoryID, dynamicID)]
    end,
  },
}, { __index = function(t, name)
  -- ui.<Type>.new(parent) builds a component; any other ui.<Name>.<Value> is an enum.
  local entry = setmetatable({
    new = function(parent)
      local c = newComponent(name, parent)
      dataOf[c].source = callerSource()
      created[#created + 1] = c
      return c
    end,
  }, { __index = function(_, k) return auto("ui." .. name .. "." .. tostring(k)) end })
  rawset(t, name, entry)
  return entry
end })

-- Every other capitalised global (id, GameKey, SkillType, Chat, ...) is an auto value.
setmetatable(_G, { __index = function(_, name)
  if type(name) == "string" and name:match("^%u") or name == "id" then return auto(name) end
end })

-- PrettyUI ---------------------------------------------------------------------------------------------

-- Stand-in for the PrettyUI dependency, built from fake layers so its writes count like the real library's.
-- Window, Tabs, FancyButton, CheckboxButton and Confirm carry the methods plugins call: a window shows,
-- closes and destroys and hosts AddTabs and AddFancyButton; tabs activate a page and hand out pages with a
-- content layer; a checkbox ticks its choices through fake.checkbox; a confirm answers through fake.confirm.
-- Each keeps its options and its root layer.
local pretty = { made = {} }
_G.prettyui = pretty

local function make(kind, parent, options)
  local c = { kind = kind, options = options or {}, root = ui.Layer.new(parent) }
  pretty.made[#pretty.made + 1] = c
  return c
end

local function host(c)
  c.content = ui.Layer.new(c.root)
  function c.AddTabs(self, values, options) return pretty.Tabs.new(self.content, values, options) end
  function c.AddFancyButton(self, text, action, options)
    return pretty.FancyButton.new(self.content, text, action, options)
  end
  return c
end

pretty.Window = {}
function pretty.Window.new(parent, options)
  local w = host(make("Window", parent, options))
  w.root:MoveToFront()
  function w.Show(self) self.root.hidden = false; self.root:MoveToFront() end
  -- PrettyUI's Close runs onClose, then destroys a window made with destroyOnClose and hides any other.
  function w.Close(self)
    if self.options.onClose then self.options.onClose(self) end
    if self.options.destroyOnClose then self:Destroy() else self.root.hidden = true end
  end
  function w.Destroy(self) self.destroyed = true; self.root:Destroy() end
  return w
end

pretty.Tabs = {}
local function activate(tabs, index, notify)
  local previous = tabs.active
  tabs.active = index
  for i, page in ipairs(tabs.pages) do page.root.hidden = i ~= index end
  if notify ~= false and previous ~= index and tabs.options.onChange then
    tabs.options.onChange(tabs, index, tabs.values[index].text, tabs.pages[index])
  end
end
function pretty.Tabs.new(parent, values, options)
  local tabs = make("Tabs", parent, options)
  tabs.values, tabs.pages = values, {}
  tabs.content = ui.Layer.new(tabs.root)
  for i = 1, #values do tabs.pages[i] = host({ root = ui.Layer.new(tabs.content) }) end
  function tabs.SetActive(self, index, notify) activate(self, index, notify) end
  function tabs.GetActiveIndex(self) return self.active end
  function tabs.GetPage(self, index) return self.pages[index] end
  activate(tabs, tabs.options.activeIndex or 1, false)
  return tabs
end

pretty.FancyButton = {}
function pretty.FancyButton.getSize(text) return math.max(100, #text * 9 + 40), 27 end
function pretty.FancyButton.new(parent, text, action, options)
  local b = make("FancyButton", parent, options)
  b.text, b.action = text, action
  function b.SetText(self, t) self.text = t end
  return b
end

pretty.CheckboxButton = {}
-- Ticks each choice in options.selectedValues or marked selected. SetSelected runs onChange(box, ticked
-- values, value, selected) on a change unless notify is false, as PrettyUI's does.
function pretty.CheckboxButton.new(parent, choices, options)
  local box = make("CheckboxButton", parent, options)
  box.choices, box.ticked = choices, {}
  for _, choice in ipairs(choices) do
    for _, value in ipairs(box.options.selectedValues or {}) do
      box.ticked[choice.value] = box.ticked[choice.value] or value == choice.value
    end
    box.ticked[choice.value] = box.ticked[choice.value] or choice.selected == true
  end
  function box.SetSelected(self, value, selected, notify)
    if self.ticked[value] == selected then return true end
    self.ticked[value] = selected
    if notify ~= false and self.options.onChange then
      local values = {}
      for _, choice in ipairs(self.choices) do
        if self.ticked[choice.value] then values[#values + 1] = choice.value end
      end
      self.options.onChange(self, values, value, selected)
    end
    return true
  end
  function box.IsSelected(self, value) return self.ticked[value] == true end
  return box
end

pretty.Confirm = {}
function pretty.Confirm.new(parent, options)
  local dialog = make("Confirm", parent, options)
  function dialog.Destroy(self) self.destroyed = true; self.root:Destroy() end
  return dialog
end

-- The first live PrettyUI component of kind, such as "Window", whose root is shown and that match accepts.
function fake.pretty(kind, match)
  for _, c in ipairs(pretty.made) do
    if c.kind == kind and not c.destroyed and fake.shown(c.root) and (match == nil or match(c)) then
      return c
    end
  end
end

-- Presses the shown FancyButton reading text, as the player would. Measured.
function fake.button(text)
  local b = fake.pretty("FancyButton", function(c) return c.text == text end)
  assert(b, "no shown PrettyUI button " .. text)
  return fake.measure("button " .. text, function() b.action(b) end)
end

-- Toggles the choice of value, or the first choice, on the shown CheckboxButton that match accepts, as the
-- player would. Measured.
function fake.checkbox(value, match)
  local box = fake.pretty("CheckboxButton", match)
  assert(box, "no shown PrettyUI checkbox")
  local choice = value or box.choices[1].value
  return fake.measure("checkbox " .. tostring(choice), function()
    box:SetSelected(choice, not box:IsSelected(choice))
  end)
end

-- Answers the open Confirm with "confirm" or "cancel". Measured.
function fake.confirm(answer)
  local dialog = fake.pretty("Confirm")
  assert(dialog, "no open PrettyUI confirm")
  local fn = answer == "cancel" and dialog.options.onCancel or dialog.options.onConfirm
  return fake.measure("confirm " .. answer, function()
    if fn == nil or fn() ~= false then dialog:Destroy() end
  end)
end

-- Scenario API -----------------------------------------------------------------------------------------

-- Sets var.<domainName>.<name>.value; nil removes the var.
function fake.var(domainName, name, value)
  local _ = var[domainName]
  vars[domainName][name] = value ~= nil and { value = value, configName = name } or nil
end

-- Adds a game component at { interface, static[, category, dynamic] } with fields such as content,
-- spriteID or alpha, and returns it. Pass parent to make it a dynamic child for IterateDynamicComponents.
-- A dynamic component reads its categoryID and dynamicID as the client's do, unless fields set them.
function fake.component(ids, fields, parent)
  local c = newComponent("game", parent, fields)
  local key = componentKey(ids[1], ids[2], ids[3], ids[4])
  gameComponents[key] = c
  local data = dataOf[c]
  data.key, data.before = key, {}
  if ids[3] ~= nil then
    if data.categoryID == nil then data.categoryID = ids[3] end
    if data.dynamicID == nil then data.dynamicID = ids[4] end
  end
  return c
end

-- Raw state of a component: x, y, anchors, width, height, hidden, hooks by name, the source line that built
-- it, and every property written.
function fake.state(c)
  return dataOf[c]
end

-- Plugin components built so far, in creation order.
function fake.created()
  return created
end

-- Writes made so far grouped by the code that built the component and the field, as a sorted list of
-- { source, field, writes, components, repeats }: repeats counts writes past the first to the same field of the
-- same component. Finds load cost and redundant writes.
function fake.writesBySource()
  local rows = {}
  for c, counts in pairs(perComponent) do
    local source = dataOf[c] and dataOf[c].source or "game"
    for field, n in pairs(counts) do
      local key = source .. "\t" .. field
      local row = rows[key]
      if row == nil then
        row = { source = source, field = field, writes = 0, components = 0, repeats = 0 }
        rows[key] = row
      end
      row.writes = row.writes + n
      row.components = row.components + 1
      row.repeats = row.repeats + n - 1
    end
  end
  local list = {}
  for _, row in pairs(rows) do list[#list + 1] = row end
  table.sort(list, function(a, b) return a.writes > b.writes end)
  return list
end

-- Whether c and every parent it has are shown and not destroyed.
function fake.shown(c)
  while c ~= nil and dataOf[c] ~= nil do
    if dataOf[c].hidden or dataOf[c].destroyed then return false end
    c = dataOf[c].parent
  end
  return true
end

-- The first shown plugin component for which predicate(c, state) is true.
function fake.find(predicate)
  for _, c in ipairs(created) do
    if fake.shown(c) and predicate(c, dataOf[c]) then return c end
  end
end

local function report(label)
  if fake.quiet then return end
  local fields = {}
  for field, n in pairs(stats.byField) do fields[#fields + 1] = field .. " " .. n end
  table.sort(fields)
  print(string.format("%-28s %4d writes  %4d client reads  %7.1f KB allocated  %d logs  %d db writes",
    label, stats.writes, stats.reads, stats.allocated, stats.logs, stats.db))
  if #fields > 0 and stats.writes > 0 then print("    writes by field: " .. table.concat(fields, ", ")) end
end

-- Runs fn and prints what it cost under label. Returns the stats.
function fake.measure(label, fn)
  collectgarbage("collect")
  collectgarbage("stop")
  resetStats()
  local before = collectgarbage("count")
  fn()
  stats.allocated = collectgarbage("count") - before
  collectgarbage("restart")
  report(label)
  return stats
end

-- Calls every handler subscribed to Event.<name> with payload, unmeasured.
function fake.fire(name, payload)
  for _, fn in pairs(handlers[name] or {}) do fn(payload) end
end

local loaded = false

-- Runs main.lua, measured, and prints the subscriptions it made.
function fake.load()
  loaded = true
  package.path = pluginDir .. "/?.lua;" .. package.path
  fake.measure("load main.lua", function() dofile(pluginDir .. "/main.lua") end)
  if not fake.quiet then print("subscriptions: " .. table.concat(fake.subscriptions(), " ")) end
end

-- One server tick: Event.ServerLogic, measured.
function fake.tick(label)
  if not loaded then fake.load() end
  return fake.measure(label or "ServerLogic", function() fake.fire("ServerLogic") end)
end

-- n server ticks, unmeasured, such as to let a background scan finish.
function fake.ticks(n)
  for _ = 1, n do fake.fire("ServerLogic") end
end

local logicPayload = { logicTick = 1 }

-- One Event.Logic tick at the current fake.mouse position, measured.
function fake.logic(label)
  return fake.measure(label or "Logic", function() fake.fire("Logic", logicPayload) end)
end

-- Event.KeyDown for GameKey.<name>, measured.
function fake.key(name, label)
  local payload = { gameKey = auto("GameKey." .. name) }
  return fake.measure(label or ("KeyDown " .. name), function() fake.fire("KeyDown", payload) end)
end

-- Sets a var and fires Event.VarTransmit for the change, as the client does, unmeasured.
function fake.varChange(domainName, name, old, new)
  fake.var(domainName, name, new)
  fake.fire("VarTransmit", { var = { configName = name }, oldValue = old, newValue = new })
end

local ribbon = nil

-- Builds the ribbon's content layer as the client does each time it opens: a client-owned layer, emptied,
-- then passed to Event.ContentLayerReady. Measured; returns the layer.
function fake.ribbon(label)
  ribbon = ribbon or newComponent("contentLayer")
  dataOf[ribbon].children = {}
  local payload = { component = ribbon }
  fake.measure(label or "ContentLayerReady", function() fake.fire("ContentLayerReady", payload) end)
  return ribbon
end

-- Calls hook, such as "ONCLICK", on a shown plugin component as the client would, measured. Pass x and y,
-- relative to the component, for click hooks.
function fake.hook(c, hook, x, y, label)
  assert(fake.shown(c), "hooks only fire on shown components: " .. tostring(dataOf[c].source))
  local listeners = dataOf[c].hooks[hook]
  assert(listeners, "component has no " .. hook .. " hook: " .. tostring(dataOf[c].source))
  return fake.measure(label or hook, function()
    for _, fn in pairs(listeners) do fn(c, x or 0, y or 0) end
  end)
end

-- Clicks the last shown ONCLICK component under the shown text reading label, as a click passes through a
-- label to the hit area below it. Measured.
function fake.press(label)
  local text = fake.find(function(_, d) return d.content == label end)
  assert(text, "no shown label " .. label)
  local t, hit = dataOf[text], nil
  for _, c in ipairs(created) do
    local d = dataOf[c]
    if c ~= text and d.parent == t.parent and d.hooks.ONCLICK and fake.shown(c)
      and t.x >= d.x and t.x < d.x + d.width and t.y >= d.y and t.y < d.y + d.height then hit = c end
  end
  assert(hit, "nothing to click under " .. label)
  return fake.hook(hit, "ONCLICK", 0, 0, "press " .. label)
end

-- Runs PluginShutdown, then lists plugin components still on the plugin layer and every game component
-- property the plugin wrote that no longer holds its value from before the first write.
function fake.shutdown()
  if type(rawget(_G, "PluginShutdown")) == "function" then PluginShutdown() end
  local left = 0
  for _, child in ipairs(dataOf[root].children) do
    if not dataOf[child].destroyed then left = left + 1 end
  end
  print(string.format("after PluginShutdown: %d of %d plugin layer children not destroyed", left,
    #dataOf[root].children))
  local changed = {}
  for key, c in pairs(gameComponents) do
    for field, box in pairs(dataOf[c].before) do
      if dataOf[c][field] ~= box.value then
        changed[#changed + 1] = string.format("    game component %s left with %s = %s (was %s)", key, field,
          tostring(dataOf[c][field]), tostring(box.value))
      end
    end
  end
  table.sort(changed)
  print(string.format("after PluginShutdown: %d game component properties left changed", #changed))
  for _, line in ipairs(changed) do print(line) end
end

-- Subscribed handlers by event, such as "ServerLogic[refresh]", for mapping hot paths.
function fake.subscriptions()
  local out = {}
  for name, refs in pairs(handlers) do
    local names = {}
    for ref in pairs(refs) do names[#names + 1] = ref end
    table.sort(names)
    out[#out + 1] = name .. "[" .. table.concat(names, ",") .. "]"
  end
  table.sort(out)
  return out
end

-- Run --------------------------------------------------------------------------------------------------

if scenarioPath then
  dofile(scenarioPath)(fake)
else
  fake.load()
  fake.tick("ServerLogic 1")
  fake.tick("ServerLogic 2 (steady)")
  fake.tick("ServerLogic 3 (steady)")
  if handlers.Logic then fake.logic("Logic (idle)") end
  if handlers.Draw then
    local payload = { timeDeltaSecs = 0.016 }
    fake.measure("Draw (idle)", function() fake.fire("Draw", payload) end)
  end
  fake.shutdown()
end
