{ buildGoModule, fetchFromGitHub, lib }:

buildGoModule rec {
  pname = "wtp";
  version = "2.10.3";

  src = fetchFromGitHub {
    owner = "satococoa";
    repo = "wtp";
    rev = "v${version}";
    hash = "sha256-KgayKjH4iHi7LgWwk2Laba33bMVZdbiMQgSmqBSTfZ0=";
  };

  vendorHash = "sha256-zsSNo1MQgpvH3ZSd3kmvdIpOCVJgSu1/pYLltx/9dZg=";

  # 一部の統合テストが Nix のビルドサンドボックス (git なし) では実行できないためスキップ。
  doCheck = false;

  # `wtp --version` の出力に正しいバージョンを埋め込む。
  # 上流 (cmd/wtp/main.go) が `version` 変数を ldflags 経由で受け取る作りなので、
  # GoReleaser の代わりに Nix 側で同じことをする。
  ldflags = [
    "-s"
    "-w"
    "-X main.version=${version}"
  ];

  meta = with lib; {
    description = "Worktree Plus - Enhanced worktree management with automated setup and hooks";
    homepage = "https://github.com/satococoa/wtp";
    license = licenses.mit;
    mainProgram = "wtp";
  };
}
