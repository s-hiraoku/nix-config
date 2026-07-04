-- 画像表示（nvim 内で画像ファイル・markdown 内画像をインライン表示）
-- kitty graphics protocol を使うため、外側の端末は wezterm / ghostty が必要。
-- tmux 越しの表示には allow-passthrough on（modules/tmux.nix で設定済み）が要る。
-- 画像処理は ImageMagick の magick CLI を使う（nix で導入済み・luarocks 不要）。
return {
  "3rd/image.nvim",
  ft = { "markdown", "png", "jpg", "jpeg", "gif", "webp", "avif" },
  opts = {
    backend = "kitty",
    processor = "magick_cli",
    integrations = {
      markdown = {
        enabled = true,
        clear_in_insert_mode = false,
        only_render_image_at_cursor = false,
        filetypes = { "markdown" },
      },
    },
    max_width = nil,
    max_height = nil,
    -- tmux のアクティブウィンドウ以外では画像を消す（描画崩れ防止）
    tmux_show_only_in_active_window = true,
    window_overlap_clear_enabled = true,
  },
}
