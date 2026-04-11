{
  description = "andersyt Home Manager configs";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, ... }:
    let
      mkHome = system: profile: home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.${system};
        modules = [ profile ];
      };
    in {
      homeConfigurations = {
        # Your dev machine (macOS or Linux)
        "andersyt" = mkHome "x86_64-linux" ./profiles/dev-setup.nix;

        # Your Ubuntu Docker VM
        "ay-dev-host" = mkHome "x86_64-linux" ./profiles/dev-hosting.nix;
      };
    };
}
