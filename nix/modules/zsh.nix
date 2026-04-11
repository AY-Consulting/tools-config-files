{ ... }:

{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    # Aliases shared across all machines
    shellAliases = {
      ll     = "ls -la";
      update = "home-manager switch";

      # Git
      ga    = "git add .";
      gcom  = "git commit -m";
      gpush = "git push";
      gpom  = "git pull origin main";
      gckm  = "git checkout main";
      gckb  = "git checkout -b";
      gpull  = "git pull";
    };
  };

  # Starship prompt — shared across all machines
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
  };
}
