#!/usr/bin/env bash
# bootstrap.sh — run once on a fresh Ubuntu 24.04 VM as root
# Usage: curl -fsSL https://raw.githubusercontent.com/YOU/dotfiles/main/bootstrap.sh | bash
set -euo pipefail

USERNAME="ay-dev-host"
DOTFILES_REPO="https://github.com/YOU/dotfiles.git"   # ← update this
DOTFILES_DIR="/home/$USERNAME/dotfiles"

echo "━━━ [1/6] Creating user $USERNAME ━━━"
if ! id "$USERNAME" &>/dev/null; then
  useradd -m -s /bin/bash "$USERNAME"
  usermod -aG sudo "$USERNAME"
  echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/$USERNAME
fi

echo "━━━ [2/6] Installing system packages (apt) ━━━"
apt update && apt install -y \
  curl \
  xz-utils \
  ca-certificates \
  gnupg \
  sudo \
  zsh

echo "━━━ [3/6] Installing Docker ━━━"
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
  | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg

echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo $VERSION_CODENAME) stable" \
  | tee /etc/apt/sources.list.d/docker.list

apt update && apt install -y \
  docker-ce \
  docker-ce-cli \
  containerd.io \
  docker-compose-plugin

systemctl enable --now docker
usermod -aG docker "$USERNAME"

echo "━━━ [4/6] Installing Nix (multi-user) ━━━"
sh <(curl -L https://nixos.org/nix/install) --daemon --yes
source /etc/profile.d/nix.sh

echo "━━━ [5/6] Cloning dotfiles and installing Home Manager ━━━"
sudo -u "$USERNAME" bash -c "
  source /etc/profile.d/nix.sh
  export NIX_PATH=\$HOME/.nix-defexpr/channels:/nix/var/nix/profiles/per-user/root/channels
  nix-shell -p git --run 'git clone $DOTFILES_REPO $DOTFILES_DIR'
  nix run home-manager/master -- switch --flake $DOTFILES_DIR/nix#$USERNAME
"

echo "━━━ [6/6] Setting default shell to Zsh ━━━"
ZSH_PATH=\$(sudo -u "$USERNAME" bash -c 'source /etc/profile.d/nix.sh && which zsh')
chsh -s "\$ZSH_PATH" "$USERNAME"

echo ""
echo "✓ Done! Log in as $USERNAME and everything is ready."
echo "  Docker: docker ps"
echo "  Update config: cd ~/dotfiles && home-manager switch --flake .#$USERNAME"