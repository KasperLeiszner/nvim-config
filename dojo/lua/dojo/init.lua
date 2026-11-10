local belts = require("dojo.challenges")

local M = {}
local ns = vim.api.nvim_create_namespace("dojo")
local data_path = vim.fn.stdpath("data") .. "/dojo.json"
local S = { keys = 0, token = 0 }

local RANKS = {
  { xp = 0, name = "Novice" },
  { xp = 100, name = "Apprentice" },
  { xp = 300, name = "Journeyman" },
  { xp = 600, name = "Adept" },
  { xp = 1000, name = "Expert" },
  { xp = 1600, name = "Master" },
  { xp = 2500, name = "Vim Sensei" },
}

local PRAISE = { "Nice!", "Clean!", "Smooth.", "Sharp!", "Ninja moves.", "Rider who?", "Keyboard wizardry.", "Flawless." }

local IGNORED_KEYS = { ["<F1>"] = true, ["<F2>"] = true, ["<F3>"] = true, ["<F4>"] = true, ["<Ignore>"] = true }

local function rank(xp)
  local current, next_rank = RANKS[1], RANKS[2]
  for i, r in ipairs(RANKS) do
    if xp >= r.xp then current, next_rank = r, RANKS[i + 1] end
  end
  return current, next_rank
end

local function load()
  local ok, d = pcall(function() return vim.json.decode(table.concat(vim.fn.readfile(data_path), "\n")) end)
  d = ok and type(d) == "table" and d or {}
  d.xp, d.best, d.streak = d.xp or 0, d.best or {}, d.streak or 0
  return d
end

local function save(d) vim.fn.writefile({ vim.json.encode(d) }, data_path) end

local function bump_streak(d)
  local today = os.date("%Y-%m-%d")
  if d.last_day == today then return end
  local yesterday = os.date("%Y-%m-%d", os.time() - 86400)
  d.streak = d.last_day == yesterday and d.streak + 1 or 1
  d.last_day = today
end

local function stars_str(n) return ("★"):rep(n) .. ("☆"):rep(3 - n) end

