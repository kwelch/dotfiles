# DOTFILES

Personal dotfiles with a reproducible setup flow and modular runtime configuration.

## Getting Started

```sh
git clone https://github.com/kwelch/dotfiles.git ~/_git/dotfiles
cd ~/_git/dotfiles
./setup.sh            # installs tools & configures git (add --force to reinstall)
```

The setup script sources every `tools/*.sh` file and calls its `install_*` function, so adding a new tool only requires dropping a file into that directory.

## Work Overlays

Corporate or machine-specific tweaks live in a separate dotfile repo and are layered on top of this one at shell startup:

1. Clone the work repo (for example `~/work/dotfiles`) and run its `./setup.sh`.
2. Add `export DOTFILE_WORK_REPO=~/work/dotfiles` to `~/.workrc` (or any file sourced before `.zshrc`).
3. Optionally set `DOTFILE_WORK_GITDIR` (defaults to `~/work/`) so `setup.sh` can register a `git config --global includeIf.gitdir:<pattern>.path` entry pointing at the work gitconfig.
4. Open a new shell; `.zshrc` loads this repo first, then sets `DOTFILE_REPO` to the work repo while it sources `config/shell/init.sh` from the overlay. Work-specific `tools/` scripts and overrides run without touching the public files.

When `DOTFILE_WORK_REPO` points to a valid repo the runtime automatically sources matching `tools/*.sh` files after their base counterparts, so overriding a tool is as simple as duplicating the filename in the work tree.

## Structure

- `tools/` – per-tool installers plus `check_` and `runtime_` helpers
- `config/shell/` – shell-init orchestration, shared functions, startup logging
- `config/git/` – layered gitconfig snippets included via `git config --global include.*`
- `.zshrc` – minimal bootstrap that loads Oh My Zsh and delegates to `config/shell/init.sh`
- `setup.sh` – orchestrates one-time installs; pass `--force` to reinstall

All runtime work happens via the `runtime_*` functions, keeping shell startup fast while still supporting lazy loading and cached startup versions.
