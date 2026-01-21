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
ZSHBAK="$HOME/.zsh.bak"
if [ -e "$ZSHBAK" ]; then
	echo "$HOME/.zsh.bak already exist, unable to backup zsh files"
	exit 1
fi
if [ -e "$ZSHDIR" ]; then
	log "Old installation found. backup files"
	mkdir -p "$ZSHBAK"
	[ -e "$ZSHDIR/bin" ] && mv "$ZSHDIR/bin" "$ZSHBAK" && HEAD="Backup" log "Backup bin"
	for userfile in $ZSHDIR/user*; do
		mv "$userfile" "$ZSHBAK"
	done
	mv "$ZSHDIR/omz/custom" "$ZSHBAK" && log "Backup omz custom folder"
	mv "$ZSHDIR" "$ZSHBAK/old.zsh" && log "Backup old installation folder"
fi

# clone files
log "Clone qwreey/zsh"                        ; git clone https://github.com/qwreey75/zsh "$ZSHDIR" --depth 1
log "Clone romkatv/zsh-defer"                 ; git clone https://github.com/romkatv/zsh-defer "$ZSHDIR/defer" --depth 1
if [[ "$ZSHFNVM" == "true" ]]; then
	log "Clone qwreey/fnvm"                   ; git clone https://github.com/qwreey75/fnvm "$ZSHDIR/fnvm" --depth 1
fi
if [[ "$ZSHNVM" == "true" ]]; then
	log "Clone nvm-sh/nvm"                    ; git clone https://github.com/nvm-sh/nvm "$ZSHDIR/nvm" --depth 1
	export NVM_DIR="$ZSHDIR/nvm"
	source "$ZSHDIR/nvm/nvm.sh"
	echo "Setup nodejs . . ."
	nvm install --no-progress node
	nvm version current > "$HOME/.nvmrc.default"
	corepack enable
	echo "nodejs installed!"
fi
log "Clone ohmyzsh/ohmyzsh"                   ; git clone https://github.com/ohmyzsh/ohmyzsh "$ZSHDIR/omz" --depth 1
log "Clone romkatv/powerlevel10k"             ; git clone https://github.com/romkatv/powerlevel10k "$ZSHDIR/powerlevel10k" --depth 1
log "Clone zsh-users/zsh-syntax-highlighting" ; git clone https://github.com/zsh-users/zsh-syntax-highlighting "$ZSHDIR/zsh-syntax-highlighting" --depth 1
log "Clone zsh-users/zsh-autosuggestions"     ; git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSHDIR/zsh-autosuggestions" --depth 1
log "Clone zsh-users/zsh-autosuggestions"     ; git clone https://github.com/lincheney/fzf-tab-completion "$ZSHDIR/fzf-tab-completion" --depth 1
if [[ "$ZSHPYENV" == "true" ]]; then
	log "Install pyenv"
	if (( $+commands[cygpath] )); then
		git clone https://github.com/pyenv-win/pyenv-win.git "$ZSHDIR\pyenv"
		PYVER="$(PATH="$ZSHDIR/pyenv/pyenv-win/bin:$ZSHDIR/pyenv/pyenv-win/shims:$PATH" $ZSHDIR/pyenv/pyenv-win/bin/pyenv latest --known 3)"
		PATH="$ZSHDIR/pyenv/pyenv-win/bin:$ZSHDIR/pyenv/pyenv-win/shims:$PATH" $ZSHDIR/pyenv/pyenv-win/bin/pyenv install "$PYVER"
		PATH="$ZSHDIR/pyenv/pyenv-win/bin:$ZSHDIR/pyenv/pyenv-win/shims:$PATH" $ZSHDIR/pyenv/pyenv-win/bin/pyenv global "$PYVER"
	else
		curl --proto '=https' --tlsv1.2 -sSf https://pyenv.run | PYENV_ROOT="$ZSHDIR/pyenv" bash
		eval "$(PYENV_ROOT="$ZSHDIR/pyenv" $ZSHDIR/pyenv/bin/pyenv init -)"
		eval "$(PYENV_ROOT="$ZSHDIR/pyenv" $ZSHDIR/pyenv/bin/pyenv virtualenv-init -)"
		PYENV_ROOT="$ZSHDIR/pyenv" PATH="$ZSHDIR/pyenv/bin:$PATH" PYENV_ROOT="$ZSHDIR/pyenv" "$ZSHDIR/pyenv/bin/pyenv" install 3.12
		PYENV_ROOT="$ZSHDIR/pyenv" PATH="$ZSHDIR/pyenv/bin:$PATH" PYENV_ROOT="$ZSHDIR/pyenv" "$ZSHDIR/pyenv/bin/pyenv" virtualenv 3.12 default
		PYENV_ROOT="$ZSHDIR/pyenv" PATH="$ZSHDIR/pyenv/bin:$PATH" PYENV_ROOT="$ZSHDIR/pyenv" "$ZSHDIR/pyenv/bin/pyenv" global default
	fi
fi
if [[ "$ZSHRUSTUP" == "true" ]]; then
	log "Install rustup"
	curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | CARGO_HOME="$HOME/.cargo" RUSTUP_HOME="$ZSHDIR/rustup" sh -s -- --no-modify-path --profile default --default-toolchain stable -c cargo -c rust-analyzer -c rust-src -c clippy -y
	rustup default stable
fi

# import backups
if [ -e "$ZSHBAK" ]; then
	[ -e "$ZSHBAK/bin" ] && mv "$ZSHBAK/bin" "$ZSHDIR/bin"
	[ -e "$ZSHBAK/custom" ] && mv "$ZSHBAK/custom" "$ZSHDIR/omz/"
	for userfile in $ZSHBAK/user*; do
		mv "$userfile" "$ZSHDIR"
	done
fi

# write zshrc
mkdir -p "$ZSHBAK"
[ -e "$HOME/.zshrc" ] && mv "$HOME/.zshrc" "$ZSHBAK/.zshrc" && echo "Backup ~/.zshrc into $ZSHBAK/.zshrc"
echo "export ZSHDIR=\"$(realpath "$ZSHDIR")\"" > "$HOME/.zshrc"
cat "$ZSHDIR/.zshrc" >> "$HOME/.zshrc"

# source files
source "$ZSHDIR/rc.zsh"
source "$ZSHDIR/lib.zsh"
zsh:compile; echo "Recompiled all of zsh"

# set install time and restart
date -u "+%s" > "$ZSHDIR/updated-at"
[ -e "$ZSHBAK" ] && echo "Old install backuped in '$ZSHBAK'"
echo "[Ok] restart your shell to go!"

