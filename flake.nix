{
  description = "Home Manager configuration of hiraoku.shinichi";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { nixpkgs, home-manager, ... }:
    let
      system = "aarch64-darwin";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      homeConfigurations."hiraoku.shinichi" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [
          ./modules/common.nix
          ./modules/personal.nix
        ];
      };

      homeConfigurations."hiraoku.shinichi@PC-05481" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [
          ./modules/common.nix
          ./modules/work.nix
        ];
      };
    };
}
