HEAD_DEFAULT="Install"
function log {
	if [[ -z "$HEAD" ]]; then
		HEAD="$HEAD_DEFAULT"
	fi
	printf "\e[32m[$HEAD]\e[0m %s\n" "$1"
}

# set zshdir
[ -z "$ZSHDIR" ] && ZSHDIR="$HOME/.zsh"
ZSHDIR="$(realpath "$ZSHDIR")"
export ZSHDIR
log "Install started to $ZSHDIR"

# check old files
if [[ -e "$ZSHDIR" ]]; then
    log "Old installation found. backup files"
    [ -e "$ZSHDIR/user-lazy.zsh" ] && mv "$ZSHDIR/user-lazy.zsh" "$HOME/user-lazy.zsh.bak" && HEAD="Backup" log "Backup user-lazy"
    [ -e "$ZSHDIR/user-after.zsh" ] && mv "$ZSHDIR/user-after.zsh" "$HOME/user-after.zsh.bak" && HEAD="Backup" log "Backup user-after"
    [ -e "$ZSHDIR/user-before.zsh" ] && mv "$ZSHDIR/user-before.zsh" "$HOME/user-before.zsh.bak" && HEAD="Backup" log "Backup user-before"
    [ -e "$ZSHDIR/user-p10k.zsh" ] && mv "$ZSHDIR/user-p10k.zsh" "$HOME/user-p10k.zsh.bak" && HEAD="Backup" log "Backup user-p10k"
    mv "$ZSHDIR/omz/custom" "$HOME/omz-custom.bak" && log "Backup omz custom folder"
    [ -e "$ZSHDIR/history" ] && mv "$ZSHDIR/history" "$HOME/history.bak" && log "Backup history"
    rm -rf $ZSHDIR && log "Old installation folder deleted"
fi

# clone files
log "Clone qwreey/zsh"                        ; git clone https://github.com/qwreey75/zsh "$ZSHDIR" --depth 1
log "Clone romkatv/zsh-defer"                 ; git clone https://github.com/romkatv/zsh-defer "$ZSHDIR/defer" --depth 1
log "Clone qwreey/fnvm"                       ; git clone https://github.com/qwreey75/fnvm "$ZSHDIR/fnvm" --depth 1
log "Clone nvm-sh/nvm"                        ; git clone https://github.com/nvm-sh/nvm "$ZSHDIR/nvm" --depth 1
log "Clone ohmyzsh/ohmyzsh"                   ; git clone https://github.com/ohmyzsh/ohmyzsh "$ZSHDIR/omz" --depth 1
log "Clone romkatv/powerlevel10k"             ; git clone https://github.com/romkatv/powerlevel10k "$ZSHDIR/powerlevel10k" --depth 1
log "Clone zsh-users/zsh-syntax-highlighting" ; git clone https://github.com/zsh-users/zsh-syntax-highlighting "$ZSHDIR/zsh-syntax-highlighting" --depth 1
log "Clone zsh-users/zsh-autosuggestions"     ; git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSHDIR/zsh-autosuggestions" --depth 1
log "Install pyenv"
curl https://pyenv.run | PYENV_ROOT="$ZSHDIR/pyenv" bash

# import backups
[ -e "$HOME/.zsh_history" ] && cat "$HOME/.zsh_history" >> "$ZSHDIR/history" && mv ".zsh_history" ".zsh_history.bak" && echo "Backup ~/.zsh_history into ~/.zsh_history.bak, history imported to $ZSHDIR/history"
[ -e "$HOME/user-lazy.zsh.bak" ] && mv "$HOME/user-lazy.zsh.bak" "$ZSHDIR/user-lazy.zsh" 
[ -e "$HOME/user-after.zsh.bak" ] && mv "$HOME/user-after.zsh.bak" "$ZSHDIR/user-after.zsh"
[ -e "$HOME/user-before.zsh.bak" ] && mv "$HOME/user-before.zsh.bak" "$ZSHDIR/user-before.zsh"
[ -e "$HOME/user-p10k.zsh.bak" ] && mv "$HOME/user-p10k.zsh.bak" "$ZSHDIR/user-p10k.zsh"
[ -e "$HOME/omz-custom.bak" ] && mv "$HOME/omz-custom.bak" "$ZSHDIR/omz/custom"
[ -e "$HOME/history.bak" ] && cat "$HOME/history" >> "$ZSHDIR/history" && rm "$HOME/history.bak"

# write zshrc
[ -e "$HOME/.zshrc" ] && mv "$HOME/.zshrc" "$HOME/zshrc.bak" && echo "Backup ~/.zshrc into ~/.zshrc.bak"
echo "export ZSHDIR=\"$(realpath "$ZSHDIR")\"" > "$HOME/.zshrc"
cat "$ZSHDIR/.zshrc" >> "$HOME/.zshrc"

# source files
source "$ZSHDIR/rc.zsh"
source "$ZSHDIR/lazyload.zsh"
zcompile_all; echo Recompiled all of zsh

# load nvm
export NVM_DIR="$ZSHDIR/nvm"
source "$ZSHDIR/nvm/nvm.sh"
echo Setup nodejs . . .
nvm install node
nvm version current > "$HOME/.nvmrc.default"
corepack enable
echo nodejs installed!

# set install time and restart
date -u "+%s" > "$ZSHDIR/updated-at"
echo restarting . . .
exec zsh

