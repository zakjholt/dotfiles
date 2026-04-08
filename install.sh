#!/usr/bin/env bash
# Symlink configs from this repo into the usual XDG / home paths.
# Usage: ./install.sh
# On a new machine: git clone <your-repo-url> ~/dotfiles && cd ~/dotfiles && ./install.sh

set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}"

link() {
	local name="$1"
	local target="$2"
	mkdir -p "$(dirname "$target")"
	ln -sfn "${DOTFILES}/${name}" "$target"
	printf 'linked %s -> %s\n' "$name" "$target"
}

link "nvim" "${CONFIG}/nvim"
link "ghostty" "${CONFIG}/ghostty"
link "tmux.conf" "${HOME}/.tmux.conf"
link "taskrc" "${HOME}/.taskrc"

printf '\nDone. Restart Ghostty/tmux/nvim if they are already running.\n'
