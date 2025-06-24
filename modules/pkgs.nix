{ pkgs, lib, ... }:
{
  nixpkgs = {
    config = {
      allowUnfree = true;
      allowUnfreePredicate = (_: true);
    };
  };

  home.packages =
    with pkgs;
    with pkgs.nodePackages_latest;
    [
      # custom packages
      (pkgs.callPackage ../pkgs/bins { })

      age
      claude-code
      comma
      cosign
      curl
      entr
      gnumake
      go-task
      graphviz
      httpstat
      hyperfine
      jq
      moreutils
      ncdu
      netcat-gnu
      nmap
      nodejs
      onefetch
      p7zip
      scc
      sqlite
      tldr
      unixtools.watch
      unrar
      vegeta
      wget
      yarn

      # Enhanced CLI tools
      bat           # Better cat with syntax highlighting
      eza           # Better ls
      fd            # Better find
      ripgrep       # Better grep (rg)
      fzf           # Fuzzy finder
      lazygit       # Git TUI
      bottom        # Better htop (btm)
      neofetch      # System info
      tree          # Directory tree viewer
      yq-go         # YAML processor
      starship      # Cross-shell prompt
      zellij        # Terminal multiplexer
      
      # File managers & viewers
      ranger        # Terminal file manager
      mcfly         # Better history search
      
      # Text processing
      sd            # Better sed
      
      # Containers & VMs
      podman        # Container runtime
      dive          # Docker image analyzer
      
      # Network & API tools
      httpie        # Better curl
      dig           # DNS lookup
      
      # .NET development
      dotnet-sdk_8
      
      # Python tools
      poetry

      # gke stuff
      (google-cloud-sdk.withExtraComponents [
        google-cloud-sdk.components.gke-gcloud-auth-plugin
      ])
      kubectl
      kubectx
      stern
      argocd

      # From NUR
      nur.repos.caarlos0.glyphs
      nur.repos.caarlos0.gocovsh
      nur.repos.caarlos0.gopls # always latest
      nur.repos.caarlos0.golangci-lint # always latest
      nur.repos.caarlos0.jsonfmt
      nur.repos.caarlos0.svu
      nur.repos.goreleaser.goreleaser-pro

      # treesitter, lsps, formatters, etc
      bash-language-server
      clang-tools # clangd lsp
      copilot-language-server
      delve
      dockerfile-language-server-nodejs
      gofumpt
      htmx-lsp
      nil # nix lsp
      nixfmt-rfc-style
      pgformatter
      prettier
      rustup
      shellcheck
      shfmt
      # sql-formatter
      stylua
      sumneko-lua-language-server
      tailwindcss-language-server
      taplo # toml lsp
      terraform-ls
      tflint
      tree-sitter
      typescript-language-server
      vscode-langservers-extracted
      yaml-language-server
      yamllint
      zig
      zls # zig lsp
    ]
    ++ (lib.optionals pkgs.stdenv.isDarwin [
      # nur.repos.caarlos0.discord-applemusic-rich-presence
      terminal-notifier
      coreutils
      mosquitto
    ])
    ++ (lib.optionals pkgs.stdenv.isLinux [
      ffmpeg_6-full # failing on macos
      inetutils # macos already has its own utils
      lm_sensors
      # https://nixos.wiki/wiki/podman
      # podman
      # shadow
    ]);
}
