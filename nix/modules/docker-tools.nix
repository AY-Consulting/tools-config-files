{ pkgs, ... }:

{
  home.packages = with pkgs; [
    docker-compose
    python313
    jq
    curl
    wget
    ripgrep
    tree
    htop
    unzip
  ];

  programs.zsh.shellAliases = {
    # Docker
    dc  = "docker compose";
    dps = "docker ps";
    dpa = "docker ps -a";
    dl  = "docker logs -f";
    di  = "docker images";
    dex = "docker exec -it";
    dpr = "docker compose pull && docker compose up -d"; # pull & redeploy

    # Docker cleanup
    dclean = "docker system prune -af";
  };
}
