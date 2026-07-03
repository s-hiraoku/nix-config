-- UI 関連プラグインの束（小さめのものをまとめる）
-- 大きい catppuccin / lualine は別ファイルに分離している。
return {
  -- バッファタブ
  {
    "akinsho/bufferline.nvim",
    version = "*",
    dependencies = "nvim-tree/nvim-web-devicons",
    config = function()
      require("bufferline").setup({
        options = {
          separator_style = "thin",
          diagnostics = "nvim_lsp",
          show_buffer_close_icons = false,
          show_close_icon = false,
          offsets = {
            {
              filetype = "neo-tree",
              text = "File Explorer",
              highlight = "Directory",
              separator = true,
            },
          },
        },
      })
    end,
  },

  -- Git サイン (変更行表示)
  {
    "lewis6991/gitsigns.nvim",
    config = function()
      require("gitsigns").setup({
        -- add / change / changedelete は行頭の細い縦線 ▎ で統一。
        -- delete / topdelete は未指定（deep_extend でデフォルトの ▁ / ▔ が効く）。
        signs = {
          add = { text = "▎" },
          change = { text = "▎" },
          changedelete = { text = "▎" },
        },
        on_attach = function(bufnr)
          local gs = package.loaded.gitsigns
          local map = vim.keymap.set
          local git_blame = require("config.git-blame-actions")
          -- wrap = true で末尾／先頭に達したら反対側へループする
          map("n", "<leader>hj", function()
            gs.nav_hunk("next", { wrap = true })
          end, { buffer = bufnr, desc = "Git: next hunk" })
          map("n", "<leader>hk", function()
            gs.nav_hunk("prev", { wrap = true })
          end, { buffer = bufnr, desc = "Git: prev hunk" })
          map("n", "<leader>hs", gs.stage_hunk, { buffer = bufnr, desc = "Git: stage/unstage hunk (toggle)" })
          map("n", "<leader>hr", gs.reset_hunk, { buffer = bufnr, desc = "Git: reset hunk" })
          map("n", "<leader>hp", gs.preview_hunk, { buffer = bufnr, desc = "Git: preview hunk" })
          map("n", "<leader>hb", gs.blame_line, { buffer = bufnr, desc = "Git: blame line" })
          -- blame 行のコミットを起点にした閲覧（diffview / gh）。詳細は config/git-blame-actions.lua
          map(
            "n",
            "<leader>hd",
            git_blame.diff_file_at_commit,
            { buffer = bufnr, desc = "Git: blame行コミットのこのファイル差分 (git show)" }
          )
          map(
            "n",
            "<leader>hD",
            git_blame.commit_details,
            { buffer = bufnr, desc = "Git: blame行コミットの全変更ファイル" }
          )
          map("n", "<leader>ho", git_blame.open_pr, { buffer = bufnr, desc = "Git: blame行コミットのPR" })
        end,
      })
    end,
  },

  -- 自動括弧閉じ
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = function()
      require("nvim-autopairs").setup()
    end,
  },

  -- コメントトグル (gcc / gc)
  {
    "numToStr/Comment.nvim",
    config = function()
      require("Comment").setup()
    end,
  },

  -- which-key (キーバインド一覧)
  -- preset = "helix" で右下にスマートな表示
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      preset = "helix",
      -- ビジュアル中／d・y 演算中に which-key が即ポップアップして
      -- <C-d> 等の操作を奪うのを防ぐ（もう1キー押されるまで出さない）
      defer = function(ctx)
        if vim.list_contains({ "d", "y" }, ctx.operator) then
          return true
        end
        return vim.list_contains({ "v", "V", "<C-V>" }, ctx.mode)
      end,
    },
  },

  -- 括弧・タグのハイライト強化
  -- カーソルがブロック内にいるときも対応する括弧・タグを常にハイライトする
  -- （組み込み matchparen はタグ/括弧の上でのみ相手方をハイライト）
  {
    "andymass/vim-matchup",
    event = { "BufReadPost", "BufNewFile" },
    init = function()
      vim.g.matchup_matchparen_offscreen = { method = "popup" } -- はみ出たペアをポップアップで表示
    end,
  },
}
