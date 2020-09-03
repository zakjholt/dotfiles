#!/bin/bash

DOTFILE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

declare -a HomeDotfiles=(".hyper.js" ".tmux.conf" ".zshrc")

for filename in ${HomeDotfiles[@]}; do
  echo Installing "$filename"...

  if test -f ~/"$filename"; then
    echo "$filename already exists. Moving to ~/$filename.bak"
    mv ~/"$filename" ~/"filename".bak
  fi
  ln -s "$DOTFILE_DIR"/"$filename" ~/"$filename"
done

## Link init.vim
if test -f ~/.config/nvim/init.vim; then
  echo init.vim already exists. Moving to ~/.config/nvim/init.vim.bak
  mv ~/.config/nvim/init.vim ~/.config/nvim/init.vim.bak
fi

ln -s "$DOTFILE_DIR"/init.vim ~/.config/nvim/init.vim


