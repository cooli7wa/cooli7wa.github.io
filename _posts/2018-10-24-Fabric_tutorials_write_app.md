---
layout: post
title: Fabric_tutorials_write_app
description:
categories: study
author:
  name: cooli7wa
  link: https://cooli7wa67@163.com
---
这篇简单介绍下 Writing Your First Application 中的一些注意点。

官方这篇教程很简单，但是有一些需要注意的地方，希望可以帮助到大家。

### 一些注意点

- npm install

  这个命令是安装 package.json 中指定的安装包，里面主要是这三个，fabric-ca-client、fabric-client 和 grpc
  fabric-ca-client，是 app 用来跟 fabric 内的 ca 服务通信的，在后面创建证书的时候，会用到。

  fabric-client，是 app 用来跟节点通信的，后面的 query、invoke 都是通过这个。

  另外在 ubuntu 1604 上安装 nodejs，可能安装是很旧的版本，在运行 npm install 的时候，就会报错，可以看下后面“npm install 的问题”里说的解决办法。

- ./startFabric.sh

  这个就是启动整个 fabric 网络，并安装好 chaincode

- enrollAdmin.js、registerUser.js、query.js、invoke.js

  这些就是所谓的 app 了，enroll 和 register 会使用 fabric-ca-client 和 fabric-client 来通信，query 和 invoke 就只使用 fabric-client 通信，因为不需要和 ca 通信。

  前两个是注册用户，后两个是获取信息和提交信息。

### npm install 的问题

- 提示 /usr/bin/env: ‘node’: No such file or directory

  这个是因为默认只有 nodejs 没有 node，解决办法是创建一个软链接。

  ```
  sudo ln -s /usr/bin/nodejs /usr/bin/node
  ```

- npm install 失败

```
node-pre-gyp WARN Using request for node-pre-gyp https download 
node-pre-gyp ERR! UNCAUGHT EXCEPTION 
node-pre-gyp ERR! stack TypeError: this is not a typed array.
node-pre-gyp ERR! stack     at Function.from (native)
node-pre-gyp ERR! stack     at Object.<anonymous> (/home/cooli7wa/Documents/mywork/block_chain_wallet/fabric-samples/fabcar/node_modules/fabric-client/node_modules/grpc/node_modules/tar/lib/parse.js:33:27)
node-pre-gyp ERR! stack     at Module._compile (module.js:410:26)
node-pre-gyp ERR! stack     at Object.Module._extensions..js (module.js:417:10)
node-pre-gyp ERR! stack     at Module.load (module.js:344:32)
node-pre-gyp ERR! stack     at Function.Module._load (module.js:301:12)
node-pre-gyp ERR! stack     at Module.require (module.js:354:17)
node-pre-gyp ERR! stack     at require (internal/module.js:12:17)
node-pre-gyp ERR! stack     at Object.<anonymous> (/home/cooli7wa/Documents/mywork/block_chain_wallet/fabric-samples/fabcar/node_modules/fabric-client/node_modules/grpc/node_modules/tar/lib/list.js:10:16)
node-pre-gyp ERR! stack     at Module._compile (module.js:410:26)
node-pre-gyp ERR! System Linux 4.4.0-137-generic
node-pre-gyp ERR! command "/usr/bin/nodejs" "/home/cooli7wa/Documents/mywork/block_chain_wallet/fabric-samples/fabcar/node_modules/fabric-client/node_modules/grpc/node_modules/.bin/node-pre-gyp" "install" "--fallback-to-build" "--library=static_library"
node-pre-gyp ERR! cwd /home/cooli7wa/Documents/mywork/block_chain_wallet/fabric-samples/fabcar/node_modules/fabric-client/node_modules/grpc
node-pre-gyp ERR! node -v v4.2.6
node-pre-gyp ERR! node-pre-gyp -v v0.10.3
node-pre-gyp ERR! This is a bug in `node-pre-gyp`.
node-pre-gyp ERR! Try to update node-pre-gyp and file an issue if it does not help:
node-pre-gyp ERR!     <https://github.com/mapbox/node-pre-gyp/issues>
fabcar@1.0.0 /home/cooli7wa/Documents/mywork/block_chain_wallet/fabric-samples/fabcar

npm WARN fabcar@1.0.0 No repository field.
npm ERR! Linux 4.4.0-137-generic
npm ERR! argv "/usr/bin/nodejs" "/usr/bin/npm" "install"
npm ERR! node v4.2.6
npm ERR! npm  v3.5.2
npm ERR! code ELIFECYCLE

npm ERR! grpc@1.14.2 install: `node-pre-gyp install --fallback-to-build --library=static_library`
npm ERR! Exit status 7
npm ERR! 
npm ERR! Failed at the grpc@1.14.2 install script 'node-pre-gyp install --fallback-to-build --library=static_library'.
npm ERR! Make sure you have the latest version of node.js and npm installed.
npm ERR! If you do, this is most likely a problem with the grpc package,
npm ERR! not with npm itself.
npm ERR! Tell the author that this fails on your system:
npm ERR!     node-pre-gyp install --fallback-to-build --library=static_library
npm ERR! You can get information on how to open an issue for this project with:
npm ERR!     npm bugs grpc
npm ERR! Or if that isn't available, you can get their info via:
npm ERR!     npm owner ls grpc
npm ERR! There is likely additional logging output above.

npm ERR! Please include the following file with any support request:
npm ERR!     /home/cooli7wa/Documents/mywork/block_chain_wallet/fabric-samples/fabcar/npm-debug.log
```

这个是因为 nodejs 版本过低，用下面的方法安装 8.x 版本

```
curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -
sudo apt-get install -y nodejs
```

<script type="text/javascript" src="https://cdn.mathjax.org/mathjax/latest/MathJax.js?config=default"></script>
