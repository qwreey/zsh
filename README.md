# Performance focused zsh setup

This is my hyper fast oh-my-zsh, cross platform setup

It use zsh-defer to load slow configurations, such as nvm.

nvm was customized by [fnvm](https://github.com/qwreey75/fnvm), which makes nvm much faster. (it was made for cygwin, but can compatible with *nix)

Also, i used zcompile, which compiles zsh file to make performance better

oh-my-zsh was customized(disable autoupdate, such more) for performance. (it was nested in rc file)

# Install

execute install script
```
ZSHFNVM="true"\
ZSHNVM="true"\
ZSHPYENV="true"\
ZSHRUSTUP="true"\
ZSHDIR=~/.zsh eval "$(curl https://raw.githubusercontent.com/qwreey/zsh/master/install.zsh)"
```
to clone omz, nvm, defer, fnvm and powerlevel10k into new .zsh (it will not overwrite your ohmyzsh, if you have ohmyzsh already, you can remove it)
This script will update call `nvm use node` to initialize nodejs, and compile all zsh file to speed up your zsh

# Config

You can add your configuration into $HOME/.zsh/user-before.zsh
user-before.zsh will loaded before zsh loaded. so you can set omz plugins by
```
plugins=( git copyfile copypath )
```

$HOME/.zsh/user-after.zsh will loaded after omz loaded
and $HOME/.zsh/user-lazy.zsh will loaded by zsh-defer

$HOME/.zsh/user-p10k.zsh will loaded for p10k if exist

If you want to configure p10k. type `p10k configure`

# Toolkit integration

This zsh configuration integrates the toolkit below. rustc, pyenv, nvm
