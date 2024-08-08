
declare -A PATH_ALLOCATIONS

function lib:path-free {
	local alloc
	eval "alloc=\$$1"
	local new=()
	for pathitem in $path; do
		if ! (($alloc[(Ie)$pathitem])); then
			new+=( $pathitem )
		fi
	done
	path=($new)
	export PATH
}
alias path-free=lib:path-free

function lib:path-alloc {
	local var=$1
	shift
	export PATH="$1"
	shift
	eval "$var=\$@"
}
alias path-alloc=lib:path-alloc

function lib:path-alloc2 {
	local var=$1
	shift
	local ret=()
	local plist=()
	local solpath
	local found=0
	for pathitem in $@; do
		if [ "$pathitem" = ":" ]; then
			plist+=( "$PATH" )
			found=1
		else
			solpath="$(realpath $pathitem)"
			ret+=( "$solpath" )
			plist+=( "$solpath" )
		fi
	done
	if [ "$found" = "0" ]; then
		plist=( "$PATH" $found )
	fi
	export PATH="${(j/:/)plist}"
	eval "$var=\$ret"
}
alias path-alloc=lib:path-alloc

HEAD_DEFAULT="LOG"
function lib:log {
	if [[ -z "$HEAD" ]]; then
		HEAD="$HEAD_DEFAULT"
	fi
	printf "\e[32m[$HEAD]\e[0m %s\n" "$1"
}
alias log=lib:log

function lib:file-timestamp {
	date +%Z-%Y.%m.%d-%H.%M.%S
}
alias file-timestamp=lib:file-timestamp

function lib:findup {
	local path_
	path_="${PWD}"
	if [ -e "${path_}/${1-}" ]; then
		printf "%s\n" "${path_}/${1-}"
	fi
	while [ "${path_}" != "" ] && [ "${path_}" != '.' ]; do
		path_=${path_%/*}
		if [ -e "${path_}/${1-}" ]; then
			printf "%s\n" "${path_}/${1-}"
		fi
	done
}
alias findup=lib:findup

function dirzsh:scriptid {
	printf "%s" "$1" | sha1sum | head -c 16
}

DIRZSH_LOADED=()
function dirzsh:apply {
	local found=()
	while read line; do
		local real="$(command realpath "$line")"
		local dir="$(command realpath "$(dirname "$line")")"
		local id="$(dirzsh:scriptid "$real")"
		found+=( $real )

		# Check is loaded
		if (($DIRZSH_LOADED[(Ie)$real])); then
			continue
		fi

		# Source
		ID="$id" SCRIPTID="$id" DIR="$dir" SCRIPTDIR="$dir" source "$real"

		# Execute load function
		ID="$id" SCRIPTID="$id" DIR="$dir" SCRIPTDIR="$dir" "$id:load"
	done < <( lib:findup "dirzsh.zsh" )

	# Unload
	for zshfile in $DIRZSH_LOADED; do
		if ! (($found[(Ie)$zshfile])); then
			local id="$(dirzsh:scriptid "$zshfile")"
			local dir="$(command realpath "$(command dirname "$zshfile")")"

			# Execute unload function
			ID="$id" SCRIPTID="$id" DIR="$dir" SCRIPTDIR="$dir" "$id:unload"

			# Unset functions from script
			unset -f $(typeset -fm "$id*" | grep -oP "$a.*(?= \(\) {)")
		fi
	done
	DIRZSH_LOADED=$found
}

function dirzsh:unload {
	for zshfile in $DIRZSH_LOADED; do
		local id="$(dirzsh:scriptid "$zshfile")"
		local dir="$(command realpath "$(command dirname "$zshfile")")"

		# Execute unload function
		ID="$id" SCRIPTID="$id" DIR="$dir" SCRIPTDIR="$dir" "$id:unload"

		# Unset functions from script
		unset -f $(typeset -fm "$id*" | grep -oP "$a.*(?= \(\) {)")
	done
	DIRZSH_LOADED=()
}

function dirzsh:reload {
	dirzsh:unload
	dirzsh:apply
}

# Hook
autoload -U add-zsh-hook
add-zsh-hook chpwd dirzsh:apply
dirzsh:apply

