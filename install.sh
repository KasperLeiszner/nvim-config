#!/usr/bin/env bash
set -euo pipefail

CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/nvim"
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

step() { printf '\n\033[1;35m==> %s\033[0m\n' "$1"; }

if ! command -v brew >/dev/null; then
  echo "Homebrew is required: https://brew.sh" >&2
  exit 1
fi

step "Installing CLI tools"
brew install neovim ripgrep fd fzf lazygit tree-sitter-cli

step "Installing Neovide and JetBrains Mono Nerd Font"
brew install --cask neovide font-jetbrains-mono-nerd-font

if [[ "$REPO_DIR" != "$CONFIG_DIR" ]]; then
  step "Linking $CONFIG_DIR -> $REPO_DIR"
  if [[ -e "$CONFIG_DIR" && ! -L "$CONFIG_DIR" ]]; then
    backup="$CONFIG_DIR.bak-$(date +%Y%m%d%H%M%S)"
    echo "Existing config moved to $backup"
    mv "$CONFIG_DIR" "$backup"
  fi
  mkdir -p "$(dirname "$CONFIG_DIR")"
  ln -sfn "$REPO_DIR" "$CONFIG_DIR"
fi

if command -v dotnet >/dev/null; then
  step "Installing .NET tools (EasyDotnet server, Roslyn LSP)"
  dotnet tool update -g EasyDotnet || dotnet tool install -g EasyDotnet
  dotnet tool update -g roslyn-language-server --prerelease || dotnet tool install -g roslyn-language-server --prerelease
else
  echo "dotnet not found - skipping C# tooling. Install with: brew install --cask dotnet-sdk"
fi

step "Installing plugins from lazy-lock.json"
nvim --headless "+Lazy! restore" +qa

step "Installing Treesitter parsers and Mason tools (about a minute)"
nvim --headless "+TSUpdate" "+sleep 60" +qa

cat <<'MSG'

Done. Open Neovide (or run `neovide`) and:
  - press D on the dashboard (or :Dojo) to start the Neovim Dojo
  - Cmd+T to search everywhere, F12 to go to declaration, Alt+Enter for actions

macOS tip: F5/F9/F10/F11 need Fn unless you enable
System Settings > Keyboard > "Use F1, F2, etc. keys as standard function keys".
MSG
