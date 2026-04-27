{
  configurations.nixos.halflight.module = {
    hardware = {
      sensor.iio.enable = true; # Enables accelerometer (If it doesn't work, newer kernel might be needed
    };
  };
}
