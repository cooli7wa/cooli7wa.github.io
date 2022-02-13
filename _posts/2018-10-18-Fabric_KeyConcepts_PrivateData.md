---
layout: post
title: Fabric_KeyConcepts_PrivateData
description:
categories: study
author:
  name: cooli7wa
  link: https://cooli7wa67@163.com
---
从之前学习的内容知道，fabric 不止提供了 channel 间的隐私保护，还提供了 channel 内的隐私保护，叫做 private data collection，可以在 channel 内创建私密通道，只有私密通道的成员才能修改和查看具体的私密数据，可以说是进一步扩展了 fabric 的使用场景。

### What is a private data collection?

包含下面两个方面：

- 实际的私密数据。通过组织节点间的 gossip 协议来传输，保存在节点的私有数据库内（SideDB），ordering service 看不到私密的数据。如果想使用 gossip，那么组织之间必须建立 anchor peer（锚节点）。
- 私密数据的哈希。哈希数据会被背书、排序并写入到每个（注意是每个）节点的账本里，用来证明数据的有效性，便于以后的查账。

看下面这张图：

![]({{site.baseurl}}/images/md/hyperledger_fabric_key_concepts_PrivateData_0.png)

注意其中的 private state 和 hash。

### Transaction flow with private data

看下涉及到私密数据的交易流程，与常规的有些不同：

1. 应用创建交易的提议，有关的私密数据或者生成私密数据的数据放到提议的 transient 域内，并将提议传给背书节点。
2. 背书节点模拟执行智能合约，然后将产生的私密数据存放到节点本地的 transient data store 内（临时的），然后根据 collection 规则，将私密数据通过 gossip 传递给其他被授权的节点。
3. 背书节点将提议的结果中的公开数据和私密数据的哈希发回给应用，这里面没有私密数据。
4. 像往常一样，应用将交易提交给 ordering service，然后 ordering service 将区块发给所有节点。
5. 所有节点接收到区块之后，先验证下自己时候有权利获得私密数据，如果有的话，需要先检查下自己的 transient data store 中是否已经接收到背书阶段的私密数据，如果没有的话就尝试从其他节点获取数据，然后验证下数据的哈希值是否和区块中的一致，然后才将私密数据真正写入到自己的数据库内，并删除 transient data store 中的数据。

### Purging data

在有些场景可能想清理掉节点的私密数据，fabric 将来也会提供这种功能。<script type="text/javascript" src="https://cdn.mathjax.org/mathjax/latest/MathJax.js?config=default"></script>
