{ config, lib, ... }:
let
  samsung = "desc:Samsung Electric Company Odyssey G85SB";
  acer = "desc:Acer Technologies XB271HU";
in
{
  configurations.nixos.lazarus.module = {
    # Monitors match by description prefix (make + model, see `hyprctl
    # monitors`), so the serial number doesn't matter. The Acer is rotated to
    # portrait on the Samsung's left.
    home-manager.users.${config.flake.meta.owner.username}.wayland.windowManager.hyprland = {
      settings = {
        monitor = [
          {
            output = samsung;
            mode = "3440x1440@174.96";
            position = "0x0";
            scale = 1;
          }
          {
            output = acer;
            mode = "2560x1440@165";
            position = "-1440x-450";
            scale = 1;
            transform = 1; # 90°
          }
        ];

        # Workspaces 1-5 on the Samsung, 6-10 on the Acer.
        workspace_rule = lib.genList (
          i:
          let
            ws = i + 1;
          in
          {
            workspace = toString ws;
            persistent = true;
            default_name = "󰣇";
            monitor = if ws <= 5 then samsung else acer;
            default = ws == 1 || ws == 6;
          }
        ) 10;
      };

      extraConfig = ''
        -- Start on the Samsung when it's connected.
        hl.on("hyprland.start", function()
            for _, mon in ipairs(hl.get_monitors()) do
                if mon.description:find("${lib.removePrefix "desc:" samsung}", 1, true) == 1 then
                    hl.dispatch(hl.dsp.focus({ monitor = mon }))
                end
            end
        end)
      '';
    };
  };
}
