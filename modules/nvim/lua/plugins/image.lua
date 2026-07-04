-- 画像表示（nvim 内で画像ファイル・markdown 内画像をインライン表示）
-- kitty graphics protocol を使うため、外側の端末は wezterm / ghostty が必要。
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
    window_overlap_clear_enabled = true,
  },
}
