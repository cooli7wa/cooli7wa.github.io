---
layout: post
title: 模版
description:
categories: [study|essay|play|report|tools]
author:
  name: cooli7wa
  link: https://cooli7wa@126.com
---

Celestia 是一条模块化的 Layer1 区块链，专注于排序交易并验证已发布的数据是否可用。Celestia 的核心理念是实现模块化的区块链架构，使得开发者在构建区块链的开发过程中可以摆脱单一架构的限制，以便开发者可以在 Celestia 的基础上按照他们的需求灵活地进行开发。
Celestia 的模块化分为执行层 (Execution Layer)，结算层 (Settlement Layer) 和共识与数据可用性层。
TIA 是其代币。

1. 执行层
由 Rollups 组成，负责执行交易。Celestia 利用 Rollups 为执行层提供了多样化的可选方案。除了支持 Optimistic Rollup 和 zkRollup 外，围绕 Celestia 构建的 dYmension、Eclipse、Fuel 等 Rollup 方案让公链链接 Cosmos 和 Solana 生态项目成为可能。
2.  结算层
目前值得关注的是 Celestia 与 Evmos 合作开发的结算层 Cevmos，它将以 Evmos 为基础，构建 EVM 的递归 Rollup。每个基于 Cevmos 构建的 Rollup 都存在一个与 Cevmos 的双向桥，可以重新部署以太坊上已有的 Rollup 合约与应用，以此来减少应用迁移所需的工作。
3.  共识与数据可用性层
这一层负责数据的可用性和共识机制。所有格式的数据都将传送到数据可用性层。节点会以它从结算层接收到数据的相同格式来存储数据。系统通过 $TIA 激励节点存储数据，而节点使用 Reed-Solomon 编码以及专门的 Namespaced Merkle Trees 数据结构来确保数据的可用性。

![]({{site.baseurl}}/images/md/a.png)

<script type="text/javascript" src="https://cdn.mathjax.org/mathjax/latest/MathJax.js?config=default"></script>
