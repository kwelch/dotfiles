# Path to your oh-my-zsh installation.
export ZSH="${HOME}/.oh-my-zsh"
ZSH_THEME="robbyrussell"
plugins=(git)

export ZSH_COMPLETIONS_DIR="${ZSH_COMPLETIONS_DIR:-$HOME/.zsh/completions}"
mkdir -p "$ZSH_COMPLETIONS_DIR"
typeset -U fpath
fpath=("$ZSH_COMPLETIONS_DIR" $fpath)

source $ZSH/oh-my-zsh.sh

export DOTFILE_REPO="${DOTFILE_REPO:-$HOME/_git/dotfiles}"
if [[ $0 == *".zshrc" ]]; then
	DOTFILE_REPO="$(dirname "$(readlink -f "$0")")"
fi

[ -f "$HOME/.workrc" ] && source "$HOME/.workrc"

DEFAULT_WORK_REPO="$HOME/work/dotfiles"
if [ -z "${DOTFILE_WORK_REPO:-}" ] && [ -d "$DEFAULT_WORK_REPO" ]; then
	DOTFILE_WORK_REPO="$DEFAULT_WORK_REPO"
fi
if [ -n "${DOTFILE_WORK_REPO:-}" ] && [ "$DOTFILE_WORK_REPO" = "$DOTFILE_REPO" ]; then
	DOTFILE_WORK_REPO=""
fi
if [ -n "${DOTFILE_WORK_REPO:-}" ] && [ ! -d "$DOTFILE_WORK_REPO" ]; then
	DOTFILE_WORK_REPO=""
fi
if [ -n "${DOTFILE_WORK_REPO:-}" ]; then
	export DOTFILE_WORK_REPO
	export DOTFILE_OVERLAY_REPO="$DOTFILE_WORK_REPO"
else
	unset DOTFILE_WORK_REPO
	unset DOTFILE_OVERLAY_REPO
fi

export GPG_TTY=$(tty)
export DOTFILE_BASE_REPO="$DOTFILE_REPO"
DOTFILES_INIT_MODE=base
if [ -f "$DOTFILE_REPO/config/shell/init.sh" ]; then
	source "$DOTFILE_REPO/config/shell/init.sh"
fi

if [ -n "${DOTFILE_OVERLAY_REPO:-}" ] && [ "$DOTFILE_OVERLAY_REPO" != "$DOTFILE_REPO" ] \
	&& [ -f "$DOTFILE_OVERLAY_REPO/config/shell/init.sh" ]; then
	prev_dotfile_repo="$DOTFILE_REPO"
	DOTFILES_INIT_MODE=overlay
	DOTFILE_REPO="$DOTFILE_OVERLAY_REPO"
	source "$DOTFILE_OVERLAY_REPO/config/shell/init.sh"
	DOTFILE_REPO="$prev_dotfile_repo"
fi
unset DOTFILES_INIT_MODE
unset prev_dotfile_repo
