---
layout: post
title: PeerCoin_PoS源码
description:
categories: study
author:
  name: cooli7wa
  link: https://cooli7wa67@163.com
---
之前学习了 PeerCoin 的白皮书，这篇就一起看下核心的 PoS 机制，PeerCoin 是 PoS 的鼻祖，所以还是很有代表性。

从 CreateNewBlock (src/main.cpp) 开始：

![]({{site.baseurl}}/images/md/peercoin_PoS_0.png)

![]({{site.baseurl}}/images/md/peercoin_PoS_1.png)

创建 coinstake 的主要流程都在 CreateCoinStake (src/wallet.cpp) 内：

![]({{site.baseurl}}/images/md/peercoin_PoS_2.png)

![]({{site.baseurl}}/images/md/peercoin_PoS_3.png)

![]({{site.baseurl}}/images/md/peercoin_PoS_4.png)

![]({{site.baseurl}}/images/md/peercoin_PoS_5.png)

这里说下手续费

我们知道，在比特币里，手续费是支付给矿工的，作为打包的报酬，而矿工自己是不用支付手续费的。而在 PeerCoin 内，手续费是直接消耗掉的，不支付给任何人，包括矿工，而矿工自己也需要支付手续费。

至于这么做的目的，有两点：

1. 解决了矿工之间由于互相竞争，导致不合作的问题。
2. 遏制通货膨胀。

到这里，整个 PoS 的流程就介绍完了，PeerCoin 是从比特币 fork 出来的，所以很多基础流程是差不多的。

那么 PeerCoin 的 PoS 的优势在哪呢，我觉得有如下这些：

- 加快了区块的产生
- 降低了能源的消耗
- 其他一些机制，比如通过去除手续费，来避免矿工间的竞争；对通货膨胀的考虑等。<script type="text/javascript" src="https://cdn.mathjax.org/mathjax/latest/MathJax.js?config=default"></script>
