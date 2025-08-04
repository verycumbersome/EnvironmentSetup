#!/usr/bin/env bash
set -euo pipefail

# ── Config ──────────────────────────────────────────────────────────
VIM_PLUG_URL="https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"
REPO_BASE="https://raw.githubusercontent.com/verycumbersome/EnvironmentSetup/main"
ZSH_AUTOCOMP_URL="https://github.com/marlonrichert/zsh-autocomplete.git"
ZSH_THEME_NAME="agnoster"
# ────────────────────────────────────────────────────────────────────

echo "[*] Updating package lists and installing packages ..."
sudo apt-get update -qq
sudo apt-get install -y --no-install-recommends vim git curl zsh tmux

echo "[*] Installing vim-plug ..."
curl -fsSL "$VIM_PLUG_URL" -o "${HOME}/.vim/autoload/plug.vim" --create-dirs

echo "[*] Fetching dot-files ..."
curl -fsSL "${REPO_BASE}/dotfiles/vimrc" -o "${HOME}/.vimrc"

echo "[*] Installing Vim plugins (non-interactive) ..."
vim -Es -u NONE \
  -c "source ~/.vimrc" \
  -c "PlugInstall --sync" \
  -c "qa" || true   # ignore first-run colour-scheme errors

# ── Oh-My-Zsh + plugins ────────────────────────────────────────────
if ! command -v omz >/dev/null; then
  echo "[*] Installing Oh-My-Zsh ..."
  RUNZSH=no KEEP_ZSHRC=yes \
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
PLUGIN_DIR="$ZSH_CUSTOM/plugins/zsh-autocomplete"

if [ ! -d "$PLUGIN_DIR" ]; then
  echo "[*] Installing zsh-autocomplete ..."
  git clone --depth 1 "$ZSH_AUTOCOMP_URL" "$PLUGIN_DIR"
fi

# Add plugin to ~/.zshrc if not present
#if ! grep -q "zsh-autocomplete" "$HOME/.zshrc"; then
  #echo "[*] Enabling zsh-autocomplete plugin ..."
  #sed -i 's/^plugins=(\(.*\))/plugins=(\1 zsh-autocomplete)/' "$HOME/.zshrc"
#fi

# Set theme to agnoster
echo "[*] Setting Oh-My-Zsh theme to ${ZSH_THEME_NAME} ..."
if grep -q '^ZSH_THEME=' "$HOME/.zshrc"; then
  sed -i "s/^ZSH_THEME=.*/ZSH_THEME=\"${ZSH_THEME_NAME}\"/" "$HOME/.zshrc"
else
  echo "ZSH_THEME=\"${ZSH_THEME_NAME}\"" >> "$HOME/.zshrc"
fi

# ── System-wide zsh defaults ───────────────────────────────────────
echo "[*] Making zsh the default shell system-wide ..."
ZSH_BIN="$(command -v zsh)"

# 1. /etc/shells
if ! grep -qxF "$ZSH_BIN" /etc/shells; then
  echo "$ZSH_BIN" | sudo tee -a /etc/shells >/dev/null
fi

# 2. Current user
sudo chsh -s "$ZSH_BIN" "$USER"

# 3. Root (comment out if not desired)
sudo chsh -s "$ZSH_BIN" root

# 4. Future users
sudo sed -i "s|^DSHELL=.*|DSHELL=$ZSH_BIN|" /etc/adduser.conf
sudo sed -i "s|^SHELL=.*|SHELL=$ZSH_BIN|" /etc/default/useradd

# 5. Ensure tmux panes spawn zsh
if [ ! -f /etc/tmux.conf ] || ! grep -q "default-shell" /etc/tmux.conf; then
  echo "set-option -g default-shell $ZSH_BIN" | sudo tee -a /etc/tmux.conf >/dev/null
fi
# ───────────────────────────────────────────────────────────────────

echo "[✓] Completed. Log out and back in (or reboot) so every session—including tmux—uses zsh."

