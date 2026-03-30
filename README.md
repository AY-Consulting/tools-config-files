# tools-config-files
A repository to store configuration files for various tools (NIX, Starship, etc.)

# Nix + Home Manager Setup

## 1. Install Nix
```bash
sh <(curl -L https://nixos.org/nix/install) --daemon
```
Restart your terminal.

## 2. Enable Flakes
```bash
echo "experimental-features = nix-command flakes" | sudo tee -a /etc/nix/nix.conf
sudo systemctl restart nix-daemon
```

## 3. Install Home Manager
```bash
nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
nix-channel --update
nix-shell '<home-manager>' -A install
```

## 4. Clone this repo
```bash
git clone git@github.com:AY-Consulting/tools-config-files.git ~/Repos/AY-Consulting/tools-config-files
```

## 5. Symlink home.nix
```bash
rm ~/.config/home-manager/home.nix
ln -s ~/Repos/AY-Consulting/tools-config-files/home.nix ~/.config/home-manager/home.nix
```

## 6. Apply
```bash
mv ~/.zshrc ~/.zshrc.bak  # backup existing zshrc if needed
home-manager switch
```

## Updating
Edit `home.nix` in the repo, then run:
```bash
home-manager switch
```
