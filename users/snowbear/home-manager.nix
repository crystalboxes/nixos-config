{ config, lib, pkgs, ... }:

let
  sources = import ../../nix/sources.nix;
  helixImport = import ./helix.nix;
  helix = helixImport { inherit pkgs; };
  fishPlugins = pkgs.writeShellScriptBin "install-kubectl-completion" ''
    # Define the directory and file paths
     FISH_CONFIG_DIR="$HOME/.config/fish"
     COMPLETIONS_DIR="$FISH_CONFIG_DIR/completions"
     REPO_DIR="$FISH_CONFIG_DIR/fish-kubectl-completions"
     COMPLETION_FILE="$COMPLETIONS_DIR/kubectl.fish"

     # Create the completions directory if it doesn't exist
     mkdir -p $COMPLETIONS_DIR

     # Clone the repository if it hasn't been cloned yet
     if [ ! -d "$REPO_DIR" ]; then
       git clone https://github.com/evanlucas/fish-kubectl-completions $REPO_DIR
     else
       echo "Repository already cloned."
     fi

     # Link the completion script if it hasn't been linked yet
     if [ ! -L "$COMPLETION_FILE" ]; then
       ln -s ../fish-kubectl-completions/completions/kubectl.fish $COMPLETION_FILE
     else
       echo "Completion file already linked."
     fi
  '';

  isDarwin = pkgs.stdenv.isDarwin;
  isLinux = pkgs.stdenv.isLinux;

  # For our MANPAGER env var
  # https://github.com/sharkdp/bat/issues/1145
  manpager = (pkgs.writeShellScriptBin "manpager" (if isDarwin then ''
    sh -c 'col -bx | bat -l man -p'
  '' else ''
    cat "$1" | col -bx | bat --language man --style plain
  ''));

  pragmatafont = pkgs.stdenvNoCC.mkDerivation {
    name = "pragmata-font";
    dontConfigue = true;
    src = ./fonts;
    installPhase = ''
      mkdir -p $out/share/fonts
      cp -R $src/ $out/share/fonts/
    '';
    meta = { description = "The Pragmata Pro Font derivation."; };
  };

