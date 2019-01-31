# [Linuxbrew)(http://linuxbrew.sh/)

## installation

Tested with RHEL 7:

```
######### The following installation script does not allow to be run with root while it requires a sudo user with password
### https://access.redhat.com/documentation/en-US/Red_Hat_Enterprise_Linux_OpenStack_Platform/2/html/Getting_Started_Guide/ch02s03.html
# sudo useradd aaa
# passwd aaa
# usermod -aG wheel aaa
# su - aaa


$ sh -c "$(curl -fsSL https://raw.githubusercontent.com/Linuxbrew/install/master/install.sh)"
...
Warning: /home/linuxbrew/.linuxbrew/bin is not in your PATH.

$ test -d ~/.linuxbrew && eval $(~/.linuxbrew/bin/brew shellenv)
$ test -d /home/linuxbrew/.linuxbrew && eval $(/home/linuxbrew/.linuxbrew/bin/brew shellenv)
$ test -r ~/.bash_profile && echo "eval \$($(brew --prefix)/bin/brew shellenv)" >>~/.bash_profile

$ brew --version
Homebrew 1.9.3
Homebrew/homebrew-core (git revision cd50; last commit 2019-01-31)

```

Install fzf:

```
$ brew install fzf
==> Downloading https://linuxbrew.bintray.com/bottles/fzf-0.17.5.x86_64_linux.bottle.tar.gz
######################################################################## 100.0%
==> Pouring fzf-0.17.5.x86_64_linux.bottle.tar.gz
==> Caveats
To install useful keybindings and fuzzy completion:
  /home/linuxbrew/.linuxbrew/opt/fzf/install

To use fzf in Vim, add the following line to your .vimrc:
  set rtp+=/home/linuxbrew/.linuxbrew/opt/fzf
==> Summary
🍺  /home/linuxbrew/.linuxbrew/Cellar/fzf/0.17.5: 17 files, 3.5MB

$ fzf --version
0.17.5 (brew)

```