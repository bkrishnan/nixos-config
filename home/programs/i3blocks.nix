{ pkgs, ... }:

let
  # Fetch i3blocks-contrib scripts from GitHub
  i3blocks-contrib = pkgs.fetchFromGitHub {
    owner = "vivien";
    repo = "i3blocks-contrib";
    rev = "9d66d81da8d521941a349da26457f4965fd6fcbd";  # Latest as of 2024-02-08
    sha256 = "sha256-iY9y3zLw5rUIHZkA9YLmyTDlgzZtIYAwWgHxaCS1+PI=";
  };

  scriptDir = ".config/i3blocks/scripts";
in
{
  home.file."${scriptDir}/volume" = {
    source = "${i3blocks-contrib}/volume/volume";
    executable = true;
  };

  home.file."${scriptDir}/cpu_usage" = {
    source = "${i3blocks-contrib}/cpu_usage/cpu_usage";
    executable = true;
  };

  home.file."${scriptDir}/memory" = {
    source = "${i3blocks-contrib}/memory/memory";
    executable = true;
  };

  home.file."${scriptDir}/weather_NOAA" = {
    source = "${i3blocks-contrib}/weather_NOAA/weather_NOAA";
    executable = true;
  };

  home.file."${scriptDir}/rofi-calendar" = {
    source = "${i3blocks-contrib}/rofi-calendar/rofi-calendar";
    executable = true;
  };

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

  # Runtime dependencies for the scripts
  home.packages = with pkgs; [
    i3blocks
    alsa-utils   # amixer for volume script
    sysstat      # mpstat for cpu_usage script
    perl         # cpu_usage and weather_NOAA are perl scripts
    perlPackages.JSON  # weather_NOAA needs JSON module
  ];
}
