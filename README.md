# Dotfiles

This repository stores my dotfiles

## Installation
1. Run the following commands:
```sh
alias dotfile='/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME'
echo ".cfg" >> .gitignore
git clone --bare https://github.com/DaRubyMiner360/dotfiles.git $HOME/.cfg
mkdir -p .config-backup && dotfile checkout 2>&1 | egrep "\s+\." | awk {'print $1'} | xargs -I{} mv {} .config-backup/{}
dotfile checkout
dotfile config --local status.showUntrackedFiles no
```
2. Run `nvim +PlugInstall +q2`
