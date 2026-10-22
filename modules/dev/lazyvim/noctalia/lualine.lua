-- lualine theme for the noctalia colourscheme, rendered by Noctalia (abslab,
-- not an upstream template). lualine's auto theme loads it by the
-- colourscheme's name instead of guessing from highlight groups. Mode colours
-- are the theme's terminal colours, laid out like tokyonight's lualine theme.
local c = {
  surface = '{{colors.surface.default.hex}}',
  bar     = '{{colors.surface_container.default.hex}}',
  section = '{{colors.surface_container_high.default.hex}}',
  text    = '{{colors.on_surface_variant.default.hex}}',
  dim     = '{{colors.outline.default.hex}}',
  blue    = '{{colors.terminal_normal_blue.default.hex}}',
  green   = '{{colors.terminal_normal_green.default.hex}}',
  magenta = '{{colors.terminal_normal_magenta.default.hex}}',
  red     = '{{colors.terminal_normal_red.default.hex}}',
  yellow  = '{{colors.terminal_normal_yellow.default.hex}}',
}

local function mode(color)
  return {
    a = { fg = c.surface, bg = color, gui = 'bold' },
    b = { fg = color, bg = c.section },
    c = { fg = c.text, bg = c.bar },
  }
end

return {
  normal = mode(c.blue),
  insert = mode(c.green),
  visual = mode(c.magenta),
  replace = mode(c.red),
  command = mode(c.yellow),
  terminal = mode(c.green),
  inactive = {
    a = { fg = c.dim, bg = c.bar },
    b = { fg = c.dim, bg = c.bar },
    c = { fg = c.dim, bg = c.bar },
  },
}
