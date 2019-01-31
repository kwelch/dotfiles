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

# PATH ALTERATIONS
### add node_modules first to prefer local bin over glbally installed
PATH="./node_modules/.bin:$PATH";

#COLORS
RED=$(tput setaf 1);
GREEN=$(tput setaf 2);
YELLOW=$(tput setaf 3);
BLUE=$(tput setaf 4);
PINK=$(tput setaf 5);
TEAL=$(tput setaf 6);
WHITE=$(tput setaf 7);

# adds git autocomplete to bash
if [ -f `brew --prefix`/etc/bash_completion.d/git-completion.bash ]; then
  . `brew --prefix`/etc/bash_completion.d/git-completion.bash
fi

# history size
HISTSIZE=5000
HISTFILESIZE=10000

# Add command to PROMPT_COMMAND (runs before each command)
# Makes sure ithe command is not already in PROMPT_COMMAND
addToPromptCommand() {
  if [[ ":$PROMPT_COMMAND:" != *":$1:"* ]]; then
    PROMPT_COMMAND="${PROMPT_COMMAND:+"$PROMPT_COMMAND:"}$1"
  fi
}

# Set iTerm title to show current directory
if [ $ITERM_SESSION_ID ]; then
  addToPromptCommand 'echo -ne "\033];${PWD##*/}\007"'
fi

[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
nvm use --silent

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


function git_branch {
  # Shows the current branch if in a git repository
  git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\ \(\1\)/';
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
PS1="${BLUE}\w${GREEN}\$(git_branch)${WHITE}\n\D{%T} $(rand_element 🔥 🚀 🍕 👻 🐙 )  $ ";
