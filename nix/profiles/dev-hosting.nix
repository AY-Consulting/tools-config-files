{ pkgs, ... }:

{
  imports = [
    ../modules/git.nix
    ../modules/zsh.nix
    ../modules/docker-tools.nix
  ];

  home.username      = "ay-dev-host";
  home.homeDirectory = "/home/ay-dev-host";
  home.stateVersion  = "24.11";

  # starship.toml shared from repo root
  home.file.".config/starship.toml".source = ../starship.toml;

  targets.genericLinux.enable = true;

  programs.home-manager.enable = true;
}
