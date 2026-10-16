{ lib, ... }:
{
  flake.modules.homeManager.gui = {
    programs.noctalia.settings.notification = {
      position = lib.mkDefault "top_right";
      follow_focused_output = lib.mkDefault true;
    };

    services.systembus-notify.enable = true;

    # Hide notifications while the screen is shared (Noctalia's do-not-disturb).
    # Counted, so one share ending doesn't unhide during another; do-not-disturb
    # that was already on before the share stays on afterwards. A reload resets
    # the count, so a stop at zero still unhides: it can't get stuck on.
    wayland.windowManager.hyprland.extraConfig = ''
      local shares = 0
      local dnd_before = false
      hl.on("screenshare.state", function(active)
          if active then
              shares = shares + 1
              if shares == 1 then
                  local p = io.popen(ipc .. "notification-dnd-status 2>/dev/null")
                  dnd_before = p ~= nil and (p:read("l") or "") == "on"
                  if p then
                      p:close()
                  end
                  hl.exec_cmd(ipc .. "notification-dnd-set on")
              end
          else
              shares = math.max(shares - 1, 0)
              if shares == 0 and not dnd_before then
                  hl.exec_cmd(ipc .. "notification-dnd-set off")
              end
          end
      end)
    '';
  };
}
