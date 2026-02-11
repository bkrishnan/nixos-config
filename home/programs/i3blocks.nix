{ pkgs, ... }:

{
  home.file.".config/i3blocks/config".text = ''
    # i3blocks config file
    command=$SCRIPT_DIR/$BLOCK_NAME
    separator_block_width=15
    markup=none

    [volume]
    label= 
    color=#F0B9E7
    interval=1
    signal=10
    STEP=5%

    [weather_NOAA]
    label= 
    color=#F0B9E7
    LAT=40.21
    LON=-77.00
    interval=600

    [cpu_usage]
    label= 
    color=#EBCFA9
    interval=10
    separator=false

    [memory]
    label= 
    color=#EBCFA9
    interval=30

    [rofi-calendar]
    color=#AEB8AE
    DATEFTM=+%a %d %b %Y
    interval=3600
    separator=false

    [time]
    label= 
    color=#AEB8AE
    command=date '+%r'
    interval=1
  '';

  # Add i3blocks to packages
  home.packages = with pkgs; [
    i3blocks
  ];
}
