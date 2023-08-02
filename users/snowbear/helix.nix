{ pkgs, ... }:
{
  packages = [
    pkgs.helix
    pkgs.nil
    pkgs.python310Packages.python-lsp-server

    pkgs.black # python formatter
  ];

  languages = builtins.readFile ./languages.toml;
  config = builtins.readFile ./helixconfig.toml;
}
