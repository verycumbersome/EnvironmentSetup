#!/usr/bin/env bash
set -euo pipefail

#---- config ----------------------------------------------------
VIM_PLUG_URL="https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"
REPO_BASE="https://raw.githubusercontent.com/verycumbersome/EnvironmentSetup/main"
#---------------------------------------------------------------

echo "[*] Updating package lists and installing packages ..."
sudo apt-get update -qq
sudo apt-get install -y --no-install-recommends vim git curl zsh

echo "[*] Installing vim-plug ..."
curl -fsSL "$VIM_PLUG_URL" -o "${HOME}/.vim/autoload/plug.vim" --create-dirs

echo "[*] Dropping dotfiles ..."
curl -fsSL "${REPO_BASE}/dotfiles/.vimrc" -o "${HOME}/.vimrc"
curl -fsSL "${REPO_BASE}/dotfiles/.zshrc" -o "${HOME}/.zshrc"

echo "[*] Installing Vim plugins ..."
vim -E -u ~/.vimrc +PlugInstall +qall

# OPTIONAL: Oh-My-Zsh (comment out if you don’t want it)
if ! command -v omz &>/dev/null; then
  echo "[*] Installing Oh-My-Zsh ..."
  RUNZSH=no KEEP_ZSHRC=yes \
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

echo "[*] Setting default shell to zsh ..."
chsh -s "$(command -v zsh)" "${USER}"

echo "[✓] Done.  Log out and back in (or run: exec zsh)."