in {
  # Home-manager 22.11 requires this be set. We never set it so we have
  # to use the old state version.
  home.stateVersion = "18.09";

  xdg.enable = true;

  #---------------------------------------------------------------------
  # Packages
  #---------------------------------------------------------------------

  # Packages I always want installed. Most packages I install using
  # per-project flakes sourced with direnv and nix-shell, so this is
  # not a huge list.
  home.packages = [
    pkgs.bat
    pkgs.fd
    pkgs.fzf
    pkgs.htop
    pkgs.jq
    pkgs.ripgrep
    pkgs.tree
    pkgs.watch
    pkgs.gopls
    pkgs.delve
    pkgs.zigpkgs.master
    pkgs.mosh
    pkgs.nodejs_20
    pkgs.nodePackages_latest.typescript-language-server
    pkgs.nodePackages.graphql-language-service-cli
    pkgs.go
    pkgs.bun
    pkgs.poetry
    pkgs.d2

    pkgs.clang-tools

    pkgs.fswatch
    pkgs.watchman
    pkgs.yarn

    pkgs.direnv
    pkgs.k3d
    pkgs.kubectl
    pkgs.air

    pkgs.yaml-language-server
    pkgs.kubernetes-helm
    pkgs.awscli2

    pkgs.terraform
    pkgs.terraform-ls
    pkgs.taplo

    (pkgs.python3.withPackages (p: with p; [ ipython jupyter ]))
  ] ++ (lib.optionals isDarwin [
    # This is automatically setup on Linux
    pkgs.cachix
    pkgs.tailscale
  ]) ++ (lib.optionals isLinux [
    pkgs.chromium
    pkgs.firefox
    pkgs.rofi
    pkgs.zathura

    pragmatafont
  ]) ++ helix.packages;

  #---------------------------------------------------------------------
  # Env vars and dotfiles
  #---------------------------------------------------------------------
  home.activation.installKubectlCompletion =
    lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      ${fishPlugins}/bin/install-kubectl-completion
    '';

  home.sessionVariables = {
    LANG = "en_US.UTF-8";
    LC_CTYPE = "en_US.UTF-8";
    LC_ALL = "en_US.UTF-8";
    EDITOR = "hx";
    PAGER = "less -FirSwX";
    MANPAGER = "${manpager}/bin/manpager";
  };

  home.file.".gdbinit".source = ./gdbinit;
  home.file.".inputrc".source = ./inputrc;

  xdg.configFile."i3/config".text = builtins.readFile ./i3;
  xdg.configFile."helix/languages.toml".text = helix.languages;
  xdg.configFile."helix/config.toml".text = helix.config;
  xdg.configFile."rofi/config.rasi".text = builtins.readFile ./rofi;
  xdg.configFile."devtty/config".text = builtins.readFile ./devtty;

  # Rectangle.app. This has to be imported manually using the app.
  xdg.configFile."rectangle/RectangleConfig.json".text =
    builtins.readFile ./RectangleConfig.json;

  # tree-sitter parsers
  xdg.configFile."nvim/parser/proto.so".source =
    "${pkgs.tree-sitter-proto}/parser";
  xdg.configFile."nvim/queries/proto/folds.scm".source =
    "${sources.tree-sitter-proto}/queries/folds.scm";
  xdg.configFile."nvim/queries/proto/highlights.scm".source =
    "${sources.tree-sitter-proto}/queries/highlights.scm";
  xdg.configFile."nvim/queries/proto/textobjects.scm".source =
    ./textobjects.scm;

  #---------------------------------------------------------------------
  # Programs
  #---------------------------------------------------------------------

  programs.gpg.enable = !isDarwin;

  programs.bash = {
    enable = true;
    shellOptions = [ ];
    historyControl = [ "ignoredups" "ignorespace" ];
    initExtra = builtins.readFile ./bashrc;

    shellAliases = {
      ga = "git add";
      gc = "git commit";
      gco = "git checkout";
      gcp = "git cherry-pick";
      gdiff = "git diff";
      gl = "git prettylog";
      gp = "git push";
      gs = "git status";
      gt = "git tag";
    };
  };

  programs.fish = {
    enable = true;
    interactiveShellInit = lib.strings.concatStrings
      (lib.strings.intersperse "\n" ([
        "source ${sources.theme-clearance}/functions/fish_prompt.fish"
        # "source ${sources.theme-clearance}/functions/fish_right_prompt.fish"
        # "source ${sources.theme-clearance}/functions/fish_title.fish"
        (builtins.readFile ./config.fish)
        "set -g SHELL ${pkgs.fish}/bin/fish"
        "npm set prefix ~/.npm-global"
        "set -Ux fish_user_paths $HOME/.npm-global/bin $fish_user_paths"
      ]));

    shellAliases = {
      ga = "git add";
      gc = "git commit";
      gco = "git checkout";
      gcp = "git cherry-pick";
      gdiff = "git diff";
      gl = "git prettylog";
      gp = "git push";
      gs = "git status";
      gt = "git tag";
    } // (if isLinux then {
      # Two decades of using a Mac has made this such a strong memory
      # that I'm just going to keep it consistent.
      pbcopy = "xclip";
      pbpaste = "xclip -o";
    } else
      { });

    plugins = map (n: {
      name = n;
      src = sources.${n};
    }) [ "fish-fzf" "fish-foreign-env" "theme-bobthefish" ];
  };

  programs.git = {
    enable = true;
    userName = "crystalboxes";
    userEmail = "crystalboxesgfx@gmail.com";
  };

  programs.tmux = {
    enable = true;
    terminal = "xterm-256color";
    shortcut = "l";
    secureSocket = false;

    extraConfig = ''
      set -ga terminal-overrides ",*256col*:Tc"

      set -g @dracula-show-battery false
      set -g @dracula-show-network false
      set -g @dracula-show-weather false

      bind -n C-k send-keys "clear"\; send-keys "Enter"

      run-shell ${sources.tmux-pain-control}/pain_control.tmux
      # run-shell ${sources.tmux-dracula}/dracula.tmux
      set -sg escape-time 0
      setw -g mouse on
    '';
  };

  programs.kitty = {
    enable = true;
    extraConfig = builtins.readFile ./kitty;
  };

  programs.i3status = {
    enable = isLinux;

    general = {
      colors = true;
      color_good = "#8C9440";
      color_bad = "#A54242";
      color_degraded = "#DE935F";
    };

    modules = {
      ipv6.enable = false;
      "wireless _first_".enable = false;
      "battery all".enable = false;
    };
  };

  # programs.neovim = {
  #   enable = true;
  #   package = pkgs.neovim-nightly;

  #   withPython3 = true;
  #   extraPython3Packages = (p:
  #     with p; [
  #       # For nvim-magma
  #       jupyter-client
  #       cairosvg
  #       plotly
  #       #pnglatex
  #       #kaleido
  #     ]);

  #   plugins = with pkgs; [
  #     customVim.vim-cue
  #     customVim.vim-fish
  #     customVim.vim-fugitive
  #     customVim.vim-glsl
  #     customVim.vim-misc
  #     customVim.vim-pgsql
  #     customVim.vim-tla
  #     customVim.vim-zig
  #     customVim.pigeon
  #     customVim.AfterColors

  #     customVim.vim-devicons
  #     customVim.vim-nord
  #     customVim.nvim-comment
  #     customVim.nvim-lspconfig
  #     customVim.nvim-plenary # required for telescope
  #     customVim.nvim-telescope
  #     customVim.nvim-treesitter
  #     customVim.nvim-treesitter-playground
  #     customVim.nvim-treesitter-textobjects
  #     customVim.nvim-magma

  #     vimPlugins.vim-airline
  #     vimPlugins.vim-airline-themes
  #     vimPlugins.vim-eunuch
  #     vimPlugins.vim-gitgutter

  #     vimPlugins.vim-markdown
  #     vimPlugins.vim-nix
  #     vimPlugins.typescript-vim
  #   ];

  #   extraConfig = (import ./vim-config.nix) { inherit sources; };
  # };
  services.gpg-agent = {
    enable = isLinux;
    pinentryFlavor = "tty";

    # cache the keys forever so we don't get asked for a password
    defaultCacheTtl = 31536000;
    maxCacheTtl = 31536000;
  };

  xresources.extraConfig = builtins.readFile ./Xresources;

  # Make cursor not tiny on HiDPI screens
  home.pointerCursor = lib.mkIf isLinux {
    name = "Vanilla-DMZ";
    package = pkgs.vanilla-dmz;
    size = 128;
    x11.enable = true;
  };
}
