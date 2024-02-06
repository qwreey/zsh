# recompile all zsh files
zcompile_all() {
	[ -e "$HOME/.zsh/private.zsh" ] && zcompile ~/.zsh/private.zsh
	[ -e "$HOME/.zsh/user-lazy.zsh" ] && zcompile ~/.zsh/user-lazy.zsh
	[ -e "$HOME/.zsh/user-before.zsh" ] && zcompile ~/.zsh/user-before.zsh
	[ -e "$HOME/.zsh/user-after.zsh" ] && zcompile ~/.zsh/user-after.zsh
	[ -e "$HOME/.zsh/user-p10k.zsh" ] && zcompile ~/.zsh/user-p10k.zsh
	zcompile "$HOME/.zsh/rc.zsh"
	zcompile "$HOME/.zsh/lazyload.zsh"
	zcompile "$HOME/.zsh/p10k.zsh"
	zcompile "$HOME/.zsh/nvm/nvm.sh"
	zcompile "$HOME/.zsh/fnvm/fnvm.sh"
	zcompile "$HOME/.zsh/defer/zsh-defer.plugin.zsh"
	zcompile "$HOME/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
	zcompile "$HOME/.zsh/lib.zsh"
	( rm "$HOME"/.zsh/omz/lib/**/*.zsh.zwc -f ) 2>/dev/null
	find "$HOME"/.zsh/powerlevel10k/**/*.zsh-theme | xargs -i zsh -c 'zcompile {}'
	find "$HOME"/.zsh/powerlevel10k/internal/**/*.zsh | xargs -i zsh -c 'zcompile {}'
	find "$HOME"/.zsh/powerlevel10k/gitstatus/**/*.zsh | xargs -i zsh -c 'zcompile {}'
	( find "$HOME"/.zsh/omz/lib/**/*.zsh | xargs -i zsh -c 'zcompile {}' ) 2>/dev/null
	( find "$HOME"/.zsh/zcompdump*.zsh | xargs -i zsh -c 'zcompile {}' ) 2>/dev/null
	find "$HOME"/.zsh/zsh-syntax-highlighting/**/*.zsh | xargs -i zsh -c 'zcompile {}'
}
zupdate() {
	git -C $HOME/.zsh/fnvm pull origin master --depth 1
	git -C $HOME/.zsh/defer pull origin master --depth 1
	git -C $HOME/.zsh/nvm pull origin master --depth 1
	git -C $HOME/.zsh/powerlevel10k pull origin master --depth 1
	git -C $HOME/.zsh/zsh-syntax-highlighting pull origin master --depth 1
	fnvm_update
	omz update
	zcompile_all
	date -u "+%s" > "$HOME/.zsh/updated-at"
	exec zsh
}

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

