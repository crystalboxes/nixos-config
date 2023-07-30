{ pkgs, ... }:
{
  packages = [
    pkgs.helix
    pkgs.pyright
    pkgs.nil
  ];

  languages = builtins.readFile ./languages.toml;
  config = builtins.readFile ./helixconfig.toml;
}
