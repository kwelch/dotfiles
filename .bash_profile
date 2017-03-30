export TERM=xterm-256color

# PATH ALTERATIONS
## Node
PATH="/usr/local/bin:$PATH:./node_modules/.bin";

#PROMPT STUFF
RED=$(tput setaf 1);
GREEN=$(tput setaf 2);
YELLOW=$(tput setaf 3);
BLUE=$(tput setaf 4);
PINK=$(tput setaf 5);
TEAL=$(tput setaf 6);
WHITE=$(tput setaf 7)

if [ -f $(brew --prefix)/etc/bash_completion ]; then
    source $(brew --prefix)/etc/bash_completion
fi

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
PS1="${BLUE}\w${GREEN}\$(git_branch)${WHITE}\n$(rand_element 💥 🔥 👾 🚀 ⛄️ 🍕 💰 👻 🐙 🌮 )  $ ";
#PS1="${BLUE}\w${GREEN}\$(git_branch)${WHITE}\n$ ";

# history size
HISTSIZE=5000
HISTFILESIZE=10000

if [ $ITERM_SESSION_ID ]; then
  export PROMPT_COMMAND='echo -ne "\033];${PWD##*/}\007"; ':"$PROMPT_COMMAND";
fi
