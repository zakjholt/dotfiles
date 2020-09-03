#!/bin/bash

# DOTFILE_DIR=$(dirname "$0")
DOTFILE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

declare -a HomeDotfiles=(".hyper.js" ".tmux.conf" ".zshrc")

for filename in ${HomeDotfiles[@]}; do
  echo Installing "$filename"...
  rm -rf ~/"$filename"
  ln -s "$DOTFILE_DIR"/"$filename" ~/"$filename"
done

## Link init.vim
ln -s "$DOTFILE_DIR"/init.vim ~/.config/nvim/init.vim


