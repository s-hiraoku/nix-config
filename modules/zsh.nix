{ config, pkgs, lib, ... }:

{
  # fzf は common.nix の programs.fzf で有効化済み (zsh integration 込み)。

  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    initContent = lib.mkMerge [
      # Multiplexer startup policy + p10k instant prompt: must run before compinit (order 570)
      (lib.mkBefore (builtins.readFile ./zsh/early-init.sh))
      # Main configuration (default order 1000)
      ''
        # Set Powerlevel10k theme path from Nix store
        export P10K_THEME_PATH="${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme"

        ${builtins.readFile ./zsh/zshrc.sh}
      ''
    ];
  };

  # ~/.p10k.zsh はこれまでマシンごとのローカルファイルとして手動編集されており、
  # 個人環境と会社環境で内容がずれていた(例: prompt_char セグメントのコメントアウト
  # 有無で `>` プロンプト記号の表示が違う)。共通設定として Nix 管理下に置く。
  home.file.".p10k.zsh".source = ./zsh/p10k.zsh;
}
