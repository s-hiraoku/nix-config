-- ファジーファインダー
return {
  "nvim-telescope/telescope.nvim",
  -- 起動時ロードを避ける。:Telescope か <leader>f 系キーで初回ロードされる。
  -- キーマップの実体は config 内で設定するため、keys にはロードのトリガーと
  -- なるキー文字列だけを列挙する（lazy がスタブを張り、押下時にロード→実キーへ委譲）。
  cmd = "Telescope",
  keys = {
    "<leader>ff",
    "<leader>fg",
    "<leader>fb",
    "<leader>fh",
    "<leader>fd",
    "<leader>fr",
    "<leader>fR",
    "<leader>fc",
    "<leader>fk",
    "<leader>dl",
    "<leader>hP",
    "<leader>:",
  },
  dependencies = {
    "nvim-lua/plenary.nvim",
    { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
  },
  config = function()
    local telescope = require("telescope")
    local builtin = require("telescope.builtin")
    local ts_utils = require("telescope.utils")
    local actions = require("telescope.actions")
    local action_state = require("telescope.actions.state")

    -- zsh 風のプロンプト行編集。
    -- telescope のプロンプト行は prompt_prefix（"> " 等）を実テキストとして含む
    -- （_get_prompt が prefix 長で切り落としてクエリを取る）ので、prefix より後ろだけを編集する。
    -- nvim_set_current_line は on_lines（nvim_buf_attach）を発火させるため再検索も走る。
    local function delete_to_bol(prompt_bufnr) -- C-u: カーソル位置〜行頭(prefix 直後)を削除
      local picker = action_state.get_current_picker(prompt_bufnr)
      local prefix_len = #picker.prompt_prefix
      local col = vim.api.nvim_win_get_cursor(0)[2]
      if col <= prefix_len then
        return
      end
      local line = vim.api.nvim_get_current_line()
      vim.api.nvim_set_current_line(line:sub(1, prefix_len) .. line:sub(col + 1))
      vim.api.nvim_win_set_cursor(0, { 1, prefix_len })
    end

    local function delete_to_eol() -- C-k: カーソル位置〜行末を削除
      local col = vim.api.nvim_win_get_cursor(0)[2]
      local line = vim.api.nvim_get_current_line()
      vim.api.nvim_set_current_line(line:sub(1, col))
      vim.api.nvim_win_set_cursor(0, { 1, col })
    end

    -- 単語境界の計算。英数字＋アンダースコア以外を区切りとみなす（パスの / - . なども区切り）。
    -- col(0-indexed) から前方/後方の単語端を返す。後方は prefix_len 未満には踏み込まない。
    local function word_fwd(line, col) -- 非単語をスキップ→単語をスキップした末尾位置
      local n, i = #line, col
      while i < n and not line:sub(i + 1, i + 1):match("[%w_]") do
        i = i + 1
      end
      while i < n and line:sub(i + 1, i + 1):match("[%w_]") do
        i = i + 1
      end
      return i
    end
    local function word_bwd(line, col, floor)
      local i = col
      while i > floor and not line:sub(i, i):match("[%w_]") do
        i = i - 1
      end
      while i > floor and line:sub(i, i):match("[%w_]") do
        i = i - 1
      end
      return i
    end

    local function forward_word() -- C-f: 次の単語へ
      local line = vim.api.nvim_get_current_line()
      vim.api.nvim_win_set_cursor(0, { 1, word_fwd(line, vim.api.nvim_win_get_cursor(0)[2]) })
    end
    local function backward_word(prompt_bufnr) -- C-b: 前の単語へ（prefix より前には行かない）
      local prefix_len = #action_state.get_current_picker(prompt_bufnr).prompt_prefix
      local line = vim.api.nvim_get_current_line()
      vim.api.nvim_win_set_cursor(0, { 1, word_bwd(line, vim.api.nvim_win_get_cursor(0)[2], prefix_len) })
    end
    local function kill_word() -- C-d: カーソル位置から後の単語を削除
      local col = vim.api.nvim_win_get_cursor(0)[2]
      local line = vim.api.nvim_get_current_line()
      vim.api.nvim_set_current_line(line:sub(1, col) .. line:sub(word_fwd(line, col) + 1))
      vim.api.nvim_win_set_cursor(0, { 1, col })
    end

    -- プレビュー表示状態に連動した path 表示切り替え用フラグ
    --   false = プレビュー有 / smart 表示（簡潔）
    --   true  = プレビュー無 / フル相対パス表示
    local preview_off = false

    -- ピッカーを開くたびに初期状態（プレビュー有 / smart）へ戻す（状態ズレ防止）
    vim.api.nvim_create_autocmd("FileType", {
      group = vim.api.nvim_create_augroup("TelescopePathToggle", { clear = true }),
      pattern = "TelescopePrompt",
      callback = function()
        preview_off = false
      end,
    })

    -- <C-g>: プレビューの表示/非表示と、それに連動した path 表示をまとめてトグル
    local function toggle_preview_and_path(prompt_bufnr)
      require("telescope.actions.layout").toggle_preview(prompt_bufnr)
      local picker = require("telescope.actions.state").get_current_picker(prompt_bufnr)
      preview_off = picker.previewer == nil

      -- ファインダーを再走させず、今ある結果の各行だけ描き直して選択行を維持する。
      -- picker.manager / entry_adder は telescope 内部 API のため、変更で壊れたら refresh() にフォールバック。
      local manager = picker.manager
      local ok = manager
        and pcall(function()
          for i = 1, manager:num_results() do
            picker:entry_adder(i, manager:get_entry(i), nil, false)
          end
        end)
      if not ok then
        picker:refresh() -- フォールバック（選択は先頭に戻るが確実に再描画される）
      end
    end

    telescope.setup({
      defaults = {
        mappings = {
          -- <C-g>: プレビュー表示/非表示 ＋ path 表示(smart ⇔ フル相対) を連動トグル
          i = {
            ["<esc>"] = actions.close,
            ["<C-g>"] = toggle_preview_and_path,
            -- プレビューのスクロール（Alt+矢印 4方向でまとめる）。macOS では Ctrl+矢印は OS 予約、
            -- Alt+英字は特殊文字を合成して届かないが、Alt+矢印は Meta として確実に届く。
            ["<M-Up>"] = actions.preview_scrolling_up,
            ["<M-Down>"] = actions.preview_scrolling_down,
            ["<M-Left>"] = actions.preview_scrolling_left,
            ["<M-Right>"] = actions.preview_scrolling_right,
            -- 前回までの入力履歴を呼び出す（C-n/C-p）。既定の候補移動を上書きするため、候補移動は
            -- 素の ↑/↓（と Tab/S-Tab）に任せる。履歴は stdpath("data")/telescope_history に永続化。
            ["<C-p>"] = actions.cycle_history_prev,
            ["<C-n>"] = actions.cycle_history_next,
            -- zsh 風の行編集（既定のプレビュースクロールを上書き）。zshrc の bindkey に対応:
            --   C-u 行頭まで削除 / C-k 行末まで削除 / C-f 次の単語 / C-b 前の単語 / C-d 後の単語削除
            --   C-w（前の単語削除）は insert モード標準でそのまま使える。
            ["<C-u>"] = delete_to_bol,
            ["<C-k>"] = delete_to_eol,
            ["<C-f>"] = forward_word,
            ["<C-b>"] = backward_word,
            ["<C-d>"] = kill_word,
          },
          n = {
            ["<C-g>"] = toggle_preview_and_path,
          },
        },
        -- プレビュー表示中は smart（簡潔）、<C-g> で非表示にするとフル相対パスに切り替わる。
        -- 関数内は組み込み transform_path に委譲（table を渡すので再帰しない）。
        path_display = function(opts, path)
          local mode = preview_off and {} or { "smart" }
          return ts_utils.transform_path({ path_display = mode, cwd = opts and opts.cwd }, path)
        end,
        file_ignore_patterns = {
          "node_modules/",
          ".git/",
          "dist/",
          "build/",
          "__pycache__/",
          "%.lock",
          "lazy-lock%.json",
        },
        sorting_strategy = "descending",
        layout_config = {
          horizontal = {
            prompt_position = "bottom",
            preview_width = 0.55,
          },
          vertical = { mirror = true },
        },
        -- live_grep でも隠しファイルを検索対象にする
        vimgrep_arguments = {
          "rg",
          "--color=never",
          "--no-heading",
          "--with-filename",
          "--line-number",
          "--column",
          "--smart-case",
          "--hidden",
          "--glob=!.git/",
        },
      },
      pickers = {
        -- ドットファイルも表示する
        find_files = { hidden = true },
      },
      extensions = { fzf = {} },
    })
    telescope.load_extension("fzf")

    local map = vim.keymap.set
    map("n", "<leader>ff", builtin.find_files, { desc = "Telescope: find files" })
    map("n", "<leader>fg", builtin.live_grep, { desc = "Telescope: live grep" })
    map("n", "<leader>fb", builtin.buffers, { desc = "Telescope: buffers" })
    map("n", "<leader>fh", builtin.help_tags, { desc = "Telescope: help tags" })
    map("n", "<leader>fd", function()
      require("telescope.builtin").find_files({
        prompt_title = "ディレクトリへ移動",
        find_command = {
          "find",
          ".",
          "-type",
          "d",
          "-not",
          "-path",
          "*/node_modules/*",
          "-not",
          "-path",
          "*/.git/*",
        },
        attach_mappings = function(prompt_bufnr, map_fn)
          local actions = require("telescope.actions")
          local action_state = require("telescope.actions.state")
          actions.select_default:replace(function()
            actions.close(prompt_bufnr)
            local entry = action_state.get_selected_entry()
            if entry then
              local dir = entry.value
              if not vim.startswith(dir, "/") then
                dir = vim.fn.getcwd() .. "/" .. dir
              end
              vim.cmd("Neotree reveal dir=" .. vim.fn.fnameescape(dir))
            end
          end)
          return true
        end,
      })
    end, { desc = "Telescope: find directory (open in neo-tree)" })
    -- diagnostics 一覧は <leader>d グループへ（<leader>de=カーソル位置の浮動表示 と並ぶ）。
    -- <leader>f 系は検索（ファイル/grep）専用に保つ。ジャンプは nvim 標準の ]d / [d を使う。
    map("n", "<leader>dl", builtin.diagnostics, { desc = "Telescope: diagnostics list" })
    -- git 変更ファイル一覧（diff プレビュー付き）。hunk 内ジャンプ hj/hk・preview hp は gitsigns 側。
    map("n", "<leader>hP", builtin.git_status, { desc = "Telescope: git status (changed files)" })
    -- fr: カレントディレクトリ限定の履歴、fR: 全体の履歴
    map("n", "<leader>fr", function()
      builtin.oldfiles({ cwd_only = true })
    end, { desc = "Telescope: recent files (cwd only)" })
    map("n", "<leader>fR", builtin.oldfiles, { desc = "Telescope: recent files (all)" })
    map("n", "<leader>fc", function()
      builtin.live_grep({ default_text = vim.fn.expand("<cword>") })
    end, { desc = "Telescope: grep word under cursor" })
    map("n", "<leader>:", builtin.command_history, { desc = "Telescope: command history" })
    -- キーマップ一覧（:nmap/:imap の `<Lua NNN: ...>` と違い、
    -- モード・キー・説明が一貫した形式で検索・閲覧できる）
    -- 既定では visual(x)/select(s)/operator(o)/term(t) が抜けるので明示的に全モード指定
    map("n", "<leader>fk", function()
      builtin.keymaps({ modes = { "n", "i", "c", "v", "x", "s", "o", "t" } })
    end, { desc = "Telescope: keymaps" })
  end,
}
