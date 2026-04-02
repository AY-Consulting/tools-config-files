{ config, pkgs, lib, ... }:

let
  isLinux = pkgs.stdenv.isLinux;
  isDarwin = pkgs.stdenv.isDarwin;
in
{
  # ── Allow unfree packages (VSCode) ───────────────────────────────────────────
  nixpkgs.config.allowUnfree = true;

  # ── User info ────────────────────────────────────────────────────────────────
  home.username = "andersyt";
  home.homeDirectory = if isDarwin then "/Users/andersyt" else "/home/andersyt";
  home.stateVersion = "24.05";

  # ── Packages ─────────────────────────────────────────────────────────────────
  home.packages = with pkgs; [
    keepassxc
    syncthing   # client only — no service enabled
    python313
    terraform
    kubectl
    azure-cli
    nodejs
  ];

  # ── VSCode ───────────────────────────────────────────────────────────────────
  programs.vscode = {
    enable = true;
    profiles.default.extensions = with pkgs.vscode-extensions; [
      ms-python.python
      ms-vscode.powershell
      hashicorp.terraform
      eamodio.gitlens
    ];
    profiles.default.userSettings = {
      "terminal.integrated.defaultProfile.linux" = "zsh";
      "terminal.integrated.profiles.linux" = {
        "zsh" = {
          "path" = "zsh";
        };
      };
    };
  };

  # ── Zsh ──────────────────────────────────────────────────────────────────────
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    shellAliases = {
      ll     = "ls -la";
      update = "home-manager switch";

      # Terraform
      tf     = "terraform";

      # Kubernetes
      k      = "kubectl";

      # Git
      ga     = "git add .";
      gcom   = "git commit -m";
      gpush  = "git push";
      gpom   = "git pull origin main";
      gckm   = "git checkout main";
      gckb   = "git checkout -b";
    };
  };

  # ── Starship — config from local dotfiles repo ───────────────────────────────
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
  };

  # starship.toml sits next to home.nix in your repo
  home.file.".config/starship.toml".source = ./starship.toml;

  # ── Git ──────────────────────────────────────────────────────────────────────
  programs.git = {
    enable = true;
    settings = {
      user.name  = "andersyt";
      user.email = "andersmyt@gmail.com";
      init.defaultBranch = "main";
      pull.rebase = true;
      signing.format = "openpgp";
    };
  };

  # ── Platform-specific ────────────────────────────────────────────────────────
  targets.genericLinux.enable = isLinux;

  # Let Home Manager manage itself
  programs.home-manager.enable = true;
}
