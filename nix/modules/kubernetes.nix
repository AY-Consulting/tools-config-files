{ pkgs, ... }:

{
  home.packages = with pkgs; [
    helm
  ];

  programs.zsh.initExtra = ''
    # kubectl + helm shell completions
    source <(kubectl completion zsh)
    source <(helm completion zsh)
    complete -o default -F __start_kubectl k
  '';
}
