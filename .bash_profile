#!/usr/bash

export TERM=xterm-256color

export REPO_HOME=$HOME/eventbrite;
export EDITOR="code --wait";

# variable for EB
export BAY_HOME=$REPO_HOME/docker-dev;
export ARCANIST_INSTALL_DIR=/Users/kwelch/.evbdevtools
source $ARCANIST_INSTALL_DIR/devtools/scripts/devenv_bash/arcanist_helpers.sh

export NVM_DIR=~/.nvm
source /usr/local/opt/nvm/nvm.sh
nvm use

#COLORS
RED=$(tput setaf 1);
GREEN=$(tput setaf 2);
YELLOW=$(tput setaf 3);
BLUE=$(tput setaf 4);
PINK=$(tput setaf 5);
TEAL=$(tput setaf 6);
WHITE=$(tput setaf 7);
RESET=$(tput sgr0);

# adds git autocomplete to bash
if [ -f `brew --prefix`/etc/bash_completion.d/git-completion.bash ]; then
  . `brew --prefix`/etc/bash_completion.d/git-completion.bash
fi

# history size
HISTSIZE=5000
HISTFILESIZE=10000
# alias hub as git (allows for extra fun commands)
eval "$(hub alias -s)"

# alias
# long format with additional seetings
### F = adds special character to indicate useage
### G for color
### l = long list format,
### A = skips `.` & `..`
### h = use M/K/G for size
alias ll='ls -FGlAh'
alias mkdir='mkdir -pv' # p = create dirs missing in path, v=list as they are created
alias cp='cp -iv' # i = interatice, v = verbose
alias ~="cd ~" # go home
alias path='echo -e ${PATH//:/\\n}' #list path with, each directory new lined

# make then cd into directory
mkcd() {
        if [ $# != 1 ]; then
                echo "Usage: mkcd <dir>"
        else
                mkdir -p $1 && cd $1
        fi
}

init_repo() {
  mkcd $1
  git init
  npm init -y
  npx license mit > LICENSE
  npx gitignore node
  npx covgen kwelch0626@gmail.com
}

function is_working_dir_dirty {
  [[ "$(git status --porcelain)" == "" ]] && echo "" || echo "*"
}

function git_branch {
  branch_color="$([ "$(is_working_dir_dirty)" == "" ] && echo $GREEN || echo $RED)"
  # Shows the current branch if in a git repository
  git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e "s@* \(.*\)@${branch_color}\ \(\1$(is_working_dir_dirty)\)@";
}
rand() {
  printf $((  $1 *  RANDOM  / 32767   ))
}
rand_element () {
  local -a th=("$@")
  unset th[0]
  printf $'%s\n' "${th[$(($(rand "${#th[*]}")+1))]}"
}

#Default Prompt
PS1="\[${BLUE}\]\w\$(git_branch)\[${RESET}\]\n\D{%T} $ ";

export PATH="$HOME/.cargo/bin:$PATH"

[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*
