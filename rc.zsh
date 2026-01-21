# set export DEBUG="true" on .zshrc to active debug mode
if [[ "$DEBUG" == "true" ]]; then
	DEBUG=true
else
	DEBUG=false
fi
$DEBUG && timer_main=$(($(date +%s%N)/1000000)) && echo .zshrc load started

# ----------------------  CONFIG  ----------------------
export FNVM_NVMDIR="$ZSHDIR/nvm"
export FNVM_DIR="$ZSHDIR/fnvm"
export NVM_DIR="$ZSHDIR/nvm"
export PYENV_ROOT="$ZSHDIR/pyenv"
export CARGO_HOME="$HOME/.cargo"
export RUSTUP_HOME="$ZSHDIR/rustup"
export COREPACK_ENABLE_AUTO_PIN=0

# unlimited history
if [ -e "$ZSHDIR/history" ]; then
	echo "The behavior of putting history files inside .zsh was unstable and has been removed. Move this to your home folder."
	echo
	echo "(move $ZSHDIR/history into $HOME/.zsh_history)"
fi
export HISTSIZE=1000000000
export SAVEHIST=$HISTSIZE
setopt EXTENDED_HISTORY

# load defer
source "$ZSHDIR/defer/zsh-defer.plugin.zsh"

# nvm
[ -e "$ZSHDIR/fnvm" ] && zsh-defer +1 +2 -c 'source $ZSHDIR/fnvm/fnvm.sh; fnvm_init'

# pyenv
if (( $+commands[cygpath] )); then
	export PATH="$ZSHDIR/pyenv/pyenv-win/bin:$ZSHDIR/pyenv/pyenv-win/shims:$PATH"
else
	[ -e "$ZSHDIR/pyenv" ] && zsh-defer +1 +2 -c 'eval "$($ZSHDIR/pyenv/bin/pyenv init -)"; eval "$($ZSHDIR/pyenv/bin/pyenv virtualenv-init -)"'
fi

# rustup
# Not required.
# [ -e "$HOME/.cargo/env" ] && [ -e "$ZSHDIR/rustup" ] && zsh-defer +1 +2 -c 'source $HOME/.cargo/env'

# load base libs
source "$ZSHDIR/lib.zsh"

# lazyload
zsh-defer +1 +2 source "$ZSHDIR/lazyload.zsh"
[ -e "$ZSHDIR/user-lazy.zsh" ] && zsh-defer +1 +2 source $ZSHDIR/user-lazy.zsh

# load user config
DISABLE_AUTO_TITLE="true" # more performance!
DISABLE_UNTRACKED_FILES_DIRTY="true"
[ -e "$ZSHDIR/user-before.zsh" ] && source $ZSHDIR/user-before.zsh

# Add common bin dirs
(! (($path[(Ie)$HOME/.yarn/bin])) ) && path=( "$HOME/.yarn/bin" $path )
(! (($path[(Ie)$HOME/.cargo/bin])) ) && path=( "$HOME/.cargo/bin" $path )
(! (($path[(Ie)$HOME/.local/bin])) ) && path=( "$HOME/.local/bin" $path )
(! (($path[(Ie)$ZSHDIR/pyenv/bin])) ) && path=( "$ZSHDIR/pyenv/bin" $path )
(! (($path[(Ie)$ZSHDIR/bin])) ) && path=( "$ZSHDIR/bin" $path )
export PATH

# ----------------------  ZSH  ----------------------
$DEBUG && timer_omz=$(($(date +%s%N)/1000000))
export ZSH="$ZSHDIR/omz"
export ZSH_CUSTOM="$ZSH/custom"
export ZSH_CACHE_DIR="$ZSH/cache"
[ -z "$plugins" ] && plugins=( git copyfile copypath ) # git web-search copypath copyfile copybuffer dirhistory

mkdir -p "$ZSH_CACHE_DIR/completions"

# Figure out the SHORT hostname
if [[ "$OSTYPE" = darwin* ]]; then
  # macOS's $HOST changes with dhcp, etc. Use ComputerName if possible.
  SHORT_HOST=$(scutil --get ComputerName 2>/dev/null) || SHORT_HOST="${HOST/.*/}"
