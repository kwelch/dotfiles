export TERM=xterm-256color

# PATH ALTERATIONS
## Node
PATH="/usr/local/bin:$PATH:./node_modules/.bin";
PATH="/usr/local/opt/python/libexec/bin:$PATH";

export EDITOR="code --wait"
export REPO_HOME=$HOME/eventbrite;

# variable for EB
export BAY_HOME=$REPO_HOME/docker-dev;
export ARCANIST_INSTALL_DIR=/Users/kwelch/.evbdevtools
source $ARCANIST_INSTALL_DIR/devtools/scripts/devenv_bash/arcanist_helpers.sh

export NVM_DIR=$HOME/.nvm
source /usr/local/opt/nvm/nvm.sh
nvm use 8

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

export NVM_DIR=$HOME/.nvm
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
nvm use 8
nvm use --delete-prefix v8.11.2 --silent

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

function daily-notes {
    notes_file="$HOME/Documents/notes/daily/`date +%Y%m%d`.md"

    if [ ! -f $notes_file ]; then
        cp "$HOME/Documents/notes/daily-notes-template.md" $notes_file
    fi

    counter=1
    max_days=31
    notes_to_open="$notes_file"
    previous_notes="$HOME/Documents/notes/daily/`date -v-${counter}d +%Y%m%d`.md"
    until [ -f $previous_notes -o $counter -gt $max_days ]; do
        counter=$((counter+1))
        previous_notes="$HOME/Documents/notes/daily/`date -v-${counter}d +%Y%m%d`.md"
    done

    if [ -f $previous_notes ]; then
        notes_to_open="$previous_notes ${notes_to_open}"
    fi

    macdown $notes_to_open
}

function start-day {
    # Pre-cache sudo credentials for 15min
    sudo -v

    for APP in Docker "Google Chrome" Slack ; do
        open -a "$APP"
    done

    daily-notes

    cd $REPO_HOME && update_eb_repos -f
    cd $REPO_HOME/docker-dev && dm_start && bay build profile
    cd $HOME
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
