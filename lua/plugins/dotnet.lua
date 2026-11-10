return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        omnisharp = { enabled = false },
      },
    },
  },
  {
    "GustavEikaas/easy-dotnet.nvim",
    dependencies = { "nvim-lua/plenary.nvim", "folke/snacks.nvim", "mfussenegger/nvim-dap" },
    lazy = false,
    opts = {
      picker = "snacks",
      lsp = {
        enabled = true,
        roslynator_enabled = true,
        easy_dotnet_extension_enabled = true,
        enhanced_rename = true,
        create_type_from_usage = true,
      },
      test_runner = {
        neotest_integration = true,
        viewmode = "vsplit",
      },
      auto_bootstrap_namespace = {
        type = "file_scoped",
        enabled = true,
      },
    },
  },
  {
    "nvim-neotest/neotest",
    optional = true,
    dependencies = { "GustavEikaas/easy-dotnet.nvim" },
    opts = {
      adapters = {
        ["neotest-vstest"] = false,
        ["easy-dotnet.neotest"] = {},
      },
    },
  },
  {
    "folke/which-key.nvim",
    opts = {
      spec = {
        { "<leader>m", group = ".NET", icon = { icon = "󰪮", color = "purple" } },
      },
    },
  },
}
