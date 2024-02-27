---
layout: post
title: Stacks - Bitcoin L2 
description:
categories: study
author:
  name: cooli7wa
  link: https://cooli7wa@126.com
---

## Stacks 和 Bicoin 的关系
Stacks 是 Bitcoin 的 L2，不过有自己的代币（STX），这点和一般的 L2 不同。

## Stacks 的共识算法（PoX）
Stacks 共识算法（PoX）依赖 Bitcoin 的共识（PoW）。文档说 PoX 与其他链使用的 PoB（power of burn）类似，不同一般情况不销毁 Bitcoin，而是将其奖励给维持链活性的 Stackers。Stacks 上竞争出块的矿工，需要支付 Bitcoin，根据 Bitcoin 的多少决定出块概率。PoX 通过 VRF（verifiable random function）来选择出块的矿工，此矿工可以获得 STX 奖励，相当于用 Bitcoin 换取 STX。Stacker 根据持有的 STX 多少和参与出块的程度，获得对应比例的矿工支付的 Bitcoin。
Stackers 会预置一些自己的 Bitcoin 地址到地址集合，每次出块，矿工会随机选择一些地址转入 Bitcoin，一旦被选择一次，那么此地址被移除出集合。如果地址集合中的地址不够，那么还是可能会有 Burn 地址来凑数。 

## 谁来提交 Bitcoin 交易给 Stacks 验证？
矿工 在 Stacks 上提交转账 Bitcoin 的交易。

## 什么是 sBTC？BTC 怎么转的 sBTC？sBTC 和 STX 什么关系？
sBTC 是 BTC 在 Stacks 上的映射，相当于解决了 BTC 的流动性问题。Bitcoin 上有一个多签的脚本地址，转给此地址的 BTC 会被转为同等金额的 sBTC，在必要的时候，可以重新转为 BTC。Stacks 有一个 Bitcoin layer 来监听事件。sBTC 和 STX 没有啥关系，STX 是 Stacks 的原生代币。

## 其他
Stacks 会将自己的账本 hash 记录在 Bitcoin 上（我没找到记录的方法，我估计是在交易脚本记录的方式），来作为验证的依据，提高自己链的可信度。

## 一些疑问和题外话
PoX 让矿工花费 BTC 来换取 STX，而且花费的越多，能得到 STX 的概率就越高。这让我有些怀疑？有矿工愿意这么做吗？将目前价值最高的数字货币换成一个新出现的货币？而且这种做法貌似也不是必须的，大多数有代币的链，都不是这么做的。Stacks 这样有点敛财的感觉呢。

虽然 Stacks 的 PoX 和之前的 PoB 有所不同，PoX 大概率不会销毁 BTC（除非地址集合不足，会用 Burn 地址充数），但是还有概率会销毁 BTC 的。作为一个 L1 链 的 L2，却要影响到 L1，而且还要销毁 L1 上本就不多的代币，如果此 L2 真的发展起来，那么 L1 还怎么玩？慢慢的不就是取而代之了吗？这很让人费解。 


<script type="text/javascript" src="https://cdn.mathjax.org/mathjax/latest/MathJax.js?config=default"></script>
