{ pkgs, ... }:

{
  # https://github.com/nix-community/home-manager/pull/2408
  environment.pathsToLink = [ "/share/fish" ];

  # Since we're using fish as our shell
  programs.fish.enable = true;

  users.users.snowbear = {
    isNormalUser = true;
    home = "/home/snowbear";
    extraGroups = [ "docker" "wheel" ];
    shell = pkgs.fish;
    hashedPassword = "$6$mWY0NrRF8dI4mpE2$UfIr7b1PwMHq40fpgoEAXMz/ZyCJCGBFaQsNp5XF6vphPWxmwAz.Ema1yhgnULmIHqLJYtEdlAIRJDEQKExwa1";
    # openssh.authorizedKeys.keys = [
    #   "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGbTIKIPtrymhvtTvqbU07/e7gyFJqNS4S0xlfrZLOaY mitchellh"
    # ];
  };

  nixpkgs.overlays = import ../../lib/overlays.nix ++ [
    (import ./vim.nix)
  ];
}