else
  SHORT_HOST="${HOST/.*/}"
fi

# add a function path
fpath=("$ZSH/functions" "$ZSH/completions" $fpath)
autoload -U compaudit compinit zrecompile

is_plugin() {
	local base_dir=$1
	local name=$2
	builtin test -f $base_dir/plugins/$name/$name.plugin.zsh \
		|| builtin test -f $base_dir/plugins/$name/_$name
}

# Add all defined plugins to fpath. This must be done
# before running compinit.
for plugin ($plugins); do
	if is_plugin "$ZSH_CUSTOM" "$plugin"; then
		fpath=("$ZSH_CUSTOM/plugins/$plugin" $fpath)
	elif is_plugin "$ZSH" "$plugin"; then
		fpath=("$ZSH/plugins/$plugin" $fpath)
	else
		echo "[oh-my-zsh] plugin '$plugin' not found"
	fi
done

# Save the location of the current completion dump file.
ZSH_COMPDUMP="$ZSHDIR/zcompdump-${ZSH_VERSION}.zsh"

# Construct zcompdump OMZ metadata
zcompdump_revision="#omz revision: $(builtin cd -q "$ZSH"; git rev-parse HEAD 2>/dev/null)"
zcompdump_fpath="#omz fpath: $fpath"

# Delete the zcompdump file if OMZ zcompdump metadata changed
if ! command grep -q -Fx "$zcompdump_revision" "$ZSH_COMPDUMP" 2>/dev/null \
	|| ! command grep -q -Fx "$zcompdump_fpath" "$ZSH_COMPDUMP" 2>/dev/null; then
	command rm -f "$ZSH_COMPDUMP*"
	zcompdump_refresh=1
	echo -n "Updating zcomdump file ..."
	tee -a "$ZSH_COMPDUMP" &>/dev/null <<EOF

$zcompdump_revision
$zcompdump_fpath
EOF
	compinit -C -i -d "$ZSH_COMPDUMP"
	zrecompile -q -p "$ZSH_COMPDUMP"
	echo " (done)"
fi
unset zcompdump_revision zcompdump_fpath zcompdump_refresh

source "$ZSH/lib/compfix.zsh"
compinit -i -d "$ZSH_COMPDUMP"
handle_completion_insecurities &|

