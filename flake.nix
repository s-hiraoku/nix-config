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

      # nixpkgs に未収録のパッケージを overlay で追加する。
      # 各パッケージは pkgs/ 配下に独立した derivation として置く。
      overlays = [
        (final: prev: {
          wtp = final.callPackage ./pkgs/wtp.nix { };
        })
      ];

      pkgs = import nixpkgs { inherit system overlays; };

      # ホスト構成は account (誰として使うか) と host (どのマシンか) の
      # 2 軸で組み合わせる。
      mkHome = modules: home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [ ./modules/common.nix ] ++ modules;
      };
    in
    {
      homeConfigurations = {
        "hiraoku.shinichi" = mkHome [
          ./modules/accounts/personal.nix
          ./modules/hosts/personal-mbp.nix
        ];

        "hiraoku.shinichi@PC-05481" = mkHome [
          ./modules/accounts/work.nix
          ./modules/hosts/work-pc05481.nix
        ];
      };
    };
}
