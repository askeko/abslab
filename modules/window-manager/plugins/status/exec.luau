-- A bar indicator fed by a command, after Waybar's custom modules. `exec` prints
-- the state as one JSON line ({ glyph, text, tooltip, class }); it runs at start,
-- every `interval` seconds and on each line the long-running `watch` command
-- prints. `colors` maps a class to a colour, and classes in `blink` flash.
local exec = noctalia.getConfig("exec")
local watch = noctalia.getConfig("watch")
local interval = noctalia.getConfig("interval")
local colors = noctalia.getConfig("colors")
local blink = {}
for _, class in noctalia.getConfig("blink") do
  blink[class] = true
end

local BLINK_MS = 500

local state = nil
local dimmed = false
local started = false
local running, rerun = false, false
local lastRun = 0

local function colorOf(class)
  local color = colors[class]
  if color == nil then
    return "on_surface" -- the widget's own colour
  end
  if dimmed then
    -- A role takes no alpha here, so a role colour flashes to the idle outline.
    return color:match("^#%x%x%x%x%x%x$") and color .. "40" or "outline"
  end
  return color
end

local function draw()
  if state == nil or state.glyph == nil then
    barWidget.setVisible(false)
    return
  end
  barWidget.setVisible(true)
  barWidget.setGlyph(state.glyph)
  barWidget.setText(state.text or "")
  if state.tooltip then
    barWidget.setTooltip(state.tooltip)
  else
    barWidget.clearTooltip()
  end
  local color = colorOf(state.class)
  barWidget.setGlyphColor(color)
  barWidget.setColor(color)
end

-- Ticks fast only while blinking.
local function schedule()
  if state ~= nil and blink[state.class] then
    noctalia.setUpdateInterval(BLINK_MS)
  elseif interval > 0 then
    noctalia.setUpdateInterval(interval * 1000)
  else
    noctalia.setUpdateInterval(60 * 60 * 1000)
  end
end

-- Lines that arrive while the command runs collapse into one more run.
local function run()
  if running then
    rerun = true
    return
  end
  running = true
  lastRun = os.time()
  noctalia.runAsync(exec, function(result)
    running = false
    local line = result.stdout:match("([^\n]+)\n*$")
    local decoded, err = nil, nil
    if line then
      decoded, err = noctalia.json.decode(line)
    end
    if err then
      noctalia.log("bad output from " .. exec .. ": " .. err)
    end
    state = decoded
    if not (state and blink[state.class]) then
      dimmed = false
    end
    draw()
    schedule()
    if rerun then
      rerun = false
      run()
    end
  end)
end

function update()
  if not started then
    started = true
    run()
    if watch ~= "" then
      -- Restarted if it ever exits.
      noctalia.runStream("while :; do " .. watch .. "; sleep 2; done", run)
    end
  elseif interval > 0 and os.time() - lastRun >= interval then
    run()
  end
  if state ~= nil and blink[state.class] then
    dimmed = not dimmed
    draw()
  end
  schedule()
end

