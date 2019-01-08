# nodejs

## Installation

### [installation: binary archive](https://github.com/nodejs/help/wiki/Installation)

Tested with RHEL7.

```bash
$ curl -O https://nodejs.org/dist/v10.15.0/node-v10.15.0-linux-x64.tar.xz
$ tar -xJvf node-v10.15.0-linux-x64.tar.xz
$ ln -s ./node-v10.15.0-linux-x64 ./node
$ vi ~/.bashrc
...
export NODEJS_HOME=/home/hongkliu/tool/node
export PATH=${NODEJS_HOME}/bin:$PATH

$ source ~/.bashrc

$ node -v
v10.15.0
$ npm version
{ npm: '6.4.1',
  ares: '1.15.0',
  cldr: '33.1',
  http_parser: '2.8.0',
  icu: '62.1',
  modules: '64',
  napi: '3',
  nghttp2: '1.34.0',
  node: '10.15.0',
  openssl: '1.1.0j',
  tz: '2018e',
  unicode: '11.0',
  uv: '1.23.2',
  v8: '6.8.275.32-node.45',
  zlib: '1.2.11' }
$ npx -v
6.4.1


```

### [installation: package manager](https://nodejs.org/en/download/package-manager/)

## hello-world

Output hello-world:

```bash
$ git clone https://github.com/hongkailiu/test-nodejs.git
$ cd test-nodejs
$ node helloworld.js 
Hello World!

```

http server hello-world:
```bash
$ node app.js 
Server running at http://127.0.0.1:3000/

### use another terminal
$ curl http://localhost:3000/
Hello World

```

using static files:

https://expressjs.com/

## npm

```bash
$ mkdir app
$ cd app
$ npm install express

```


https://github.com/nodejs/node-v0.x-archive/wiki/Node-Hosting