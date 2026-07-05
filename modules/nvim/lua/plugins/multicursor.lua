-- マルチカーソル（VSCode の cmd+d に相当）
-- 操作フロー: Ctrl+n で単語選択 → 連打で次の同単語を追加 → c/i で同時編集 → Esc×2 で解除
return {
  "mg979/vim-visual-multi",
  branch = "master",
  event = { "BufReadPost", "BufNewFile" },
  init = function()
    vim.g.VM_maps = {
      ["Find Under"] = "<C-n>", -- カーソル下の単語を選択 & 次の同単語も追加
      ["Find Subword Under"] = "<C-n>",
      ["Add Cursor Down"] = "<C-Down>", -- 下の行にカーソルを追加
      ["Add Cursor Up"] = "<C-Up>", -- 上の行にカーソルを追加
      ["Skip Region"] = "<C-x>", -- 現在の選択をスキップして次へ
      ["Undo"] = "u",
    }
    -- ステータスラインに「MULTI」と表示
    vim.g.VM_set_statusline = 3
    -- Insert モード終了（Esc）で VM モードも終了
    vim.g.VM_quit_after_leaving_insert_mode = 1
    -- カーソル位置を Kanagawa Wave に映える色で明示
    vim.api.nvim_create_autocmd("ColorScheme", {
      pattern = "*",
      callback = function()
        vim.api.nvim_set_hl(0, "VM_Cursor", { bg = "#a6da95", fg = "#181926", bold = true }) -- green
        vim.api.nvim_set_hl(0, "VM_Extend", { bg = "#eed49f", fg = "#181926" }) -- yellow
        vim.api.nvim_set_hl(0, "VM_Match", { bg = "#8aadf4", fg = "#181926" }) -- blue
        vim.api.nvim_set_hl(0, "VM_Insert", { bg = "#ed8796", fg = "#181926", bold = true }) -- red
      end,
    })
    vim.cmd("doautocmd ColorScheme")
  end,
}
