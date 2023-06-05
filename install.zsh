[ ! -e "$HOME/.zshrc" ] && cp $HOME/.zsh/.zshrc $HOME
source $HOME/.zsh/rc.zsh
source $HOME/.zsh/lazyload.zsh
export NVM_DIR=$HOME/.zsh/nvm
source $HOME/.zsh/nvm/nvm.sh
omztrim; echo Trimmed zsh libs
zcompile_all; echo Recompiled all of zsh
echo Setup nodejs . . .
nvm install node
nvm version current > $HOME/.nvmrc.default
echo nodejs installed!
echo restarting . . .
exec zsh
