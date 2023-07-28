{ config, lib, pkgs, ... }:
{
  packages = [
    pkgs.helix
    pkgs.pywright
    pkgs.nil
  ];
}