_omz_source() {
	local context filepath="$1"

	# Construct zstyle context based on path
	case "$filepath" in
	lib/*) context="lib:${filepath:t:r}" ;;         # :t = lib_name.zsh, :r = lib_name
	plugins/*) context="plugins:${filepath:h:t}" ;; # :h = plugins/plugin_name, :t = plugin_name
	esac

	# local disable_aliases=0
	zstyle -T ":omz:${context}" aliases || disable_aliases=1

	# Back up alias names prior to sourcing
	local -A aliases_pre galiases_pre
	if (( disable_aliases )); then
		aliases_pre=("${(@kv)aliases}")
		galiases_pre=("${(@kv)galiases}")
	fi

	# Source file from $ZSH_CUSTOM if it exists, otherwise from $ZSH
	if [[ -f "$ZSH_CUSTOM/$filepath" ]]; then
		source "$ZSH_CUSTOM/$filepath"
	elif [[ -f "$ZSH/$filepath" ]]; then
		source "$ZSH/$filepath"
	fi

	# Unset all aliases that don't appear in the backed up list of aliases
	if (( disable_aliases )); then
		if (( #aliases_pre )); then
			aliases=("${(@kv)aliases_pre}")
		else
			(( #aliases )) && unalias "${(@k)aliases}"
		fi
		if (( #galiases_pre )); then
			galiases=("${(@kv)galiases_pre}")
		else
			(( #galiases )) && unalias "${(@k)galiases}"
		fi
	fi
}

# Load all of the config files in ~/oh-my-zsh that end in .zsh
# TIP: Add files you don't want in git to .gitignore
$DEBUG && timer_libs=$(($(date +%s%N)/1000000))
for config_file ("$ZSH"/lib/*.zsh); do
	file="${config_file:t}"
	#[ "$file" != "correction.zsh" ] &&
	#[ "$file" != "directories.zsh" ] &&
	#[ "$file" != "grep.zsh" ] &&
	#[ "$file" != "misc.zsh" ] &&
	_omz_source "lib/$file"
done
unset custom_config_file
$DEBUG && timer_libs_result=$(($(date +%s%N)/1000000-$timer_libs))

autoload -U colors && colors
autoload -Uz is-at-least
autoload -Uz +X regexp-replace VCS_INFO_formats
autoload -Uz add-zsh-hook
setopt auto_cd
setopt auto_pushd
setopt pushd_ignore_dups
setopt pushdminus
setopt multios
setopt long_list_jobs
setopt interactivecomments
setopt prompt_subst

$DEBUG && timer_plugins=$(($(date +%s%N)/1000000)) && timer_plugins_text=""
# Load all of the plugins that were defined in ~/.zshrc
for plugin ($plugins); do
	$DEBUG && timer_plugin=$(($(date +%s%N)/1000000))
	_omz_source "plugins/$plugin/$plugin.plugin.zsh"
	$DEBUG && timer_plugins_text="    - $plugin: "$(($(date +%s%N)/1000000-$timer_plugin))"\n$timer_plugins_text"
done
unset plugin
$DEBUG && timer_plugins_result=$(($(date +%s%N)/1000000-$timer_plugins))

# Load all of your custom configurations from custom/
for config_file ("$ZSH_CUSTOM"/*.zsh(N)); do
	source "$config_file"
done
unset config_file

# set completion colors to be the same as `ls`, after theme has been loaded
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

$DEBUG && echo "OMZ loaded: "$(($(date +%s%N)/1000000-$timer_omz))"\n - Plugins: $timer_plugins_result\n$timer_plugins_text - Libs: $timer_libs_result"

# ----------------------  THEME  ----------------------
$DEBUG && timer_theme=$(($(date +%s%N)/1000000))
THEME_FILE=$(echo $ZSHDIR/*-zsh-theme/*.zsh-theme)
if [[ -e "$ZSHDIR/user-theme.zsh" ]]; then
	source "$ZSHDIR/user-theme.zsh"
elif [[ -e "$THEME_FILE" ]]; then
	source "$THEME_FILE"
else
	if [[ -e "$ZSHDIR/user-p10k.zsh" ]]; then
		source "$ZSHDIR/user-p10k.zsh"
	else
		source "$ZSHDIR/p10k.zsh"
		source "$ZSHDIR/p10k-override.zsh"
	fi
	[ -e "$ZSHDIR/user-p10k-override.zsh" ] && source "$ZSHDIR/user-p10k-override.zsh"
	source "$ZSHDIR/powerlevel10k/powerlevel10k.zsh-theme"
fi
$DEBUG && echo "Theme (p10k) loaded: "$(($(date +%s%N)/1000000-$timer_theme))

# ---------------------- SYNTAX  ----------------------
$DEBUG && timer_syntax=$(($(date +%s%N)/1000000))
if [[ "$DISABLE_SYNTAX_HIGHLIGHTING" != "true" ]]; then
	source "$ZSHDIR/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
fi
$DEBUG && echo "Syntax Highlighting loaded: "$(($(date +%s%N)/1000000-$timer_syntax))

# ------------------ AUTOSUGGESTIONS ------------------
$DEBUG && timer_autosug=$(($(date +%s%N)/1000000))
source "$ZSHDIR/zsh-autosuggestions/zsh-autosuggestions.zsh"
$DEBUG && echo "Auto Suggestions loaded: "$(($(date +%s%N)/1000000-$timer_autosug))

# ------------------ FZF COMPLETION  ------------------
if which fzf &> /dev/null; then
	source "$ZSHDIR/fzf-tab-completion/zsh/fzf-zsh-completion.sh"
	bindkey '^ ' fzf_completion
fi

# ----------------------  AFTER  ----------------------
[ -e "$ZSHDIR/user-after.zsh" ] && source $ZSHDIR/user-after.zsh
$DEBUG && echo "SUM: "$(($(date +%s%N)/1000000-$timer_main))
true
