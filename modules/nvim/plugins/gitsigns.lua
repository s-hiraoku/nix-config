return {
  "lewis6991/gitsigns.nvim",
  opts = {
    signs = {
      add = { text = "│" },
      change = { text = "│" },
      delete = { text = "_" },
      topdelete = { text = "‾" },
      changedelete = { text = "~" },
    },
  },
  keys = {
    { "]c", function() require("gitsigns").nav_hunk("next") end, desc = "Next git hunk" },
    { "[c", function() require("gitsigns").nav_hunk("prev") end, desc = "Previous git hunk" },
    { "<leader>hp", function() require("gitsigns").preview_hunk() end, desc = "Preview hunk" },
    { "<leader>hs", function() require("gitsigns").stage_hunk() end, desc = "Stage hunk" },
    { "<leader>hr", function() require("gitsigns").reset_hunk() end, desc = "Reset hunk" },
    { "<leader>hb", function() require("gitsigns").blame_line({ full = true }) end, desc = "Blame line (full)" },
  },
}
