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

## Test
* [gomega](https://onsi.github.io/gomega/) and [ginkgo](https://onsi.github.io/ginkgo/)
* [testify](https://github.com/stretchr/testify/) and [mockery](https://github.com/vektra/mockery): [examples](https://blog.lamida.org/mocking-in-golang-using-testify/)
* [gomock](https://github.com/golang/mock/): [examples](https://blog.codecentric.de/en/2017/08/gomock-tutorial/)

## godoc

[godoc.org](https://godoc.org/) generates and hosts api docs for
 go project hosted eg, at github.com.
See [how to write doc for golang](https://blog.golang.org/godoc-documenting-go-code).
[Here](https://godoc.org/github.com/hongkailiu/test-go) is the doc for svt-go.

[Generate and view goDoc locally](https://godoc.org/golang.org/x/tools/cmd/godoc).


## CICD

## Good practice

* https://github.com/golang/go/wiki/CodeReviewComments


## [migrating-from-glide-to-dep](https://golang.github.io/dep/docs/migrating.html)

Install `dep`:

```
$ curl https://raw.githubusercontent.com/golang/dep/master/install.sh | sh
$ dep version
dep:
 version     : v0.5.0
 build date  : 2018-07-26
 git hash    : 224a564
 go version  : go1.10.3
 go compiler : gc
 platform    : linux/amd64
 features    : ImportDuringSolve=false

```

Generate dep files: NOT work for my test-go repo (does not return over several hours). Had to remove all go file, `dep init`, and add it back one by one.

```
$ dep init
```
