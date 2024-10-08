
typeset -g POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(
	# =========================[ Line #1 ]=========================
	# os_icon                 # os identifier
	q_device_name # for ssh...
	status                  # exit code of the last command
	dir                     # current directory
	vcs                     # git status
	command_execution_time
	# pyenv
	# nodeenv
	time
	background_jobs
	# luaenv
	vim_shell

	# =========================[ Line #2 ]=========================
	newline                 # \n
	prompt_char             # prompt symbol
)

function prompt_q_device_name() {
	if [ -z "$P10K_DEVICENAME" ]; then
		if [ -e "$ZSHDIR/codename.colored" ]; then
			P10K_DEVICENAME="$(cat "$ZSHDIR/codename.colored")"
		elif [ -e "$ZSHDIR/codename" ]; then
			P10K_DEVICENAME="$(cat "$ZSHDIR/codename")"
		elif [ ! -z "$HOST" ]; then
			P10K_DEVICENAME="$HOST"
		else
			P10K_DEVICENAME="UNKNOWN"
		fi
	fi
	p10k segment -b 2 -f '219' -t "%B$P10K_DEVICENAME"
}
function prompt_q_account_name() {

}

typeset -g POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=()
typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet

