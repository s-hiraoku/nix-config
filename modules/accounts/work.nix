{ config, pkgs, ... }:

let
  # openapi-generator-cli などの Java ツール用 JDK。
  # LTS (Java 17) を採用。openapi-generator-cli v7.x は Java 11 以上を要求。
  jdk = pkgs.jdk17;
in
{
  home.packages = [ jdk ];

  home.sessionVariables = {
    # .home は platform ごとの正しい JAVA_HOME path を返す
    JAVA_HOME = jdk.home;

    LAZYGIT_COMMIT_PROMPT = "ステージ済みの diff を読んで、Conventional Commits 形式 `type(scope): description` で 1 行の日本語コミットメッセージを出力してください。type は feat, fix, docs, style, refactor, test, chore のいずれかのみ。マークダウンや余計な説明は不要。メッセージ本文のみを返してください。";
  };

  programs.git.settings.user.email = "hiraoku.shinichi@synergy101.jp";
}
