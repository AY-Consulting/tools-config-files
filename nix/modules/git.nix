{ ... }:

{
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
}
