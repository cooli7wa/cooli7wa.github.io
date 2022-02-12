---
layout: post
title: gerrit REST API 使用方法
#  User beanpodtech_test
description:
categories: tools
author:
  name: cooli7wa
  link: https://cooli7wa67@163.com
---
公司使用repo管理多个project，使用gerrit作为代码审核。
为了方便为gerrit上的多个project创建同名分支，减少错误和遗漏，需要做一个自动化工具。
查阅了一些资料，有两种方式可以做，SSH和REST API

## SSH

就是走的很熟悉的SSH协议，使用这种方式，前提是gerrit账号有配置当前机器的rsa pubkey（gerrit网页，Settings -> SSH Public Keys）。

使用方式很简单，比如我想在test这个project下，基于master创建一个叫abc的分支：

```shell
# 'ssh' -p <port> <host> 'gerrit create-branch' <PROJECT> <NAME> <REVISION>
ssh -p 29418 cooli7wa@mygerrit.com.cn gerrit create-branch test abc master
```

-p 29418，是gerrit默认的ssh 端口

cooli7wa，替换成你的gerrit的账号名

mygerrit.com.cn，替换成你的gerrit网址

如果在~/.ssh/config中配置过默认的用户名，就可以省略掉cooli7wa@，比如这样

```shell
Host mygerrit.com.cn
  Hostname 192.168.8.248
  Port 29418
  User cooli7wa
```

这样就可以了，在Branches里，可以看到刚创建的分支

![]({{site.baseurl}}/images/md/./REST_API_001_7b47.png)

这种方式简单，但是也有弊端，**SSH可以支持的命令有限**，比如“删除分支”就没有。。

全部支持的命令，[可以看这里](https://gerrit-review.googlesource.com/Documentation/cmd-index.html)

所以这个还不能满足我们的需求。

## REST API

REST API是走的HTTP协议，使用GET、PUT、POST、DELETE等常见的HTTP命令，比SSH支持的命令多太多了，我们最关心的删除分支，自然包括在内。

既然使用的是HTTP协议，在某些操作的时候（比如PUT、DELETE），自然需要提供账号和密码，发送给gerrit。

但是这里有几个容易掉的坑：

### 1. 关于账号和密码

大家在登录gerrit的时候，需要输入账号和密码，在使用REST API的时候，理所当然的认为也应该是这个，其实不然。账号是这个账号没错，但是密码不是。

我们公司的服务器是gerrit+apache，可能大多数公司都是类似这样的组合，平时输入的账号和密码，其实是apache来验证的，与gerrit无直接的关系，自然不能用在gerrit的REST API上，**应该使用HTTP Password**，这密码在这里：

![]({{site.baseurl}}/images/md/REST_API_002_4da0.png)

如果密码是空的，就点下面的那个Generate Password按键，这个密码记录下来，以后会用

### 2. 关于gerrit endpoint

默认的REST endpoint（比如"/projects/test/branches/"），是匿名的，也就是说，如果直接通过HTTP协议访问这个endpoint，在gerrit看来，你是匿名访问的，那么权限就会有限（这个看gerrit的权限配置）。**需要在前面增加"/a/"**，也就是"/a/projects/test/branches/"，这样才是鉴权的endpoint，所谓鉴权，就是需要提供账号和密码，也就是上面说的。

### 3. 关于gerrit端口

这个也与gerrit+apache的组合有关，访问gerrit的网址（比如mygerrit.com.cn）时，其实不是直接访问到gerrit，而是先访问到apache，apache再转发到真实的**gerrit的端口**上，这时gerrit服务才能接收到信息。

而REST API中使用的，应该是**gerrit的真实地址，也就是网址+gerrit的端口**，比如我们的gerrit实际的端口是8081，那么这个地址就应该是mygerrit.com.cn:8081（这里真是掉坑无数，我和同事都先后掉到这里，而且我也没在gerrit的官方文档中看到关于这里的提示，网上也没看到有人提示这里）

### 4. 关于HTTPDigestAuth 和 HTTPBasicAuth

最后一点需要提醒的是，HTTP协议里，账号和密码由两种鉴权方式，一种是Digest，一种是Basic，应该用哪种取决于gerrit的配置（gerrit/etc/gerrit.config）

![]({{site.baseurl}}/images/md/REST_API_003_ae57.png)

如果这里配置了，gitBasicAuth = true，那么应该使用Basic，否则就使用Digest

我们公司默认是Digest



好了，这几点都介绍完了，可以开始用了，下面的例子都以创建和删除分支为例，其他更多的命令可以查看[官方文档](https://gerrit-review.googlesource.com/Documentation/rest-api.html)。

这里给出两种实现方式，一种是使用curl，一种是使用python的pygerrit库

### curl实现

```shell
# 创建分支
# revision，是基于的分支或者commit id
# 注意URL中的/a/
curl -u cooli7wa:WRach3vif7r8cpYn5Gc4QQUySFFBqi9u3oBlWtYTmQ --digest -X PUT http://mygerrit.com.cn:8081/a/projects/test/branches/abc -H "Content-Type: application/json" -d '{"revision":"master"}'
# 删除分支
curl -u cooli7wa:WRach3vif7r8cpYn5Gc4QQUySFFBqi9u3oBlWtYTmQ --digest -X DELETE http://mygerrit.com.cn:8081/a/projects/test/branches/abc
```

### python实现

```python
from pygerrit2.rest import GerritRestAPI
from requests.auth import HTTPDigestAuth, HTTPBasicAuth

GERRITE_USER = "cooli7wa"
GERRITE_PWD = "WRach3vif7r8cpYn5Gc4QQUySFFBqi9u3oBlWtYTmQ"
GERRITE_URL = "http://mygerrit.com.cn:8081/"

GERRITE_URL_CREATE_BRANCH = "/projects/test/branches/abc"

auth = HTTPDigestAuth(GERRITE_USER, GERRITE_PWD)
rest = GerritRestAPI(url=GERRITE_URL, auth=auth)

# 创建分支
ret = rest.put(GERRITE_URL_CREATE_BRANCH)
# 删除分支
#ret = rest.delete(GERRITE_URL_CREATE_BRANCH)
print(ret)
```

<完>
<script type="text/javascript" src="https://cdn.mathjax.org/mathjax/latest/MathJax.js?config=default"></script>
