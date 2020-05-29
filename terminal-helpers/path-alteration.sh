#!/usr/sh

# Honestly, I don't know what this does
PATH=$HOME/bin:/usr/local/bin:$PATH

# Add node modules to allow calling local node modules without prefix of yarn|npm
PATH=$PATH:./node_modules/.bin
