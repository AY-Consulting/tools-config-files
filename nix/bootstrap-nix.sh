#!/usr/bin/env bash
# bootstrap.sh — run once on a fresh Ubuntu 24.04 VM as root
# Usage: curl -fsSL https://raw.githubusercontent.com/AY-Consulting/tools-config-files/main/nix/bootstrap-nix.sh | bash
set -euo pipefail

USERNAME="ay-dev-host"
DOTFILES_REPO="https://github.com/AY-Consulting/tools-config-files.git"
DOTFILES_DIR="/home/$USERNAME/repos/tools-config-files"

SSH_PUBKEY="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBaBRTgkdq/lG1Hi78Vft0Vgj/T4U8DDLNWbR+H3PVib andersmyt@gmail.com"

echo "━━━ [1/6] Creating user $USERNAME ━━━"
if ! id "$USERNAME" &>/dev/null; then
  useradd -m -s /bin/bash "$USERNAME"
  usermod -aG sudo "$USERNAME"
  echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/$USERNAME
fi

# Deploy SSH public key with correct permissions
mkdir -p /home/$USERNAME/.ssh
echo "$SSH_PUBKEY" > /home/$USERNAME/.ssh/authorized_keys
chown -R $USERNAME:$USERNAME /home/$USERNAME/.ssh
chmod 700 /home/$USERNAME/.ssh
chmod 600 /home/$USERNAME/.ssh/authorized_keys

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
# Clean up any previous partial Nix install
systemctl stop nix-daemon.socket nix-daemon.service 2>/dev/null || true
pkill -f nix-daemon 2>/dev/null || true
find /etc -name "*.backup-before-nix" -delete 2>/dev/null || true
sh <(curl -L https://nixos.org/nix/install) --daemon --yes
source /etc/profile.d/nix.sh

echo "experimental-features = nix-command flakes" >> /etc/nix/nix.conf
systemctl restart nix-daemon

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
echo "  Update config: cd ~/repos/tools-config-files && home-manager switch --flake .#$USERNAME"