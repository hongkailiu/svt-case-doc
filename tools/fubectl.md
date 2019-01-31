# [fubectl](https://github.com/kubermatic/fubectl)


Install [fzf](https://github.com/junegunn/fzf): 

Method 1:
```
# cd ~/bin
# curl -LO https://github.com/junegunn/fzf-bin/releases/download/0.17.5/fzf-0.17.5-linux_386.tgz
# tar xzvf ./fzf-0.17.5-linux_386.tgz
# rm ./fzf-0.17.5-linux_386.tgz
# fzf --version
0.17.5 (b46227d)

```


Method 2: install fzf using `linuxbrew`: [how2](./linuxbrew.md) and then

```
# cd ~/bin
# ln -s /home/linuxbrew/.linuxbrew/bin/fzf ./fzf
# fzf --version
0.17.5 (brew)

```

Install `fubectl`:

```
# curl -LO https://rawgit.com/kubermatic/fubectl/master/fubectl.source
# src_path=$(readlink -f ./fubectl.source)
# echo "[ -f ${src_path} ] && source ${src_path}" >> ~/.bash_profile
# source ~/.bash_profile 

```
