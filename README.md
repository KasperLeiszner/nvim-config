# nvim

LazyVim setup tuned for people coming from **JetBrains Rider** (Visual Studio OSX keymap + IdeaVim), with first-class C#/.NET support and a built-in game for learning Vim.

- **Neovide** GUI so Cmd shortcuts work like in Rider
- **Roslyn LSP + easy-dotnet**: build, run, debug, test explorer, NuGet, `dotnet new` templates
- **Copilot** inline suggestions (Tab to accept), Copilot Chat
- **Dojo**: belt-based Vim katas with XP, stars and streaks (`:Dojo`)

## Install (macOS)

```bash
git clone https://github.com/KasperLeiszner/nvim-config.git ~/.config/nvim
~/.config/nvim/install.sh
```

Cloning anywhere else works too: the script symlinks it into `~/.config/nvim` and backs up any existing config.
The script installs Neovim, Neovide, ripgrep, fd, fzf, lazygit, tree-sitter CLI, JetBrains Mono Nerd Font, and the .NET tools (`EasyDotnet`, `roslyn-language-server`). Plugins are pinned by `lazy-lock.json`.

## Rider → Neovim cheat sheet

| Rider action | Rider key | Neovim (Neovide) | Vim / LazyVim native |
|---|---|---|---|
| Search Everywhere | Cmd+T | Cmd+T | `<Space><Space>` |
| Go to File / Type / Symbol | Cmd+Shift+T / Cmd+O / Cmd+Shift+Alt+T | same | `<Space>ff` / `<Space>sS` |
| Recent Files | Ctrl+, | Ctrl+, | `<Space>fr` |
| File Structure | Alt+\ | Alt+\ | `<Space>ss` |
| Go to Declaration | F12 | F12 | `gd`, `<Space>gd` |
| Go to Implementation | Alt+End | Alt+End | `gI`, `<Space>gi` |
| Find / Show Usages | Shift+F12 | Shift+F12 | `gr`, `<Space>gu` |
| Back / Forward | Cmd+- / Cmd+Shift+- | same | `<C-o>` / `<C-i>`, `<Space>gb` / `<Space>gf` |
| Show Intention Actions | Alt+Enter | Alt+Enter | `<Space>ca` |
| Rename | Cmd+R R | Cmd+R R | `<Space>cr` |
| Extract Method / Refactor This | Cmd+R M / Cmd+Shift+R | same | `<Space>ca` |
| Reformat Code | Cmd+Alt+Enter, Cmd+K D | same | `<Space>cf` |
| Comment line | Cmd+Alt+/, Cmd+K C | same | `gcc` |
| Quick Documentation | Cmd+K I | Cmd+K I | `K` |
| Next / previous error | Alt+PgDn / Alt+PgUp | same | `]e` / `[e` |
| Find / Find in Files / Replace in Files | Cmd+F / Cmd+Shift+F / Cmd+Shift+H | same | `/` / `<Space>/` / `<Space>sr` |
| Solution Explorer | Cmd+1 | Cmd+1 | `<Space>e` |
| Terminal | Cmd+Ctrl+1 | Cmd+Ctrl+1 | `<C-/>` |
| Git | — | Cmd+0 | `<Space>gg` (lazygit) |
| New file from template | Cmd+N | Cmd+N | `<Space>mn` |
| Build Solution | Cmd+Shift+B | Cmd+Shift+B | `<Space>mb` |
| Run / Debug | Ctrl+F5 / Alt+F5 | same | `<Space>mr` / `<Space>md` (pick launch profile) |
| Resume / start debugging | F5 | F5 | `<Space>dc` |
| Stop | Shift+F5 | Shift+F5 | `<Space>dt` |
| Toggle breakpoint | F9 | F9 | `<Space>db` |
| Step over / into / out | F10 / F11 / Shift+F11 | same | `<Space>dO` / `<Space>di` / `<Space>do` |
| Run / debug tests at cursor | Cmd+; T / Cmd+; D | same | `<Space>tr` / `<Space>td` |
| Run all tests | Cmd+; L | Cmd+; L | `<Space>tT` |
| Unit Test Explorer | — | Cmd+; E | `<Space>mt` |
| NuGet add / remove / outdated | — | — | `<Space>mp` / `<Space>mP` / `<Space>mo` |
| Copilot accept | Tab | Tab | Tab |
| Save / Save All / Close tab | Cmd+S / Cmd+Shift+S / Cmd+W | same | `:w` / `:wa` / `<Space>bd` |

Your old `.ideavimrc` leader maps (`<Space>gd gy gi gu gb gf`, `<Space><Space>`) work the same. LazyVim's git blame and file history moved to `<Space>gB` and `<Space>gF`.
All `.NET` commands live under `<Space>m` (press it and wait for the which-key menu).

macOS: function keys need Fn unless you enable *System Settings → Keyboard → Use F1, F2, etc. keys as standard function keys*.

## Dojo

`:Dojo`, `<Space>k`, or `D` on the start screen.

Six belts, 65 drills: motions, operators, counts & dot-repeat, text objects, search/replace & macros, and a Black Belt quiz that maps Rider actions to Neovim keys. Every drill has a par keystroke count; hit par for ★★★. XP, rank and daily streak are saved in `~/.local/share/nvim/dojo.json`.

In a drill: `F1` hint · `F2` restart · `F3` skip · `F4` menu. `:DojoStats` shows progress.

## Layout

```
lua/config/      options, keymaps (Rider bindings), lazy bootstrap
lua/plugins/     dotnet.lua (Roslyn, easy-dotnet, neotest), dojo.lua
dojo/lua/dojo/   the game: init.lua (engine), challenges.lua (drills)
lazyvim.json     enabled LazyVim extras
install.sh       one-shot macOS setup
```
