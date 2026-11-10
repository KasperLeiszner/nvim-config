local map = vim.keymap.set

local function dotnet(fn)
  return function() require("easy-dotnet")[fn]() end
end

local function code_action(kind)
  return function()
    vim.lsp.buf.code_action({ context = { only = kind and { kind } or nil, diagnostics = {} } })
  end
end

local function dap(fn)
  return function() require("dap")[fn]() end
end

local function start_or_continue()
  if require("dap").session() then return require("dap").continue() end
  if vim.bo.filetype == "cs" or vim.fn.glob("*.sln*") ~= "" then return require("easy-dotnet").debug_default() end
  require("dap").continue()
end

local function stop_all()
  if require("dap").session() then require("dap").terminate() end
  pcall(function() require("easy-dotnet").stop() end)
end

-- IdeaVim leader maps carried over from ~/.ideavimrc
map("n", "<leader>gd", vim.lsp.buf.definition, { desc = "Goto Declaration (Rider)" })
map("n", "<leader>gy", vim.lsp.buf.type_definition, { desc = "Goto Type Declaration (Rider)" })
map("n", "<leader>gi", function() Snacks.picker.lsp_implementations() end, { desc = "Goto Implementation (Rider)" })
map("n", "<leader>gu", function() Snacks.picker.lsp_references() end, { desc = "Show Usages (Rider)" })
map("n", "<leader>gb", "<C-o>", { desc = "Back (Rider)" })
map("n", "<leader>gf", "<C-i>", { desc = "Forward (Rider)" })
map("n", "<leader>gB", function() Snacks.picker.git_log_line() end, { desc = "Git Blame Line" })
map("n", "<leader>gF", function() Snacks.picker.git_log_file() end, { desc = "Git Current File History" })
map("n", "<leader><leader>", function() Snacks.picker.smart() end, { desc = "Search Everywhere (Rider)" })

