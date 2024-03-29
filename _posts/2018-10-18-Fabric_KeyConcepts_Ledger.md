---
layout: post
title: Fabric_KeyConcepts_Ledger
description:
categories: study
author:
  name: cooli7wa
  link: https://cooli7wa67@163.com
---
这篇看下 Key concepts 的最后一篇文章，账本。

### A Blockchain Ledger

在账本里包含两个部分，世界状态和区块链。

世界状态记录的是键值对，键值对的值来源于区块链，区块链记录了所有的交易日志，像上节说的，这些交易包含有效和无效的，有效的交易会影响到世界状态，而无效的只是一份记录而已，为了以后的查账，区块链本身不能更改。

### World State

![]({{site.baseurl}}/images/md/hyperledger_fabric_key_concepts_Ledger_0.png)

每条叫做一个 state，每个 state 都有一个 version，每次 state 改变的时候，version 都会增加，所以这个也被用在节点接收区块之前的校验里，需要保证当前的 version 和交易创建的时候的相符合。

世界状态可以在任何时候通过区块链重新生成。

### Blockchain

![]({{site.baseurl}}/images/md/hyperledger_fabric_key_concepts_Ledger_1.png)

H* 中包含本区块的所有交易的哈希和前一个区块的哈希。

genesis block（创世区块）不包含任何的交易，它包含 channel 的配置的初始状态。

### Blocks

![]({{site.baseurl}}/images/md/hyperledger_fabric_key_concepts_Ledger_2.png)

- Block Header，区块头
  - Block number，每个区块增加 1
  - Current Block Hash，当前区块的哈希
  - Previous Block Hash，前一个区块的哈希
- Block Data，区块数据，包含所有的交易
- Block Metadata，区块 meta 数据，包含创建的时间，证书，公钥，签名，也包含有效/无效的标识。

### Transactions

![]({{site.baseurl}}/images/md/hyperledger_fabric_key_concepts_Ledger_3.png)

- Header，包含一些必要的 meta 数据，比如相关联的 chaincode 的名字和 version。
- Signature，应用的签名
- Proposal，应用提供的输入参数
- Response，包含交易前和之后的世界状态，这个是可读写的，如果交易是有效的，那么这里的数值，最终会被记录到世界状态。
- Endorsements，这里是一系列签过名的交易的 response，就是所有的背书。

### World State database options

数据库可以使用 LevelDB 和 CouchDB，LevelDB 适合于键值对形式的数据，而 CouchDB 适合于JSON 格式的数据。从这里可以看出来 fabric 的一个重要的特性，可插拔性。<script type="text/javascript" src="https://cdn.mathjax.org/mathjax/latest/MathJax.js?config=default"></script>
