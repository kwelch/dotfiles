#!/usr/bash
###############################################################################
##
## THIS FILE IS RUN FOR HEADLESS TERMINALS
##
## NOTE: it is included within the profile file, so it is always used
##
###############################################################################

## PATH ALTERATIONS
# Add node modules to allow calling local node modules without prefix of yarn|npm
PATH="/usr/local/bin:$PATH:./node_modules/.bin";

## Setup NVM
export NVM_DIR=$HOME/.nvm
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
nvm use
