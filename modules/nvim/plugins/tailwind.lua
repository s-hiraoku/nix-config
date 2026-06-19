-- Tailwind CSS の LSP 補完を有効化する。
-- LazyVim の lang.tailwind extra を読み込むことで、tailwindcss-language-server の
-- 起動設定・補完ソース・カラースウォッチ表示がまとめて構成される。
-- プロジェクト直下の tailwind.config.{js,cjs,ts} を検出すると、その設定の
-- カスタムトークン（例: text-size-m / text-size-base）を補完候補に出す。
return {
  { import = "lazyvim.plugins.extras.lang.tailwind" },
}
