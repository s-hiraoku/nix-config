{ config, pkgs, ... }:

{
  # 外付け SSD に ghq の clone 先を置く。
  # 別の個人 PC では SSD が無い可能性があるので、host モジュール側で持つ。
  programs.git.settings.ghq.root = "/Volumes/SSD/ghq";
}