local function count_keys(keys)
  local trans = vim.fn.keytrans(vim.api.nvim_replace_termcodes(keys, true, true, true))
  local n, i = 0, 1
  while i <= #trans do
    local special = trans:match("^<[^<>]+>", i)
    i = i + (special and #special or vim.str_utf_end(trans, i) + 1)
    n = n + 1
  end
  return n
end

local function normalize(keys) return vim.fn.keytrans(vim.api.nvim_replace_termcodes(keys, true, true, true)) end

local function par(ch) return ch.par or count_keys(ch.solution) end

local function score(keys, p)
  if keys <= p then return 3 end
  if keys <= math.ceil(p * 1.5) + 1 then return 2 end
  return 1
end

local function id(bi, ci) return belts[bi].id .. "/" .. ci end

local function col_of(line, spec)
  if spec == "$" then return math.max(#line - 1, 0) end
  if type(spec) == "number" then return spec end
  if type(spec) == "string" then return (line:find(spec, 1, true) or 1) - 1 end
  return 0
end

local function highlights()
  vim.api.nvim_set_hl(0, "DojoTarget", { bg = "#ff9e64", fg = "#1a1b26", bold = true, default = true })
  vim.api.nvim_set_hl(0, "DojoTargetLine", { bg = "#3b2f2a", default = true })
  vim.api.nvim_set_hl(0, "DojoTitle", { fg = "#bb9af7", bold = true, default = true })
  vim.api.nvim_set_hl(0, "DojoHint", { fg = "#e0af68", italic = true, default = true })
  vim.api.nvim_set_hl(0, "DojoGood", { fg = "#9ece6a", bold = true, default = true })
  vim.api.nvim_set_hl(0, "DojoQuiz", { fg = "#7dcfff", bold = true, default = true })
end

local function valid_win(w) return w and vim.api.nvim_win_is_valid(w) end

local function new_buf(lines)
  local buf = vim.api.nvim_create_buf(false, true)
  vim.bo[buf].bufhidden = "wipe"
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].filetype = "dojo"
  vim.bo[buf].shiftwidth = 4
  vim.bo[buf].tabstop = 4
  vim.bo[buf].expandtab = true
  vim.bo[buf].smartindent = false
  vim.bo[buf].indentexpr = ""
  vim.bo[buf].commentstring = "// %s"
  vim.b[buf].minipairs_disable = true
  vim.b[buf].completion = false
  vim.b[buf].autoformat = false
  pcall(vim.treesitter.start, buf, "c_sharp")
  return buf
end

local function plain_window(win)
  vim.wo[win].number = false
  vim.wo[win].relativenumber = false
  vim.wo[win].signcolumn = "no"
  vim.wo[win].statuscolumn = ""
  vim.wo[win].foldcolumn = "0"
  vim.wo[win].cursorline = false
  vim.wo[win].winfixheight = true
end

local function ensure_tab()
  if S.tab and vim.api.nvim_tabpage_is_valid(S.tab) and valid_win(S.win) then
    vim.api.nvim_set_current_tabpage(S.tab)
    return
  end
  vim.cmd("tabnew")
  S.tab = vim.api.nvim_get_current_tabpage()
  S.win = vim.api.nvim_get_current_win()
end

local function reset_windows()
  for _, w in ipairs(vim.api.nvim_tabpage_list_wins(S.tab)) do
    if w ~= S.win and vim.api.nvim_win_get_config(w).relative == "" then pcall(vim.api.nvim_win_close, w, true) end
  end
  vim.api.nvim_win_call(S.win, function() vim.cmd("diffoff") end)
end

local function update_bar()
  if not valid_win(S.win) or not S.ch or S.ch.quiz then return end
  local r = rank(S.data.xp)
  vim.wo[S.win].winbar = string.format(
    " ⌨  %d / par %d   %s   %%#DojoTitle#✦ %d XP · %s%%*   🔥 %d",
    S.keys, par(S.ch), stars_str(score(S.keys, par(S.ch))), S.data.xp, r.name, S.data.streak
  )
end

local function render_info(hint)
  local belt, ch = belts[S.belt], S.ch
  local lines = {
    string.format(" %s %s  ·  %d/%d", belt.icon, belt.title, S.idx, #belt.challenges),
    " " .. (ch.quiz and "What do you press in Neovim for this Rider action?" or ch.task),
    ch.quiz and " Type the keys (all valid mappings count)  ·  <Esc> back to menu"
      or string.format(" Par %d keys  ·  F1 hint   F2 restart   F3 skip   F4 menu", par(ch)),
  }
  if hint then table.insert(lines, " 💡 " .. hint) end
  vim.bo[S.info].modifiable = true
  vim.api.nvim_buf_set_lines(S.info, 0, -1, false, lines)
  vim.bo[S.info].modifiable = false
  vim.api.nvim_buf_set_extmark(S.info, ns, 0, 0, { end_col = #lines[1], hl_group = "DojoTitle" })
  if hint then vim.api.nvim_buf_set_extmark(S.info, ns, 3, 0, { end_col = #lines[4], hl_group = "DojoHint" }) end
  if valid_win(S.info_win) then vim.api.nvim_win_set_height(S.info_win, #lines) end
end

local function solved()
  local ch = S.ch
  if ch.goal then
    local p = vim.api.nvim_win_get_cursor(S.win)
    return p[1] == S.goal[1] and (S.goal[2] == nil or p[2] == S.goal[2])
  end
  return vim.deep_equal(vim.api.nvim_buf_get_lines(S.buf, 0, -1, false), ch.target)
end

local function advance(token, delay)
  vim.defer_fn(function()
    if S.token == token and valid_win(S.win) then M.start(S.belt, S.idx + 1) end
  end, delay)
end

local function complete(stars, detail)
  S.done = true
  local d = load()
  local key = id(S.belt, S.idx)
  local prev = d.best[key] or 0
  local gained = stars > prev and (stars - prev) * 10 or 2
  local before = rank(d.xp)
  d.xp = d.xp + gained
  d.best[key] = math.max(prev, stars)
  bump_streak(d)
  save(d)
  S.data = d
  local after = rank(d.xp)
  local lines = { string.format("%s   +%d XP", stars_str(stars), gained), detail }
  if stars < 3 and S.ch.solution then table.insert(lines, "Par solution: " .. S.ch.solution) end
  vim.notify(table.concat(lines, "\n"), vim.log.levels.INFO, { title = "🥋 " .. PRAISE[math.random(#PRAISE)] })
  if after.name ~= before.name then
    vim.notify("You are now: " .. after.name, vim.log.levels.INFO, { title = "🎉 Rank up!" })
  end
  update_bar()
  if vim.fn.mode() ~= "n" then vim.cmd("stopinsert") end
  advance(S.token, stars == 3 and 900 or 2200)
end

local function check()
  if S.done or not S.ch or S.ch.quiz or not vim.api.nvim_buf_is_valid(S.buf) then return end
  if vim.fn.mode() ~= "n" then return end
  if solved() then return complete(score(S.keys, par(S.ch)), string.format("%d keys (par %d)", S.keys, par(S.ch))) end
  if not S.hinted and S.keys > par(S.ch) * 2 + 2 then M.hint() end
end

local function on_key(_, typed)
  if not S.ch or S.done or S.ch.quiz or not typed or typed == "" then return end
  if vim.api.nvim_get_current_buf() ~= S.buf then return end
  local k = vim.fn.keytrans(typed)
  if IGNORED_KEYS[k] or k:find("Mouse") or k:find("ScrollWheel") or k:find("^<Focus") then return end
  S.keys = S.keys + 1
  vim.schedule(update_bar)
end

local function run_quiz(ch, token)
  local answers = vim.tbl_map(normalize, ch.answers)
  local typed = ""
  while S.token == token do
    if valid_win(S.win) then vim.wo[S.win].winbar = " ⌨  " .. (typed == "" and "…" or typed) end
    vim.cmd.redraw()
    local ok, c = pcall(vim.fn.getcharstr)
    if not ok or S.token ~= token then return end
    local k = vim.fn.keytrans(c)
    if k == "<Esc>" then return M.menu() end
    typed = typed .. k
    if vim.tbl_contains(answers, typed) then
      return complete(3, "Correct: " .. typed .. "\nAll options: " .. table.concat(answers, "   "))
    end
    local is_prefix = vim.iter(answers):any(function(a) return vim.startswith(a, typed) end)
    if not is_prefix then
      S.done = true
      vim.notify("You typed " .. typed .. "\nAnswer: " .. table.concat(answers, "   or   "), vim.log.levels.WARN, { title = "🥋 Not quite" })
      return advance(token, 2500)
    end
  end
end

local function set_buffer_keys(buf)
  local o = { buffer = buf, nowait = true }
  vim.keymap.set("n", "<F1>", M.hint, vim.tbl_extend("force", o, { desc = "Dojo hint" }))
  vim.keymap.set("n", "<F2>", M.restart, vim.tbl_extend("force", o, { desc = "Dojo restart" }))
  vim.keymap.set("n", "<F3>", M.skip, vim.tbl_extend("force", o, { desc = "Dojo skip" }))
  vim.keymap.set("n", "<F4>", M.menu, vim.tbl_extend("force", o, { desc = "Dojo menu" }))
end

function M.start(bi, ci)
  local belt = belts[bi]
  if not belt then return M.menu() end
  local ch = belt.challenges[ci]
  if not ch then return M.belt_done(bi) end

  ensure_tab()
  reset_windows()
  S.token = S.token + 1
  S.belt, S.idx, S.ch, S.keys, S.done, S.hinted, S.goal = bi, ci, ch, 0, false, false, nil
  S.data = load()

  local lines = ch.quiz and { "", "", "     Rider:  " .. ch.task, "" } or vim.deepcopy(ch.text)
  local old = vim.api.nvim_win_get_buf(S.win)
  S.buf = new_buf(lines)
  vim.api.nvim_win_set_buf(S.win, S.buf)
  if vim.api.nvim_buf_is_valid(old) and old ~= S.buf and vim.api.nvim_buf_get_name(old) == "" and not vim.bo[old].modified then
    pcall(vim.api.nvim_buf_delete, old, { force = true })
  end
  vim.wo[S.win].foldenable = false
  vim.wo[S.win].wrap = false
  vim.wo[S.win].relativenumber = true
  set_buffer_keys(S.buf)

  local top = S.win
  if ch.target then
    S.target = new_buf(ch.target)
    vim.bo[S.target].modifiable = false
    S.target_win = vim.api.nvim_open_win(S.target, false, { split = "above", win = S.win, height = #ch.target + 1 })
    vim.wo[S.target_win].winbar = "%#DojoGood# 🎯 Make your buffer look like this"
    vim.wo[S.target_win].foldenable = false
    for _, w in ipairs({ S.target_win, S.win }) do
      vim.api.nvim_win_call(w, function() vim.cmd("diffthis") end)
      vim.wo[w].foldenable = false
    end
    top = S.target_win
  end

  S.info = new_buf({})
  vim.treesitter.stop(S.info)
  S.info_win = vim.api.nvim_open_win(S.info, false, { split = "above", win = top, height = 4 })
  plain_window(S.info_win)
  render_info()

  vim.api.nvim_set_current_win(S.win)
  vim.cmd("stopinsert")

  if ch.quiz then
    vim.api.nvim_buf_set_extmark(S.buf, ns, 2, 0, { end_col = #lines[3], hl_group = "DojoQuiz" })
    vim.bo[S.buf].modifiable = false
    local token = S.token
    vim.schedule(function() run_quiz(ch, token) end)
    return
  end

  local start = ch.start or { 1, 0 }
  vim.api.nvim_win_set_cursor(S.win, { start[1], col_of(lines[start[1]], start[2]) })

  if ch.goal then
    local row = ch.goal[1]
    local col = ch.goal[2] ~= nil and col_of(lines[row], ch.goal[2]) or nil
    S.goal = { row, col }
    vim.api.nvim_buf_set_extmark(S.buf, ns, row - 1, 0, { line_hl_group = "DojoTargetLine", virt_text = { { " ◀ target", "DojoHint" } } })
    if col then vim.api.nvim_buf_set_extmark(S.buf, ns, row - 1, col, { end_col = col + 1, hl_group = "DojoTarget", priority = 300 }) end
  end

  local group = vim.api.nvim_create_augroup("dojo_challenge", { clear = true })
  vim.api.nvim_create_autocmd({ "CursorMoved", "TextChanged", "InsertLeave" }, {
    group = group,
    buffer = S.buf,
    callback = function() vim.schedule(check) end,
  })
  update_bar()
end

function M.hint()
  if not S.ch or S.ch.quiz or not vim.api.nvim_buf_is_valid(S.info or -1) then return end
  S.hinted = true
  render_info(S.ch.hint)
end

function M.restart()
  if S.belt then M.start(S.belt, S.idx) end
end

function M.skip()
  if S.belt then M.start(S.belt, S.idx + 1) end
end

local function belt_stars(d, bi)
  local got = 0
  for ci = 1, #belts[bi].challenges do got = got + (d.best[id(bi, ci)] or 0) end
  return got, #belts[bi].challenges * 3
end

local function first_open(d, bi, min)
  for ci = 1, #belts[bi].challenges do
    if (d.best[id(bi, ci)] or 0) < min then return ci end
  end
end

function M.belt_done(bi)
  local d = load()
  local got, max = belt_stars(d, bi)
  local cleared = not first_open(d, bi, 1)
  local title = cleared and ("🥋 " .. belts[bi].title:match("^[^·]+") .. "earned!") or "🥋 End of belt"
  vim.notify(string.format("%d / %d stars", got, max) .. (got < max and "\nReplay for 3 stars on every drill." or "\nPerfect belt!"), vim.log.levels.INFO, { title = title })
  M.menu()
end

function M.continue()
  local d = load()
  for _, min in ipairs({ 1, 3 }) do
    for bi = 1, #belts do
      local ci = first_open(d, bi, min)
      if ci then return M.start(bi, ci) end
    end
  end
  vim.notify("Every drill mastered. You are a Vim Sensei. 🥷", vim.log.levels.INFO, { title = "🥋 Dojo" })
end

function M.stats()
  local d = load()
  local r, next_rank = rank(d.xp)
  local lines = {
    string.format("Rank: %s  ·  %d XP%s", r.name, d.xp, next_rank and string.format("  (%d to %s)", next_rank.xp - d.xp, next_rank.name) or ""),
    string.format("Streak: 🔥 %d day%s", d.streak, d.streak == 1 and "" or "s"),
    "",
  }
  for bi, belt in ipairs(belts) do
    local got, max = belt_stars(d, bi)
    table.insert(lines, string.format("%s %-42s %2d/%d ★", belt.icon, belt.title, got, max))
  end
  vim.notify(table.concat(lines, "\n"), vim.log.levels.INFO, { title = "🥋 Dojo stats" })
end

function M.menu()
  local d = load()
  local items = { { label = "▶  Continue where you left off", action = M.continue } }
  for bi, belt in ipairs(belts) do
    local got, max = belt_stars(d, bi)
    table.insert(items, { label = string.format("%s  %s   %d/%d ★", belt.icon, belt.title, got, max), belt = bi })
  end
  table.insert(items, { label = "📊  Stats", action = M.stats })
  local r = rank(d.xp)
  vim.ui.select(items, {
    prompt = string.format("Neovim Dojo · %s · %d XP · 🔥 %d", r.name, d.xp, d.streak),
    format_item = function(item) return item.label end,
  }, function(choice)
    if not choice then return end
    if choice.action then return choice.action() end
    M.start(choice.belt, first_open(d, choice.belt, 3) or 1)
  end)
end

function M.setup()
  highlights()
  vim.api.nvim_create_autocmd("ColorScheme", { group = vim.api.nvim_create_augroup("dojo_hl", { clear = true }), callback = highlights })
  vim.on_key(on_key, ns)
  local commands = { Dojo = M.menu, DojoContinue = M.continue, DojoHint = M.hint, DojoRestart = M.restart, DojoSkip = M.skip, DojoStats = M.stats }
  for name, fn in pairs(commands) do
    vim.api.nvim_create_user_command(name, function() fn() end, {})
  end
end

M._internal = { S = S, belts = belts, par = par, count_keys = count_keys, normalize = normalize }

return M
