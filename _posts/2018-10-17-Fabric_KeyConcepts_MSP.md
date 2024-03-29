---
layout: post
title: Fabric_KeyConcepts_MSP
description:
categories: study
author:
  name: cooli7wa
  link: https://cooli7wa67@163.com
---
之前看过了 fabric 的网络架构，这篇来学习下 fabric 中很重要的 MSP (membership service provider) 相关的知识。

### Identity

身份（Identity）决定了对区块链中资源获取和使用的权利。

principal 包含了更广泛的身份信息，比如用户的组织、部门、角色等。

MSP (membership service provider) 用来对身份提供可信任的鉴权，默认实现是使用 X.509 证书，采用 PKI (Public Key Infrastructure) 分层模型。

Fabric 提供了一个私有的 CA 来处理证书，也可以使用公开的或者商业的 CA。

### MSP

- 机构通过 MSP 来管理他们的成员。每个机构的 MSP 不一定只有一个，对于不同的业务可能有不同的 MSP。

比如下面这张图：

![]({{site.baseurl}}/images/md/hyperledger_fabric_key_concepts_MSP_0.png)

- Organizational units (OUs) 组织部门，是指每个组织内可以有不同的业务线，证书内的 OU 域，就是指这个证书可以应用于哪个业务线，使得权限控制可以细分到组织内的不同部门。
- MSPs 按照作用域分为 Local MSP 和 Channel MSPs，Local MSPs 是为了clients (users) 和 nodes (peers 和 orderers)，每个 node 和 user 都必须有 local MSP，用来确定哪些请求者是组织内的成员，channel 的配置里包含不同组织的 MSP，因为 channel 的 MSPs 是对所有节点有效的，所以所有节点都另外存有 channel MSPs 的备份，并且通过共识算法同步。
- MSPs 按照等级分为 Network MSP、Channel MSP、Peer MSP、Orderer MSP，前两个是 Global MSP，或两个是 Local MSP。
  - Network MSP，定义了网络成员列表，和谁可以可以管理任务（比如创建 channel等）。
  - Channel MSP，定义了 channel 成员列表，和谁可以添加成员和实例化合约等。
  - Peer MSP，定义了组织的成员列表，和谁可以在 peer 上安装合约等。
  - Orderer MSP，也是定义了组织的成员列表，不过是在 Orderer 节点上。
- MSP 结构
  ![]({{site.baseurl}}/images/md/hyperledger_fabric_key_concepts_MSP_1.png)
  - Root CAs，根 CA
  - Intermediate CAs，中间 CA
  - Organiztional Units (OUs)，组织部门
  - Administrators，管理者
  - Revoked Certificates，作废的证书
  - Node Identity，节点身份
  - KeyStore (private keys)，私钥库
  - TLS Root CA，TLS（传输层安全协议）根 CA
  - TLS Intermediate Ca，TLS 中间 CA

<script type="text/javascript" src="https://cdn.mathjax.org/mathjax/latest/MathJax.js?config=default"></script>
