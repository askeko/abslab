{
  # Through Noctalia, for its OSD. Fn keys also work on the lock screen.
  flake.modules.homeManager.gui.wayland.windowManager.hyprland.extraConfig = ''
    local hw = { locked = true, repeating = true }

    bind(mod .. " + SHIFT + equal", cmd(ipc .. "volume-up"), "Volume up", { repeating = true })
    bind(mod .. " + SHIFT + plus", cmd(ipc .. "volume-up"), "Volume up", { repeating = true })
    bind(mod .. " + SHIFT + minus", cmd(ipc .. "volume-down"), "Volume down", { repeating = true })
    bind(mod .. " + SHIFT + M", cmd(ipc .. "volume-mute"), "Mute output")
    bind("XF86AudioRaiseVolume", cmd(ipc .. "volume-up"), "Volume up", hw)
    bind("XF86AudioLowerVolume", cmd(ipc .. "volume-down"), "Volume down", hw)
    bind("XF86AudioMute", cmd(ipc .. "volume-mute"), "Mute output", { locked = true })

    bind("XF86AudioPlay", cmd(ipc .. "media toggle"), "Play/pause", { locked = true })
    bind("XF86AudioPause", cmd(ipc .. "media toggle"), "Play/pause", { locked = true })
    bind("XF86AudioNext", cmd(ipc .. "media next"), "Next track", { locked = true })
    bind("XF86AudioPrev", cmd(ipc .. "media previous"), "Previous track", { locked = true })
  '';
}
