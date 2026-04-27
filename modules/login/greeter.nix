#INFO: This just enables the greeter, setup default_session and
# initial_session should be done in desktop environment config
{
  flake.modules.nixos.pc = {
    services.greetd = {
      enable = true;
    };
  };
}
