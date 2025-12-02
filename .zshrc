# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

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

export GPG_TTY=$(tty)

if [ -f "$DOTFILE_REPO/config/shell/init.sh" ]; then
	source "$DOTFILE_REPO/config/shell/init.sh"
fi

[ -f "$HOME/.workrc" ] && source "$HOME/.workrc"
