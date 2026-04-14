return {
  "coder/claudecode.nvim",
  opts = {
    terminal_cmd = "synapse claude -- --dangerously-skip-permissions",
  },
  config = function(_, opts)
    require("claudecode").setup(opts)
    vim.keymap.set("t", "<C-\\><C-\\>", "<C-\\><C-n>", { desc = "Exit terminal mode" })
  end,
}