-- macOS basics (Neovide does not map Cmd keys by default)
map({ "n", "i", "v" }, "<D-s>", "<cmd>w<cr><esc>", { desc = "Save" })
map({ "n", "i", "v" }, "<D-S-s>", "<cmd>wa<cr><esc>", { desc = "Save All" })
map("v", "<D-c>", '"+y', { desc = "Copy" })
map("v", "<D-x>", '"+d', { desc = "Cut" })
map({ "n", "v" }, "<D-v>", '"+P', { desc = "Paste" })
map({ "i", "c" }, "<D-v>", "<C-r>+", { desc = "Paste" })
map("t", "<D-v>", [[<C-\><C-n>"+Pi]], { desc = "Paste" })
map("n", "<D-a>", "ggVG", { desc = "Select All" })
map({ "n", "i" }, "<D-z>", "<cmd>undo<cr>", { desc = "Undo" })
map({ "n", "i" }, "<D-S-z>", "<cmd>redo<cr>", { desc = "Redo" })
map("n", "<D-w>", function() Snacks.bufdelete() end, { desc = "Close Tab" })
map("n", "<D-F4>", function() Snacks.bufdelete() end, { desc = "Close Tab (Rider)" })

-- Navigation (Rider: Visual Studio OSX keymap)
map("n", "<D-t>", function() Snacks.picker.smart() end, { desc = "Search Everywhere" })
map("n", "<D-S-t>", function() Snacks.picker.files() end, { desc = "Goto File" })
map("n", "<D-o>", function() Snacks.picker.lsp_workspace_symbols({ filter = { default = { "Class", "Struct", "Interface", "Enum", "Record" } } }) end, { desc = "Goto Type" })
map("n", "<D-S-M-t>", function() Snacks.picker.lsp_workspace_symbols() end, { desc = "Goto Symbol" })
map("n", "<C-,>", function() Snacks.picker.recent() end, { desc = "Recent Files" })
map("n", "<M-\\>", function() Snacks.picker.lsp_symbols() end, { desc = "File Structure" })
map("n", "<F12>", vim.lsp.buf.definition, { desc = "Goto Declaration" })
map("n", "<S-F12>", function() Snacks.picker.lsp_references() end, { desc = "Find Usages" })
map("n", "<M-S-F12>", function() Snacks.picker.lsp_references() end, { desc = "Show Usages" })
map("n", "<D-S-F11>", vim.lsp.buf.type_definition, { desc = "Goto Type Declaration" })
map("n", "<M-End>", function() Snacks.picker.lsp_implementations() end, { desc = "Goto Implementation" })
map("n", "<D-->", "<C-o>", { desc = "Back" })
map("n", "<D-S-->", "<C-i>", { desc = "Forward" })
map("n", "<M-PageDown>", function() vim.diagnostic.jump({ count = 1, severity = vim.diagnostic.severity.ERROR }) end, { desc = "Next Error" })
map("n", "<M-PageUp>", function() vim.diagnostic.jump({ count = -1, severity = vim.diagnostic.severity.ERROR }) end, { desc = "Previous Error" })
map({ "n", "i" }, "<D-k><D-i>", vim.lsp.buf.hover, { desc = "Quick Documentation" })
map("n", "<D-k>i", vim.lsp.buf.hover, { desc = "Quick Documentation" })

-- Search
map("n", "<D-f>", "/", { desc = "Find in File" })
map("n", "<D-g>", "n", { desc = "Find Next" })
map("n", "<D-S-f>", function() Snacks.picker.grep() end, { desc = "Find in Files" })
map("n", "<D-S-h>", function() require("grug-far").open() end, { desc = "Replace in Files" })

-- Editing & refactoring
map({ "n", "i", "v" }, "<M-CR>", code_action(), { desc = "Show Intention Actions" })
map({ "n", "v" }, "<D-r>r", function() return ":IncRename " .. vim.fn.expand("<cword>") end, { expr = true, desc = "Rename" })
map({ "n", "v" }, "<D-r><D-r>", function() return ":IncRename " .. vim.fn.expand("<cword>") end, { expr = true, desc = "Rename" })
map({ "n", "v" }, "<D-r>m", code_action("refactor.extract"), { desc = "Extract Method" })
map({ "n", "v" }, "<D-r><D-m>", code_action("refactor.extract"), { desc = "Extract Method" })
map({ "n", "v" }, "<D-S-r>", code_action("refactor"), { desc = "Refactor This" })
map("n", "<D-M-/>", "gcc", { remap = true, desc = "Comment Line" })
map("v", "<D-M-/>", "gc", { remap = true, desc = "Comment Selection" })
map("n", "<D-k><D-c>", "gcc", { remap = true, desc = "Comment Line" })
map("v", "<D-k><D-c>", "gc", { remap = true, desc = "Comment Selection" })
map("n", "<D-k><D-u>", "gcc", { remap = true, desc = "Uncomment Line" })
map("v", "<D-k><D-u>", "gc", { remap = true, desc = "Uncomment Selection" })
map({ "n", "v" }, "<D-M-CR>", function() LazyVim.format({ force = true }) end, { desc = "Reformat Code" })
map({ "n", "v" }, "<D-k><D-d>", function() LazyVim.format({ force = true }) end, { desc = "Reformat Code" })
map("n", "<D-n>", function() require("easy-dotnet").createfile(vim.fn.expand("%:p:h")) end, { desc = "New File From Template" })

-- Tool windows
map("n", "<D-1>", "<cmd>Neotree toggle reveal<cr>", { desc = "Solution Explorer" })
map("n", "<D-M-l>", "<cmd>Neotree toggle reveal<cr>", { desc = "Solution Explorer" })
map({ "n", "t" }, "<D-C-1>", function() Snacks.terminal() end, { desc = "Terminal" })
map("n", "<D-0>", function() Snacks.lazygit() end, { desc = "Git (lazygit)" })

-- Build, run, debug
map("n", "<D-S-b>", dotnet("build_solution_quickfix"), { desc = "Build Solution" })
map("n", "<D-F9>", dotnet("build_solution_quickfix"), { desc = "Build Solution" })
map("n", "<C-F5>", dotnet("run_default"), { desc = "Run" })
map("n", "<M-F5>", dotnet("debug"), { desc = "Debug (pick project)" })
map("n", "<F5>", start_or_continue, { desc = "Debug / Resume" })
map("n", "<S-F5>", stop_all, { desc = "Stop" })
map("n", "<F9>", dap("toggle_breakpoint"), { desc = "Toggle Breakpoint" })
map("n", "<F10>", dap("step_over"), { desc = "Step Over" })
map("n", "<F11>", dap("step_into"), { desc = "Step Into" })
map("n", "<D-F11>", dap("step_into"), { desc = "Step Into" })
map("n", "<S-F11>", dap("step_out"), { desc = "Step Out" })

-- Unit tests (Rider: Cmd+; then T/D/L)
map("n", "<D-;>t", function() require("neotest").run.run() end, { desc = "Run Unit Tests" })
map("n", "<D-;><D-t>", function() require("neotest").run.run() end, { desc = "Run Unit Tests" })
map("n", "<D-;>d", function() require("neotest").run.run({ strategy = "dap" }) end, { desc = "Debug Unit Tests" })
map("n", "<D-;><D-d>", function() require("neotest").run.run({ strategy = "dap" }) end, { desc = "Debug Unit Tests" })
map("n", "<D-;>l", function() require("neotest").run.run(vim.uv.cwd()) end, { desc = "Run All Tests in Solution" })
map("n", "<D-;><D-l>", function() require("neotest").run.run(vim.uv.cwd()) end, { desc = "Run All Tests in Solution" })
map("n", "<D-;>r", function() require("neotest").run.run_last() end, { desc = "Repeat Last Test Run" })
map("n", "<D-;>e", dotnet("testrunner"), { desc = "Unit Test Explorer" })

-- .NET extras under <leader>m
map("n", "<leader>mb", dotnet("build_solution_quickfix"), { desc = "Build Solution" })
map("n", "<leader>mr", dotnet("run_profile_default"), { desc = "Run With Profile" })
map("n", "<leader>md", dotnet("debug_profile_default"), { desc = "Debug With Profile" })
map("n", "<leader>mt", dotnet("testrunner"), { desc = "Test Explorer" })
map("n", "<leader>mp", dotnet("add_package"), { desc = "NuGet: Add Package" })
map("n", "<leader>mP", dotnet("remove_package"), { desc = "NuGet: Remove Package" })
map("n", "<leader>mo", dotnet("outdated"), { desc = "NuGet: Outdated" })
map("n", "<leader>mn", dotnet("new"), { desc = "New Project/Item" })
map("n", "<leader>ms", dotnet("secrets"), { desc = "User Secrets" })
map("n", "<leader>me", dotnet("diagnostic_errors"), { desc = "Solution Errors" })
map("n", "<leader>mc", dotnet("clean"), { desc = "Clean" })
map("n", "<leader>mR", dotnet("restore"), { desc = "Restore" })
map("n", "<leader>mx", dotnet("terminal_toggle"), { desc = "Toggle .NET Terminal" })
