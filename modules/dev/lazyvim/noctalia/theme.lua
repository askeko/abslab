-- Rendered by Noctalia. Tokyo Night provides the highlight definitions, while
-- every palette entry comes from Noctalia or a blend of its colours.
return {
  mode = "{{ mode }}",
  on_colors = function(c)
    local bg = "{{colors.surface.default.hex}}"
    local fg = "{{colors.on_surface.default.hex}}"
    local muted = "{{colors.on_surface_variant.default.hex}}"
    local primary = "{{colors.primary.default.hex}}"
    local secondary = "{{colors.secondary.default.hex}}"
    local tertiary = "{{colors.tertiary.default.hex}}"
    local outline = "{{colors.outline.default.hex}}"
    local terminal = {
      black = "{{colors.terminal_normal_black.default.hex}}",
      red = "{{colors.terminal_normal_red.default.hex}}",
      green = "{{colors.terminal_normal_green.default.hex}}",
      yellow = "{{colors.terminal_normal_yellow.default.hex}}",
      blue = "{{colors.terminal_normal_blue.default.hex}}",
      magenta = "{{colors.terminal_normal_magenta.default.hex}}",
      cyan = "{{colors.terminal_normal_cyan.default.hex}}",
      white = "{{colors.terminal_normal_white.default.hex}}",
      black_bright = "{{colors.terminal_bright_black.default.hex}}",
      red_bright = "{{colors.terminal_bright_red.default.hex}}",
      green_bright = "{{colors.terminal_bright_green.default.hex}}",
      yellow_bright = "{{colors.terminal_bright_yellow.default.hex}}",
      blue_bright = "{{colors.terminal_bright_blue.default.hex}}",
      magenta_bright = "{{colors.terminal_bright_magenta.default.hex}}",
      cyan_bright = "{{colors.terminal_bright_cyan.default.hex}}",
      white_bright = "{{colors.terminal_bright_white.default.hex}}",
    }
    local util = require("tokyonight.util")
    local function tint(color, amount)
      return util.blend(color, amount, bg)
    end

    -- Derive surfaces from the actual background: builtin and wallpaper themes
    -- do not necessarily supply the same Material surface-container roles.
    c.bg, c.fg = bg, fg
    c.bg_dark, c.bg_dark1 = tint(fg, 0.04), tint(fg, 0.08)
    c.bg_highlight, c.bg_visual = tint(primary, 0.12), tint(primary, 0.22)
    c.bg_search = tint(primary, 0.3)
    c.bg_popup, c.bg_statusline = c.bg_dark, c.bg_dark
    c.bg_sidebar, c.bg_float = c.bg_dark, c.bg_dark
    c.fg_dark, c.fg_sidebar, c.fg_float = muted, muted, fg
    c.fg_gutter, c.comment = outline, muted
    c.dark3, c.dark5 = outline, muted
    c.black, c.terminal_black = bg, terminal.black_bright
    c.border, c.border_highlight = outline, primary

    c.blue, c.blue0 = terminal.blue, primary
    c.blue1, c.blue2 = terminal.cyan, terminal.blue_bright
    c.blue5, c.blue6, c.blue7 = terminal.cyan_bright, terminal.cyan_bright, tint(primary, 0.3)
    c.cyan, c.teal = terminal.cyan, terminal.cyan
    c.green, c.green1, c.green2 = terminal.green, terminal.green_bright, terminal.green
    c.magenta, c.magenta2, c.purple = terminal.magenta, terminal.magenta_bright, secondary
    c.orange = util.blend(terminal.red, 0.5, terminal.yellow)
    c.red, c.red1, c.yellow = terminal.red, terminal.red_bright, terminal.yellow
    c.error = "{{colors.error.default.hex}}"
    c.warning, c.info, c.hint, c.todo = terminal.yellow, primary, tertiary, primary

    c.git = { add = terminal.green, change = terminal.blue, delete = terminal.red, ignore = muted }
    c.diff = {
      add = tint(terminal.green, 0.15),
      delete = tint(terminal.red, 0.15),
      change = tint(primary, 0.12),
      text = tint(primary, 0.25),
    }
    c.rainbow = { terminal.blue, terminal.yellow, terminal.green, terminal.cyan,
      terminal.magenta, secondary, c.orange, terminal.red }
    c.terminal = terminal
    -- Plugin highlights also use these blend helpers after on_colors runs.
    util.bg, util.fg = bg, fg
  end,
}
