return {
  {
    dir = vim.fn.stdpath("config") .. "/dojo",
    name = "dojo",
    cmd = { "Dojo", "DojoContinue", "DojoHint", "DojoRestart", "DojoSkip", "DojoStats" },
    keys = {
      { "<leader>k", "<cmd>Dojo<cr>", desc = "Dojo (Neovim katas)" },
    },
    opts = {},
  },
  {
    "folke/snacks.nvim",
    opts = function(_, opts)
      local keys = vim.tbl_get(opts, "dashboard", "preset", "keys")
      if keys then table.insert(keys, #keys, { icon = "🥋", key = "D", desc = "Neovim Dojo", action = ":Dojo" }) end
    end,
  },
}
