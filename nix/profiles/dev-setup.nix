{ config, pkgs, lib, ... }:

let
  isLinux  = pkgs.stdenv.isLinux;
  isDarwin = pkgs.stdenv.isDarwin;
in
{
  imports = [
    ../modules/git.nix
    ../modules/zsh.nix
  ];

  nixpkgs.config.allowUnfree = true;

  home.username    = "andersyt";
  home.homeDirectory = if isDarwin then "/Users/andersyt" else "/home/andersyt";
  home.stateVersion = "24.05";

  home.packages = with pkgs; [
    keepassxc
    syncthing
    python313
    terraform
    kubectl
    azure-cli
    nodejs
  ];

  # ── VSCode ──────────────────────────────────────────────────────────────────
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
        "zsh".path = "zsh";
      };
    };
  };

  # ── Extra aliases on top of shared zsh module ───────────────────────────────
  programs.zsh.shellAliases = {
    tf = "terraform";
    k  = "kubectl";
  };

  # starship.toml sits next to flake.nix in your repo
  home.file.".config/starship.toml".source = ../starship.toml;

  targets.genericLinux.enable = isLinux;

  programs.home-manager.enable = true;
}
