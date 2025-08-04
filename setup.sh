#!/usr/bin/env bash
set -euo pipefail

# ---- config -------------------------------------------------
VIM_PLUG_URL="https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"
REPO_BASE="https://raw.githubusercontent.com/verycumbersome/EnvironmentSetup/main"
ZSH_AUTOCOMP_URL="https://github.com/marlonrichert/zsh-autocomplete.git"
# ------------------------------------------------------------

echo "[*] Updating package lists and installing packages ..."
sudo apt-get update -qq
sudo apt-get install -y --no-install-recommends vim git curl zsh

echo "[*] Installing vim-plug ..."
curl -fsSL "$VIM_PLUG_URL" -o "${HOME}/.vim/autoload/plug.vim" --create-dirs

echo "[*] Dropping dotfiles ..."
curl -fsSL "${REPO_BASE}/dotfiles/.vimrc" -o "${HOME}/.vimrc"

echo "[*] Installing Vim plugins ..."
vim -E -u ~/.vimrc +PlugInstall +qall

# ---- Oh-My-Zsh ---------------------------------------------
if ! command -v omz &>/dev/null; then
  echo "[*] Installing Oh-My-Zsh ..."
  RUNZSH=no KEEP_ZSHRC=yes \
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

# Install zsh-autocomplete
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
PLUGIN_DIR="$ZSH_CUSTOM/plugins/zsh-autocomplete"
if [ ! -d "$PLUGIN_DIR" ]; then
  echo "[*] Installing zsh-autocomplete plugin ..."
  git clone --depth=1 "$ZSH_AUTOCOMP_URL" "$PLUGIN_DIR"
fi

# Ensure the plugin is listed in ~/.zshrc
if ! grep -q "zsh-autocomplete" "$HOME/.zshrc"; then
  echo "[*] Adding zsh-autocomplete to plugin list ..."
  sed -i 's/^plugins=(\(.*\))/plugins=(\1 zsh-autocomplete)/' "$HOME/.zshrc"
fi
# ------------------------------------------------------------

echo "[*] Setting default shell to zsh ..."
chsh -s "$(command -v zsh)" "$USER"
exec zsh
echo "[✓] Done."

