#!/usr/bin/env bash
BASEDIR=$(dirname "$0")

ln -i $PWD/$BASEDIR/.bash_profile ~/.bash_profile
ln -i $PWD/$BASEDIR/.gitignore_global ~/.gitignore_global
ln -i $PWD/$BASEDIR/.gitconfig ~/.gitconfig
