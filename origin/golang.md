# [GoLang](https://golang.org/)

## Tutorial

* [golangbot.com](https://golangbot.com/learn-golang-series/)

## Installation

### [from binary](https://golang.org/doc/install)

```sh
$ cd ~/tool
$ wget https://dl.google.com/go/go1.9.3.linux-amd64.tar.gz
$ tar -xzf go1.9.3.linux-amd64.tar.gz
$ mv go go1.9.3
$ ln -s go1.9.3 go

### Append ~/.bashrc
...
export GOROOT=$HOME/tool/go
export PATH=$PATH:$GOROOT/bin
export GOPATH=$HOME/repo/go
export PATH=$GOPATH/bin:$PATH

$ go version
go version go1.9.3 linux/amd64
```

### from dnf
Follow [those steps](README.md#prerequisites).

## Cli

## IDE
* Intellij Ultimate Edition + go plugin
* vscode

### Dep. Management

## awesome
https://github.com/avelino/awesome-go

https://github.com/gostor/awesome-go-storage

### logging

* [sirupsen/logrus](https://github.com/sirupsen/logrus)
* [op/go-logging](https://github.com/op/go-logging)

### goroutine pool

* [go-playground/pool](https://github.com/go-playground/pool)

### cli

* [spf13/cobra](https://github.com/spf13/cobra)

## Libs

go template:

https://godoc.org/text/template#pkg-subdirectories
https://blog.gopheracademy.com/advent-2017/using-go-templates/

code-generator:

https://github.com/kubernetes/code-generator
https://kubernetes.io/docs/contribute/generate-ref-docs/kubernetes-api/

swagger:

https://swagger.io/docs/specification/about/

database:

https://flaviocopes.com/golang-sql-database/
https://github.com/golang-migrate/migrate
https://github.com/pressly/goose

## godoc

[godoc.org](https://godoc.org/) generates and hosts api docs for
 go project hosted eg, at github.com.
See [how to write doc for golang](https://blog.golang.org/godoc-documenting-go-code).
[Here](https://godoc.org/github.com/hongkailiu/test-go) is the doc for svt-go.

[Generate and view goDoc locally](https://godoc.org/golang.org/x/tools/cmd/godoc).


## CICD

## Good practice

* https://github.com/golang/go/wiki/CodeReviewComments
