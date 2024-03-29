---
layout: post
title: Fabric_introduction
description:
categories: study
author:
  name: cooli7wa
  link: https://cooli7wa67@163.com
---
前些天参加了在北京举行的可信区块链峰会，各大公司的落地区块链产品大部分是基于联盟链的，而其中使用最多的就是 hyperledger fabric，而且很多安全方面的公司的产品也是针对 fabric 的，从 fabric 公开的材料中得知，中国已经注册了 50 多家会员单位，算上使用但还没注册的应该更多，可见 fabric 的影响力之大。我虽然之前看了一些文章和视频介绍 fabric，但是理解不深，所以最近开始深入学习下 fabric 的相关知识，就从 [官方文档](https://hyperledger-fabric.readthedocs.io/en/latest/whatis.html) 开始吧。

### Introduction

这段主要介绍了 fabric 为企业级用户设计的一些考量：

- 成员必须是可识别的
- 网络应该是许可制的
- 交易效率高
- 交易时间短
- 对于商业交易的隐私性保护

### Hyperledger Fabric

介绍了 fabric 与其他流行的分布式账本和区块链平台的区别。

- 隶属于 linux 基金会，一个开源的平台，由超过 35 个机构和接近 200 名开发者维护。
- 模块化和可配置化，适用于银行、金融、保险、健康、人力资源、供应链和数字音乐发布等领域。
- 是第一个支持智能合约 (chaincode) 的分布式账本，且账本语言支持 Java、Go、Node.js 等流程语言，减少了学习成本。
- 平台是许可制的，节点间互相了解（虽然可能不完全信任），不匿名。
- 可插拔的共识机制。比如，CFT (crash fault-tolerant) 和 BFT (byzantine fault tolerant) 可以根据实际场景进行切换。
- 不需要发行代币，也就省掉了挖矿的消耗，使性能和其他分布式系统相似，且减少了签名相关的风险和攻击。
- 支持隐私和保密交易

### Modularity

介绍 fabric 中使用的模块：

- 可插拔的 ordering service，用来排序交易、生成区块和广播给其他节点
- 可插拔的 membership service，用来验证用户的身份
- 可选的 peer-to-peer gossip service，用来节点间的提供服务
- chaincode 智能合约，比如在 docker 环境内运行，提供隔离。
- 账本支持一系列的 DBMS (Database Managerment System)
- 可插拔的背书和验证策略

### Permissioned vs Permissionless Blockchains

这段主要对比了介绍了许可制的优点。

没有许可制的区块链中，任何人都可以加入，且是匿名的，为了弥补这种信任的缺失，需要采用类似挖矿和手续费的方式来提供激励。

而在许可制的区块链中，区块链的相关操作是在一系列已知、可识别、审核的节点间进行，提供了一定程度的信任基础，所以可以使用类似 CFT 和 BFT 的共识算法。

另外在许可制的网络中，节点恶意攻击的可能性降低，因为节点间互相了解，且作恶行为会被记录。

### Smart Contracts

智能合约的三个关键点是：

- 网络中的智能合约间可以协作
- 可以动态发布合约
- 调用合约的应用代码，应该被认为是不可信的或者是恶意的

前面讲到了，fabric 支持很多流行语言，不是像 eth 只支持 solidity。eth 只支持 solidity 的原因，作者讲是因为为了得到确定性的结果（支持多语言，可能遇到结果不一致问题），但是会导致学习成本上升。fabric 通过流程的调整解决了这个问题，后面会说。

### A New Approach

execute-order-validate，是新的交易处理流程，每步骤如下：

- *execute* a transaction and check its correctness, thereby endorsing it,
- *order* transactions via a (pluggable) consensus protocol, and
- *validate* transactions against an application-specific endorsement policy before committing them to the ledger

application-specific endorsement policy 指的是，对于每个交易，只有所有背书节点中的一部分来进行背书，这样所有节点就可以并行计算。

另外第一个阶段也保证了确定性，因为保证了确定性，所以 fabric 才能很轻松的支持多合约语言（各种合约语言导致的不确定性问题，在第一阶段就解决了）。

### Privacy and Confidentiality

这里讲了在商业上隐私的重要性，并且提出了一些解决隐私问题的方法，比如加密数据、零知识证明等。在 fabric 内使用的是 channel 的方式，channel 连接特定的一些节点，对外不可见。以后还会推出基于零知识证明的私有数据的方式。

### Pluggable Consensus

现阶段 fabric 提供了 基于 Kafka 和 Zookeeper 实现的 CFT共识算法，以后会推出 Raft 和 BFT 的共识算法。

### Performance and Scalability

我们知道，很多联盟链使用的共识算法，对于节点数量比较少的情况，性能都很好。这段主要说的是 1.1.0 版本（现在是 1.3.0）性能又有了很大的提升，比 1.0.0 有了超过两倍的提升。

<script type="text/javascript" src="https://cdn.mathjax.org/mathjax/latest/MathJax.js?config=default"></script>
