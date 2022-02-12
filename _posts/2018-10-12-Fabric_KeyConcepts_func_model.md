---
layout: post
title: Fabric_KeyConcepts_func_model
description:
categories: study
author:
  name: cooli7wa
  link: https://cooli7wa67@163.com
---
之前看了 fabric 的介绍，这篇就开始进入正题，深入学习下各种概念和特性。这里内容很多，介绍了 fabric 的方方面面，所以会陆续更新一系列文章。

这篇介绍 Functionalities 和 Model，内容不多。

### Hyperledger Fabric Functionalities

- Identity management，许可网络有进入控制，这可以做额外的鉴权操作，比如有的 id 可以发布新的 chaincode，而有的 id 只能调用 chaincode
- Privacy and confidentiality，通过 channel 的方式来达到隐私和保密的效果，对于没有权限进入 channel 的节点，无法查看 channel 内信息。
- Efficient processing， fabric 将交易执行的整个过程分离为 ordering 和 commitment，并分配给不同类型的节点来做，这样的分离使得并行计算成为可能。
- Chaincode functionality，这里谈到两点，第一点是一般的 chaincode 提供的资产转移方式就有相同的规则和需求，公开透明。第二点是 system chaincode 定义了各个 channel 的参数、规则，也定义了背书和验证的一些需求和规则。
- Modular design，模块化设计是 fabric 的一大特点，模块的优势一般就是容易维护和移植，这在 fabric 上体现为，各种机构和组织开发和使用的模块能够互相配合。

### Hyperledger Fabric Model

这里主要是介绍了 fabric 的一些关键特性，主要包含下面这些方面：

- Assets，资产范围很广，从虚拟到实物都可以，资产的表现可以是二进制或者 JSON 格式。
- Chaincode，交易的主要逻辑。
- Ledger Features，每个 channel 都有自己的 ledger，ledger 主要是记录了不可变的序列的记录，而 state 是通过数据库存储的各个节点的 key-value 值。从 ordering service 发来的交易，每个节点都需要验证，验证是否符合背书规则，在写入区块之前，还需要验证状态在处理这段时间内没有被更改过。一旦写入区块链，那么交易就是无法改变的。每个 channel 的 ledger 都包含一些配置、权限等规则。
- Privacy，隐私性方面，前面已经说过了，fabric 主要是通过 channel 和 private data 方式来保护，channel 在整个网络中划分了私密的通道，在通道之内的成员，还可以成立各个组织，各个组织之间是通过 private data 来保护的，这里也叫做 collection。
- Security & Membership Services，这就是成员的许可机制，已经说过了。
- Consensus，这里文章说的主要意思是，现在共识机制就像是算法的同义词，只负责交易的提交，但是在 fabric 里共识体现在方方面面，在提议、背书、排序、验证、提交的整个流程中都在使用。

<script type="text/javascript" src="https://cdn.mathjax.org/mathjax/latest/MathJax.js?config=default"></script>
