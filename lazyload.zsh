# update notification
if [[ -z "$NO_UPDATE_NOFITICATION" ]]; then
	now=$(date -u "+%s")
	[ -n "$HOME/.zsh/updated-at" ] && ( echo $now > "$HOME/.zsh/updated-at" )
	[[ "$(( `date -u "+%s"` > `cat "$HOME/.zsh/updated-at"` + 2592000 ))" == 1 ]] && printf "%s" "You haven't updated omz in a month. Type \"zupdate\" to update omz.
	To suppress this message, put
	export NO_UPDATE_NOFITICATION=\"true\"
	in your user-before.zsh"
fi

# Session unique id
function rand16 {
	which openssl >/dev/null && openssl rand -base64 16 && return 0
	LC_ALL=C tr -dc '[:graph:]' </dev/urandom | head -c 13
}
[ -z "$SESSION_PASSWORD_CACHE" ] && export SESSION_PASSWORD_CACHE="$(rand16)"

# Git commands
# From https://github.com/cmilr/Git-Beautify-For-MacOS-Terminal/blob/master/bash_profile
txtpur='\e[0;35m' # Purple
bldcyn='\e[1;36m' # Cyan
txtrst='\e[0m'    # Text Reset
# Basic log
alias log="printf '$bldcyn' > /tmp/gitlog ; git log --pretty=format:'%D' -1 >> /tmp/gitlog ; printf '\n' >> /tmp/gitlog ; git log --color --pretty=format:'%C(green)%h%Creset ≁ %C(yellow)%>(12,trunc)%cr%C(white) %>(11,trunc)%an%C(green) ⟹  %C(blue) %s' --abbrev-commit --date=relative >> /tmp/gitlog ; less /tmp/gitlog ; rm /tmp/gitlog" 
# Basic log with graph
alias logg="printf '$bldcyn' > /tmp/gitlog ; git log --pretty=format:'%D' -1 >> /tmp/gitlog ; printf '\n' >> /tmp/gitlog ; git log --color --graph --pretty=format:'%C(green)%h%Creset ≁ %C(yellow)%>(12,trunc)%cr%C(white) %>(11,trunc)%an%C(green) ⟹  %C(blue) %s' --abbrev-commit --date=relative >> /tmp/gitlog ; less /tmp/gitlog ; rm /tmp/gitlog"
# Verbose log
alias logv="printf '$bldcyn' > /tmp/gitlog ; git log --pretty=format:'%D' -1 >> /tmp/gitlog ; printf '\n' >> /tmp/gitlog ; git log --color --pretty=format:'%C(green)%h%Creset ≁ %C(yellow)%>(12,trunc)%cr%C(white) %>(11,trunc)%an %Creset%ce%C(green) ⟹  %C(blue) %s' --abbrev-commit --date=relative >> /tmp/gitlog ; less /tmp/gitlog ; rm /tmp/gitlog"
# Verbose log with graph
alias loggv="printf '$bldcyn' > /tmp/gitlog ; git log --pretty=format:'%D' -1 >> /tmp/gitlog ; printf '\n' >> /tmp/gitlog ; git log --color --graph --pretty=format:'%C(green)%h%Creset ≁ %C(yellow)%>(12,trunc)%cr%C(white) %>(11,trunc)%an %Creset%ce%C(green) ⟹  %C(blue) %s' --abbrev-commit --date=relative >> /tmp/gitlog ; less /tmp/gitlog ; rm /tmp/gitlog"
# Log with full commit messages
alias logm="printf '$bldcyn' > /tmp/gitlog ; git log --pretty=format:'%D' -1 >> /tmp/gitlog ; printf '\n' >> /tmp/gitlog ; git log --color --format=format:'%Creset%Cgreen%h%Creset | %C(white)%an | %C(yellow)%cr%n%Creset%s%n%n%b%n' >> /tmp/gitlog ; less /tmp/gitlog ; rm /tmp/gitlog"
# Show refs
alias refs="printf '$bldcyn' ; git show-ref --abbrev && printf '$txtrst'"
# Show remote refs and urls
alias remotes="printf '$txtpur' ; git remote -v && printf '$bldcyn\n' ; git branch -r --no-color && printf '$txtrst'"

