#!/bin/bash

DOTFILE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

backup_existing(){
  file=$1

  if test -f $file; then
    echo "$file" already exists. Moving to "$file".bak
    mv "$file" "$file".bak
  fi
}

declare -a HomeDotfiles=(".hyper.js" ".tmux.conf" ".zshrc")

for filename in ${HomeDotfiles[@]}; do
  echo Installing "$filename"...

  backup_existing ~/"$filename"
  ln -s "$DOTFILE_DIR"/"$filename" ~/"$filename"
done

## Link init.vim
backup_existing ~/.config/nvim/init.vim
ln -s "$DOTFILE_DIR"/init.vim ~/.config/nvim/init.vim

## Link config.fish
backup_existing ~/.config/fish/config.fish
ln -s "$DOTFILE_DIR"/config.fish ~/.config/fish/config.fish

## Link starship.toml
backup_existing ~/.config/starship.toml
ln -s "$DOTFILE_DIR/starship.toml" ~/.config/starship.toml

