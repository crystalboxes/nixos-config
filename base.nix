{ config, pkgs, lib , ... }:
{
    boot.kernelPackages = pkgs.linuxPackages_latest;
    nix = {
      package = pkgs.nixUnstable;
      extraOptions = ''
        experimental-features = nix-command flakes
        keep-outputs = true
        keep-derivations = true
      '';
    };
    
    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;

    boot.loader.systemd-boot.consoleMode = "0";
    networking.hostName = "dev";
    time.timeZone = "Europe/Kyiv";
    
  # Don't require password for sudo
    security.sudo.wheelNeedsPassword = false;

    # Virtualization settings
    virtualisation.docker.enable = true;

    
    # setup windowing environment
    services.xserver = {
      enable = true;
      layout = "us";
      dpi = 220;

      desktopManager = {
        xterm.enable = false;
        wallpaper.mode = "fill";
      };

      displayManager = {
        defaultSession = "none+i3";
        lightdm.enable = true;

        # AARCH64: For now, on Apple Silicon, we must manually set the
        # display resolution. This is a known issue with VMware Fusion.
        sessionCommands = ''
          ${pkgs.xorg.xset}/bin/xset r rate 200 40
        '';
      };

      windowManager = {
        i3.enable = true;
      };
    };


    # Select internationalisation properties.
    i18n.defaultLocale = "en_US.UTF-8";
    users.mutableUsers = false;

    fonts = {
      fontDir.enable = true;

      fonts = [
        pkgs.fira-code
      ];
    };

     environment.systemPackages = with pkgs; [
      gnumake
      killall
      rxvt_unicode
      xclip

      (writeShellScriptBin "xrandr-auto" ''
        xrandr --output Virtual-1 --auto
      '')
      # For getting clipboard to work in wmvare
      gtkmm3
    ];

    
  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  services.openssh.settings.PasswordAuthentication = true;
  services.openssh.settings.PermitRootLogin = "no";
  
  networking.firewall.enable = false;
  system.stateVersion = "23.05";

}
