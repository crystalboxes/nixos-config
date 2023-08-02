{ pkgs, ... }:
{
  packages = [
    pkgs.helix
    pkgs.pyright
    pkgs.nil

    pkgs.black # python formatter
  ];

  languages = builtins.readFile ./languages.toml;
  config = builtins.readFile ./helixconfig.toml;
}
