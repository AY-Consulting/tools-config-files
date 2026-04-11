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

  # Deploy your SSH public key
  home.file.".ssh/authorized_keys" = {
    text = ''
      ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBaBRTgkdq/lG1Hi78Vft0Vgj/T4U8DDLNWbR+H3PVib andersmyt@gmail.com
    '';
    mode = "0600";
  };

  # starship.toml shared from repo root
  home.file.".config/starship.toml".source = ../starship.toml;

  targets.genericLinux.enable = true;

  programs.home-manager.enable = true;
}
