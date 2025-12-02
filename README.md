# DOTFILES

Personal dotfiles with a reproducible setup flow and modular runtime configuration.

## Getting Started

```sh
git clone https://github.com/kwelch/dotfiles.git ~/_git/dotfiles
cd ~/_git/dotfiles
./setup.sh            # installs tools & configures git (add --force to reinstall)
```

The setup script sources every `tools/*.sh` file and calls its `install_*` function, so adding a new tool only requires dropping a file into that directory.

## Structure

- `tools/` – per-tool installers plus `check_` and `runtime_` helpers
- `config/shell/` – shell-init orchestration, shared functions, startup logging
- `config/git/` – layered gitconfig snippets included via `git config --global include.*`
- `.zshrc` – minimal bootstrap that loads Oh My Zsh and delegates to `config/shell/init.sh`
- `setup.sh` – orchestrates one-time installs; pass `--force` to reinstall

All runtime work happens via the `runtime_*` functions, keeping shell startup fast while still supporting lazy loading and cached startup versions.
