{ pkgs, ... }:

{
  # Since we're using fish as our shell
  programs.zsh.enable = true;

  users.users.snowbear = {
    isNormalUser = true;
    home = "/home/snowbear";
    extraGroups = [ "docker" "wheel" ];
    shell = pkgs.zsh;
    hashedPassword = "$6$mWY0NrRF8dI4mpE2$UfIr7b1PwMHq40fpgoEAXMz/ZyCJCGBFaQsNp5XF6vphPWxmwAz.Ema1yhgnULmIHqLJYtEdlAIRJDEQKExwa1";
  };

}
