-- 自動補完の設定
return {
  "hrsh7th/nvim-cmp",
  event = { "InsertEnter", "CmdlineEnter" },
  dependencies = {
    "hrsh7th/cmp-nvim-lsp",
    "hrsh7th/cmp-buffer",
    "hrsh7th/cmp-path",
    "hrsh7th/cmp-cmdline", -- : / コマンドラインでも補完候補を表示
    "L3MON4D3/LuaSnip",
    "saadparwaiz1/cmp_luasnip",
    "rafamadriz/friendly-snippets",
  },
  config = function()
    local cmp = require("cmp")
    local luasnip = require("luasnip")

    require("luasnip.loaders.from_vscode").lazy_load()

    local kind_icons = {
      Text = "",
      Method = "󰆧",
      Function = "󰊕",
      Constructor = "",
      Field = "󰇽",
      Variable = "󰂡",
      Class = "󰠱",
      Interface = "",
      Module = "",
      Property = "󰜢",
      Unit = "",
      Value = "󰎠",
      Enum = "",
      Keyword = "󰌋",
      Snippet = "",
      Color = "󰏘",
      File = "󰈙",
      Reference = "",
      Folder = "󰉋",
      EnumMember = "",
      Constant = "󰏿",
      Struct = "",
      Event = "",
      Operator = "󰆕",
      TypeParameter = "󰅲",
    }
    -- 補完メニュー右端に出すソース名
    local source_labels = {
      nvim_lsp = "LSP",
      luasnip = "Snippet",
      buffer = "Buffer",
      path = "Path",
    }
    -- メニュー右端テキストのキャッシュ（entry をキーにした弱参照テーブル）
    -- resolve でテキストが書き換わってもカーソル前後で表示を固定するため
    local menu_cache = setmetatable({}, { __mode = "k" })

    -- TS/JSX で props（Field / Property）を上位に出すための kind 優先度
    -- 数値が小さいほど上に表示される
    local kind_priority = {
      Field = 1,
      Property = 1,
      EnumMember = 2,
      Variable = 3,
      Method = 4,
      Function = 4,
    }
    local compare = cmp.config.compare
    local lsp_kind = require("cmp.types").lsp.CompletionItemKind
    local function rank(entry)
      local kind = lsp_kind[entry:get_kind()]
      return kind_priority[kind] or 99
    end
    local function compare_props_first(e1, e2)
      local r1, r2 = rank(e1), rank(e2)
      if r1 ~= r2 then
        return r1 < r2
      end
      return nil -- 同順位は次の comparator に委ねる
    end

    -- insert モードで zsh(readline)風キー操作を実行するヘルパ（cmp と兼用するキー用）
    local function zsh_feed(keys)
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(keys, true, false, true), "n", false)
    end

    cmp.setup({
      snippet = {
        expand = function(args)
          luasnip.lsp_expand(args.body)
        end,
      },
      mapping = cmp.mapping.preset.insert({
        -- C-b/C-f/C-e は zsh風の行編集と兼用。
        --   補完メニュー表示中 → cmp 本来の動作（docs スクロール / abort）
        --   非表示時          → backward-word / forward-word / end-of-line
        ["<C-b>"] = cmp.mapping(function()
          if cmp.visible() then
            cmp.scroll_docs(-4)
          else
            zsh_feed("<C-o>b")
          end
        end, { "i" }),
        ["<C-f>"] = cmp.mapping(function()
          if cmp.visible() then
            cmp.scroll_docs(4)
          else
            zsh_feed("<C-o>w")
          end
        end, { "i" }),
        ["<C-Space>"] = cmp.mapping.complete(),
        ["<C-e>"] = cmp.mapping(function()
          if cmp.visible() then
            cmp.abort()
          else
            zsh_feed("<End>")
          end
        end, { "i" }),
        ["<CR>"] = cmp.mapping.confirm({ select = true }),
        ["<Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_next_item()
          elseif luasnip.expand_or_jumpable() then
            luasnip.expand_or_jump()
          else
            fallback()
          end
        end, { "i", "s" }),
        ["<S-Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_prev_item()
          elseif luasnip.jumpable(-1) then
            luasnip.jump(-1)
          else
            fallback()
          end
        end, { "i", "s" }),
      }),
      sources = cmp.config.sources({
        { name = "nvim_lsp" },
        { name = "luasnip" },
        -- copilot はインライン補完（copilot.lua）で「欲しいときだけ」出す方針にしたため
        -- 補完メニューのソースからは外している
      }, {
        { name = "buffer" },
        { name = "path" },
      }),
      -- props（Field/Property）を上位に出すソート順
      sorting = {
        priority_weight = 2,
        comparators = {
          compare.offset,
          compare.exact,
          compare_props_first,
          compare.score,
          compare.recently_used,
          compare.locality,
          compare.kind,
          compare.length,
          compare.order,
        },
      },
      formatting = {
        fields = { "kind", "abbr", "menu" },
        format = function(entry, vim_item)
          -- アイコン
          vim_item.kind = string.format("%s %s", kind_icons[vim_item.kind] or "", vim_item.kind)

          -- 右端: どのライブラリ/ディレクトリ由来かを表示する。
          --   completionItem/resolve でカーソルを当てると detail 等が
          --   「Auto import from '...'」に書き換わってしまうため、
          --   メニュー初回描画時の値をエントリ単位でキャッシュし、
          --   カーソル前後で右側テキストが変化しないようにする。
          local cached = menu_cache[entry]
          if cached == nil then
            local item = entry.completion_item or {}
            local ld = item.labelDetails
            if ld and ld.description and ld.description ~= "" then
              cached = ld.description
            elseif item.detail and item.detail ~= "" then
              cached = item.detail
            else
              local label = source_labels[entry.source.name]
              cached = label and ("[" .. label .. "]") or ""
            end
            -- 長すぎる場合は省略（型シグネチャ等が膨らむのを防ぐ）
            if vim.fn.strchars(cached) > 30 then
              cached = vim.fn.strcharpart(cached, 0, 29) .. "…"
            end
            menu_cache[entry] = cached
          end
          vim_item.menu = cached ~= "" and cached or nil
          return vim_item
        end,
      },
    })

    -- : コマンドライン補完（コマンドパレットの下に候補一覧を表示）
    cmp.setup.cmdline(":", {
      mapping = cmp.mapping.preset.cmdline(),
      sources = cmp.config.sources({ { name = "path" } }, { { name = "cmdline" } }),
    })

    -- / ? 検索補完（バッファ内の単語）
    cmp.setup.cmdline({ "/", "?" }, {
      mapping = cmp.mapping.preset.cmdline(),
      sources = { { name = "buffer" } },
    })
  end,
}
