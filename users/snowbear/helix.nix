{ pkgs, ... }:
{
  packages = [
    pkgs.helix
    pkgs.nil
    pkgs.pyright

    pkgs.black # python formatter
  ];

  languages = builtins.readFile ./languages.toml;
  config = builtins.readFile ./helixconfig.toml;
}
