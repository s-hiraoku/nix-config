-- HTML タグの自動補完・自動リネーム（JSX / TSX にも対応）
-- 対応タグ上にカーソルがあると、閉じタグをハイライト（matchparen 相当）
return {
  "windwp/nvim-ts-autotag",
  dependencies = { "nvim-treesitter/nvim-treesitter" },
  -- ft による遅延ロードは InsertLeave が別バッファで発火したとき
  -- treesitter パーサーが nil になりエラーになる。
  -- BufReadPost で起動時に一度ロードし、プラグイン自身の filetype 判定に任せる。
  event = "BufReadPost",
  config = function()
    require("nvim-ts-autotag").setup({
      opts = {
        enable_close = true,
        enable_rename = true,
        enable_close_on_slash = false,
      },
    })

    -- -----------------------------------------------------------------------
    -- Guard: autotag の internal モジュール関数を pcall でラップする。
    --
    -- 問題: InsertCharPre で `>` を入力した際、autotag が現在バッファの
    --   treesitter パーサーを取得しようとするが、Lua / Python 等の
    --   非 HTML/JSX バッファでは buf_parser が nil になりクラッシュする。
    --   (internal.lua:257 "attempt to index local 'buf_parser' (a nil value)")
    --
    -- 対処: internal モジュールのすべての公開関数を pcall でラップし、
    --   nil パーサーによるクラッシュを握りつぶす。
    --   autotag が対応していないバッファではそもそも何もしないのが正しい動作。
    -- -----------------------------------------------------------------------
    local ok, internal = pcall(require, "nvim-ts-autotag.internal")
    if ok and type(internal) == "table" then
      for k, v in pairs(internal) do
        if type(v) == "function" then
          internal[k] = function(...)
            pcall(v, ...)
          end
        end
      end
    end
  end,
}
