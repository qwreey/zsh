if [[ -e "$HOME/.zsh" ]]; then
    [ -e "$HOME/.zsh/user-lazy.zsh" ] && mv "$HOME/.zsh/user-lazy.zsh" "$HOME/user-lazy.zsh.bak" 
    [ -e "$HOME/.zsh/user-after.zsh" ] && mv "$HOME/.zsh/user-after.zsh" "$HOME/user-after.zsh.bak"
    [ -e "$HOME/.zsh/user-before.zsh" ] && mv "$HOME/.zsh/user-before.zsh" "$HOME/user-before.zsh.bak"
    [ -e "$HOME/.zsh/user-p10k.zsh" ] && mv "$HOME/.zsh/user-p10k.zsh" "$HOME/user-p10k.zsh.bak"
    mv "$HOME/.zsh/omz/custom" "$HOME/omz-custom.bak"
    rm -rf $HOME/.zsh
fi
git clone https://github.com/qwreey75/zsh $HOME/.zsh --depth 1 --recursive
[ -e "$HOME/user-lazy.zsh.bak" ] && mv "$HOME/user-lazy.zsh.bak" "$HOME/.zsh/user-lazy.zsh" 
[ -e "$HOME/user-after.zsh.bak" ] && mv "$HOME/user-after.zsh.bak" "$HOME/.zsh/user-after.zsh"
[ -e "$HOME/user-before.zsh.bak" ] && mv "$HOME/user-before.zsh.bak" "$HOME/.zsh/user-before.zsh"
[ -e "$HOME/user-p10k.zsh.bak" ] && mv "$HOME/user-p10k.zsh.bak" "$HOME/.zsh/user-p10k.zsh"
[ -e "$HOME/omz-custom.bak" ] && mv "$HOME/omz-custom.bak" "$HOME/.zsh/omz/custom"

[ -e "$HOME/.zshrc" ] && mv "$HOME/.zshrc" "$HOME/.zshrc.bak" && echo "Backup ~/.zshrc into ~/.zshrc.bak"
cp $HOME/.zsh/.zshrc $HOME
source $HOME/.zsh/rc.zsh
source $HOME/.zsh/lazyload.zsh
export NVM_DIR=$HOME/.zsh/nvm
source $HOME/.zsh/nvm/nvm.sh
zcompile_all; echo Recompiled all of zsh
echo Setup nodejs . . .
nvm install node
nvm version current > $HOME/.nvmrc.default
echo nodejs installed!
date -u "+%s" > "$HOME/.zsh/updated-at"
echo restarting . . .
exec zsh
