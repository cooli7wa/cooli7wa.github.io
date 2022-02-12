---
layout: post
title: Fabric_KeyConcepts_Peers
description:
categories: study
author:
  name: cooli7wa
  link: https://cooli7wa67@163.com
---
前面学习了 MSPs，这篇来详细看下 Peers 相关的知识。

[原文](https://hyperledger-fabric.readthedocs.io/en/release-1.3/peers/peers.html) 在这里，这篇文章的前半部分详细介绍了一些 Peer 、Ledger、Application、Chaincode、channel 之间的关系，这里前面的学习中都有所了解，在这里就不详细介绍了，这里主要看下 query 和 update 的详细流程。

这张图介绍了 query 和 update 的梗概，1-3 是 query，4-5 是 update：

![]({{site.baseurl}}/images/md/hyperledger_fabric_key_concepts_Peer_0.png)

在文章的后面，将这个过程又做了重新的划分，分为了 3 个阶段，我们一个个来看下：

### Phase 1: Proposal

![]({{site.baseurl}}/images/md/hyperledger_fabric_key_concepts_Peer_1.png)

从 application（应用） 发送 propose（提议）到 endorsing peer（背书节点），然后背书节点返回背书结果给应用（这个阶段中用不到 orderers（排序节点））。

应用产生提议之后，应该发送给哪些背书节点？这个是由背书规则（智能合约中定义）决定的。

背书节点做些什么？每个背书节点单独使用提议的内容执行智能合约，得到 response（图中 R\*），然后对 response 进行签名得到背书（图中 E\*），将反馈和背书打包后返还给应用。

应用在收到足够的背书之后，第一阶段就成功结束了。

那么如果应用收到的反馈结果不同怎么办？

首先说下什么情况会导致反馈结果不同，一种是背书节点的账本状态不对，比如比较老，那么通过智能合约计算出来的结果就可能跟别人的不一样，第二种是因为智能合约的编程语言有很多种，可能得到不确定性的结果。

那么第一种情况，应用可以通过简单的发送 up-to-date 提议来让节点更新（第二种文章没介绍怎么处理），如果结果还是不同，那么节点可以选择终止后续的交易，实际上如果不终止，后续的流程中也会被拒绝。

### Phase 2: Packaging

![]({{site.baseurl}}/images/md/hyperledger_fabric_key_concepts_Peer_2.png)

在这个阶段中，orderer 是核心。orderer 从很多的应用处接收交易，然后将这些交易排序打包到区块内，然后将区块发布给所有链接到 orderer 的节点上，包括之前背书的节点。

需要注意的一点是，排序的顺序与接收到的顺序很可能是不一样的。

另外，交易一旦被写入区块，它的位置就确定了，分叉和重写永远不会发生。

这里没有具体讲排序的规则是什么样的，但是这里一定有一个规则，而且不是根据接收时间计算的。

### Phase 3: Validation

![]({{site.baseurl}}/images/md/hyperledger_fabric_key_concepts_Peer_3.png)

这个阶段，orderer 节点发布区块，然后每个节点验证区块中的每笔交易，并写入账本。

发布前面已经说了，这里需要注意的是，不是每个节点都需要连接到 orderer 来获取区块，也可以通过 gossip 等方式来获取区块。

那么需要验证哪些东西呢？

首先，交易的背书是否符合背书规则（在智能合约中定义）的要求，并且背书的反馈是否是相同的，另外还需要检查本地账本的状态是否和交易背书的时候的状态一致，因为这段时间可能发生了一些交易，改变了交易的初始状态。

如果验证都通过，那么这笔交易就会被写到账本里，如果失败，那么交易不会被写入账本，但是会被保留以便查账，所以在节点内，区块的状态与 orderer 发过来的基本是一致的（除了有些有效和无效的标记），但是不是区块内的所有交易都被写到了账本里，只有验证过有效的才会被写到账本里。

另外需要注意的一点是，智能合约在这个阶段中是不需要被执行的，合约只需要在第一阶段执行。

最后，节点会根据验证结果发送一些事件，比如 block events、block transaction events、chaincode events，应用可以注册监听这些事件，比如交易验证失败的事件，可以做些后续的处理。

### 一些感想

看到这，联想到之前 fabric 介绍中所说的共识算法，fabric 现在针对的场景还是 CFT，也就是节点只有故障没有作恶，从上面的共识过程看，很简单，没有类似 PBFT 那种多阶段共识的流程，fabric 的计划是后续加入 BFT 的支持，现在还没有。

另外 fabric 这种分阶段分节点处理不同事物的方式，使结构和流程很清晰，并且可以应对并发的情况，挺不错的。<script type="text/javascript" src="https://cdn.mathjax.org/mathjax/latest/MathJax.js?config=default"></script>
