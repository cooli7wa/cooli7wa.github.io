---
layout: post
title: Fabric_KeyConcepts_network
description:
categories: study
author: cooli7wa
---
这篇学习 fabric 的网络架构，[官方文档](https://hyperledger-fabric.readthedocs.io/en/release-1.3/network/network.html) 在这里，写得很全面也容易懂，这里就不详细介绍了，这篇主要是总结下一些关键点。

### 整体网络架构

先看下官方的这张图：

![]({{site.baseurl}}/images/md/hyperledger_fabric_network_0.png)

初看这张图感觉挺迷糊的，各种符号和图标很多，官方文档从头一点点介绍了这个网络的构建过程，看过之后就觉得很清晰了，不过我这里就不这么介绍了，我主要想从这张图开始，总结下图上的各个图标符号的意义和互相之间的联系，方便大家对整个架构有一个快速的了解。

主要介绍下面这些：

- 图标及缩写的含义
- 其他符号的含义
- 各个部分的作用和联系
- 交易流程和节点类型

### 图标及缩写的含义

- R*，比如 R1 ~ R4，R 代表的是 organization (机构)，也就是联盟链内的各个联盟成员。
- \*C\*，比如 NC4、CC1、CC2，C 代表的是 configuration (配置)，NC 代表的是 network config，CC 代表的是 channel config。
- P*，比如 P1 ~ P3，P 代表的是 peer (节点)。
- S*，比如 S5 、S6，S 代表的是 smart contract (智能合约)。
- L*，比如 L1、L2，L 代表 ledger (账本)。
- O*，比如 O1，O 代表 ordering service (排序服务)。
- A*，比如 A1 ~ A3，A 代表 application (应用)。
- CA*，比如 CA1 ~ CA4，CA 代表 Certificate Authority (证书授权中心)。
- C*，比如 C1、C2，C 代表 channel (频道)。
- N，代表 network (网络)。

### 其他符号的含义

C1 和 C2 的椭圆形代表 channel，与 channel 有线连接的对象，代表属于此 channel，上面的圆，标注 1 或 2，也是这个意思。

### 各个部分的作用和联系

- NC*，是整个网络的基础配置，最开始由 R4 创建，在 R1 加入之后，可以由 R1 和 R4 共同维护和更改。配置包含但是不限于访问控制、管理资源。
- CC*，每个 channel 都有自己的配置 (CC)，这个是与 NC 独立的，channel 内的规则都是由 CC 唯一确定的，由 channel 内的成员来维护和更改。一旦 channel 创建了，NC 就再也无法影响 channel。
- ordering service，排序服务节点，虽然图中是一个，但是实际上可以有多个。主要是收集应用的背书过的 transaction，通过共识排序生成 block，然后发送给 channel 内的节点来记录。除了这个还负责批准节点加入 channel 的请求，等等这个不是跟独立有所矛盾么？其实虽然请求是发给 ordering service，但是是根据 channel 自己的 CC 来决定是否可以加入的，所以实际上还是 channel 本身在控制。
- ledger，每个 channel 有自己的账本，channel 内的 peer，都需要保存一份副本，保持同步。操作账本的规则都是 CC 规定的，所以账本物理上被节点拥有，逻辑上是 channel 拥有。
- smart contract，智能合约由组织的应用开发者来创建，用来产生交易，账本的所有操作都是通过智能合约。智能合约的创建本身有两个主要的操作，安装和实例化。安装是指将智能合约部署到 channel 内的某个节点上（不一定所有节点都需要部署），被部署的节点知道合约的全部内容，而其他节点或应用，只知道合约提供的接口，通过接口可以进行账本等操作。实例化是指将某个节点已经部署过合约这件事通知 channel 内的所有节点，通知过之后，智能合约才算真正有效。
  另外拥有智能合约的节点可以进行背书操作，通过根据应用传送的数据和自身的智能合约，经过执行和签名产生背书后的交易。
- 所有的节点都可以选择接受或者拒绝交易，但是只有拥有智能合约的节点才能够进行背书。
- 多个 channel 之间是隔离的，但是 channel 包含的机构可以重叠，某些机构因为业务需要可以加入到不同的 channel 里面，那么他们的节点，就可以同时拥有不同 channel 的账本和智能合约。
- policy 或者说 config，只要涉及到的机构达成共识就可以更改。

### 节点类型和交易流程

前面介绍了各个部分的名称和作用，现在看下每个 channel 内的节点的类型：

- committing peer，每个节点都是一个提交节点，记录区块到账本。
- endorsing peer，拥有智能合约的节点是背书节点，可以对应用提交的交易进行验证并背书。
- leader peer，每个 channel 可以拥有一个主节点，主节点接收 ordering service 发送过来的区块，并转发给其他节点。在静态模式，主节点是由配置固定的，可以有零或者多个，在动态模式，主节点是选举出的。
- anchor peer，锚定节点，主要是为了不同机构之间的通信，每个机构可以有零或多个锚定节点，应用于跨机构通信的场景。

再看下交易流程：

1. 应用根据需要构造交易提案，并发送给 channel 内的背书节点。
2. 背书节点模拟执行交易，然后将原始交易和执行结果打包并签名，发回给应用。
3. 应用收到背书节点的回应后，打包并签名发送给 ordering service。
4. ordering service 对收到的交易进行共识排序，然后按照策略来生成区块，并发送给对应 channel 内的 peer 节点。
5. peer 节点对区块内的交易进行验证，检查交易的输入输出是否正确，然后将区块写入账本。<script type="text/javascript" src="https://cdn.mathjax.org/mathjax/latest/MathJax.js?config=default"></script>
