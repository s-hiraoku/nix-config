{
  description = "Home Manager configuration of hiraoku.shinichi";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # hunk (https://www.hunk.dev/): レビュー向けターミナル diff ビューア。
    # nixpkgs 未収録だが upstream 自身が flake を提供しているため、
    # pkgs/ 配下に自前 derivation を書かずそのまま input として取り込む。
    hunk.url = "github:modem-dev/hunk";
  };

  outputs =
    { nixpkgs, home-manager, hunk, ... }:
    let
      system = "aarch64-darwin";

      # nixpkgs に未収録のパッケージを overlay で追加する。
      # 各パッケージは pkgs/ 配下に独立した derivation として置く。
      # NOTE: herdr は nixpkgs 版が Darwin でソースビルドに失敗するため
      # (vendored libghostty-vt の zig ビルドが Apple SDK を見つけられず
      #  DarwinSdkNotFound。upstream issue ogulcancelik/herdr#285)、
      # 本体は Homebrew (brew install herdr) で導入し、Nix では設定のみ管理する
      # (modules/herdr.nix)。upstream / nixpkgs が Darwin ビルドを直したら
      # ここに herdr overlay を足して本体も Nix 管理へ移行する。
      overlays = [
        (final: prev: {
          wtp = final.callPackage ./pkgs/wtp.nix { };
          hunk = hunk.packages.${system}.default;
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
