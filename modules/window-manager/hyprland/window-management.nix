{ lib, ... }:
{
  flake.modules.homeManager.gui.wayland.windowManager.hyprland = {
    # Workspaces 1-10, shown by name in the bar (nf-linux-nixos glyph). Hosts that
    # pin workspaces to monitors replace the whole list.
    settings.workspace_rule = lib.mkDefault (
      lib.genList (i: {
        workspace = toString (i + 1);
        persistent = true;
        default_name = "";
      }) 10
    );

    # Binds match the key's unshifted symbol in the default layout (eu), or the
    # device's own layout where resolve_binds_by_sym is set, hence "+" bound as
    # both `equal` (eu) and `plus` (dk).
    extraConfig = ''
      bind(mod .. " + Q", hl.dsp.window.close(), "Close window")
      bind(mod .. " + F", hl.dsp.window.fullscreen({ mode = "maximized" }), "Maximize column")
      bind(mod .. " + SHIFT + F", hl.dsp.window.fullscreen(), "Fullscreen")
      bind(mod .. " + SHIFT + space", hl.dsp.window.float(), "Toggle floating")

      bind(mod .. " + mouse:272", hl.dsp.window.drag(), "Move window (drag)", { mouse = true })
      bind(mod .. " + mouse:273", hl.dsp.window.resize(), "Resize window (drag)", { mouse = true })

      -- Columns
      bind(mod .. " + R", hl.dsp.layout("colresize +conf"), "Next column width preset")
      bind(mod .. " + equal", hl.dsp.layout("colresize +0.1"), "Column wider")
      bind(mod .. " + plus", hl.dsp.layout("colresize +0.1"), "Column wider")
      bind(mod .. " + minus", hl.dsp.layout("colresize -0.1"), "Column narrower")
      bind(mod .. " + C", hl.dsp.layout("center"), "Centre column")
      bind(mod .. " + comma", hl.dsp.layout("consume"), "Pull next column's window into this column")
      bind(mod .. " + period", hl.dsp.layout("promote"), "Move window out into its own column")
      bind(mod .. " + bracketleft", hl.dsp.layout("consume_or_expel prev"), "Window into/out of column (left)")
      bind(mod .. " + bracketright", hl.dsp.layout("consume_or_expel next"), "Window into/out of column (right)")

      -- niri's "window-or-workspace" moves: within the column first, and past
      -- its top or bottom edge on to the workspace above or below.
      local function column_edge(win, dir)
          local layout = win and win.layout
          local col = layout and layout.column
          if not col then
              return true -- floating, or no window at all
          end
          local i = layout.index_in_column -- 0-based
          if dir == "down" then
              return i >= #col.windows - 1
          end
          return i == 0
      end

      local function workspace_in(dir)
          return dir == "down" and "r+1" or "r-1"
      end

      local function focus_window_or_workspace(dir)
          return function()
              if column_edge(hl.get_active_window(), dir) then
                  hl.dispatch(hl.dsp.focus({ workspace = workspace_in(dir) }))
              else
                  hl.dispatch(hl.dsp.layout("focus " .. (dir == "down" and "d" or "u")))
              end
          end
      end

      local function move_window_or_workspace(dir)
          return function()
              if column_edge(hl.get_active_window(), dir) then
                  hl.dispatch(hl.dsp.window.move({ workspace = workspace_in(dir) }))
              else
                  hl.dispatch(hl.dsp.window.move({ direction = dir }))
              end
          end
      end

      bind(mod .. " + H", hl.dsp.layout("focus l"), "Focus column left")
      bind(mod .. " + L", hl.dsp.layout("focus r"), "Focus column right")
      bind(mod .. " + J", focus_window_or_workspace("down"), "Focus window or workspace below")
      bind(mod .. " + K", focus_window_or_workspace("up"), "Focus window or workspace above")
      bind(mod .. " + SHIFT + H", hl.dsp.layout("swapcol l"), "Move column left")
      bind(mod .. " + SHIFT + L", hl.dsp.layout("swapcol r"), "Move column right")
      bind(mod .. " + SHIFT + J", move_window_or_workspace("down"), "Move window down or to workspace below")
      bind(mod .. " + SHIFT + K", move_window_or_workspace("up"), "Move window up or to workspace above")

      -- Workspaces (per monitor, like niri: r±1 includes the empty one below)
      bind(mod .. " + CTRL + J", hl.dsp.focus({ workspace = "r+1" }), "Focus workspace below")
      bind(mod .. " + CTRL + K", hl.dsp.focus({ workspace = "r-1" }), "Focus workspace above")
      bind(mod .. " + CTRL + SHIFT + J", hl.dsp.window.move({ workspace = "r+1" }), "Move window to workspace below")
      bind(mod .. " + CTRL + SHIFT + K", hl.dsp.window.move({ workspace = "r-1" }), "Move window to workspace above")
      bind(mod .. " + mouse_down", hl.dsp.focus({ workspace = "r+1" }), "Focus workspace below")
      bind(mod .. " + mouse_up", hl.dsp.focus({ workspace = "r-1" }), "Focus workspace above")

      for i = 1, 10 do
          local key = i % 10 -- 10 is on the 0 key
          bind(mod .. " + " .. key, hl.dsp.focus({ workspace = i }), "Focus workspace " .. i)
          bind(mod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }), "Move window to workspace " .. i)
      end

      -- Monitors
      bind(mod .. " + CTRL + H", hl.dsp.focus({ monitor = "l" }), "Focus monitor left")
      bind(mod .. " + CTRL + L", hl.dsp.focus({ monitor = "r" }), "Focus monitor right")
      bind(mod .. " + CTRL + SHIFT + H", hl.dsp.window.move({ monitor = "l" }), "Move window to monitor left")
      bind(mod .. " + CTRL + SHIFT + L", hl.dsp.window.move({ monitor = "r" }), "Move window to monitor right")
    '';
  };
}
