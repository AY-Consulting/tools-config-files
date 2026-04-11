# tools-config-files

Configuration files for various tools (Nix, Starship, etc.)

## Repository Structure

```
.
├── nix/
│   ├── flake.nix               # Declares all machines
│   ├── starship.toml           # Shared Starship prompt config
│   ├── bootstrap-nix.sh        # One-shot provisioning script for a fresh Ubuntu VM
│   ├── modules/                # Reusable building blocks
│   │   ├── git.nix             # Git config (shared across all profiles)
│   │   ├── zsh.nix             # Zsh + aliases + Starship (shared across all profiles)
│   │   └── docker-tools.nix   # Docker CLI tools and aliases
│   └── profiles/               # Per-machine configs — pick which modules to include
│       ├── dev-setup.nix       # Dev machine (VSCode, kubectl, terraform, azure-cli)
│       └── dev-hosting.nix    # Ubuntu Docker VM (docker-tools, python, common utils)
├── starship/                   # Starship theme experiments
├── other/
│   └── gmk87-no-ansi.keylayout
└── old/
    └── dev.nix                 # Legacy single-file config (kept for reference)
```

---

# Nix + Home Manager Setup

## Dev Machine (macOS or Linux)

### 1. Install Nix
```bash
sh <(curl -L https://nixos.org/nix/install) --daemon
```
Restart your terminal.

### 2. Enable Flakes
```bash
echo "experimental-features = nix-command flakes" | sudo tee -a /etc/nix/nix.conf
sudo systemctl restart nix-daemon   # Linux
# or: sudo launchctl stop org.nixos.nix-daemon && sudo launchctl start org.nixos.nix-daemon  # macOS
```

### 3. Clone this repo
```bash
git clone git@github.com:AY-Consulting/tools-config-files.git ~/Repos/AY-Consulting/tools-config-files
```

### 4. Apply
```bash
mv ~/.zshrc ~/.zshrc.bak  # backup existing zshrc if needed
nix run home-manager/master -- switch --flake ~/Repos/AY-Consulting/tools-config-files/nix#ay-dev-setup
```

### Updating
Edit any file under `nix/`, then run:
```bash
home-manager switch --flake ~/Repos/AY-Consulting/tools-config-files/nix#ay-dev-setup
```

---

## Ubuntu Docker VM (fresh provision)

Run as root on a fresh Ubuntu 24.04 VM:
```bash
curl -fsSL https://raw.githubusercontent.com/AY-Consulting/tools-config-files/main/nix/bootstrap-nix.sh | bash
```

This script:
1. Creates the `ay-dev-host` user
2. Installs Docker via apt
3. Installs Nix
4. Clones this repo and runs `home-manager switch` automatically

### Updating the VM
```bash
cd ~/tools-config-files
git pull
home-manager switch --flake ./nix#ay-dev-host
```

---

## Adding a New Machine

1. Create a new profile in `nix/profiles/your-machine.nix` and import whichever modules you need
2. Add it to `nix/flake.nix` under `homeConfigurations`
3. Bootstrap with:
```bash
nix run home-manager/master -- switch --flake /path/to/repo/nix#your-machine
```
