---
layout: post
title: Bitcoin Address
description:
categories: study
author:
  name: cooli7wa
  link: https://cooli7wa67@163.com
---

## 遗留（Legacy）/支付公钥哈希（P2PKH）地址
今天，这类型的地址在交易中使用最多的空间，因此也是最昂贵的地址类型。不过这类地址很容易识别，因为这些地址都是以「1」开头的。

## 支付脚本哈希 Pay-to-Script-Hash（P2SH）地址
与传统以「1」开头的地址相比，P2SH 地址不是公钥的哈希，而是涉及某些技术脚本的哈希，可用于要求多重签名的转账事宜等，甚至可以利用隔离见证节省交易费用，发送到 P2SH 地址比使用旧地址的钱包便宜约 26%。

## 隔离见证地址（SegWit）Bech32 地址
Segwit 地址也称为 Bech32 地址，它们的特性是以 bc1q 开头。这种类型的比特币地址减少了交易中存储的信息量，它们不在交易中存储签名和脚本，而是在见证中，因此，相对 P2SH 地址，Segwit 地址可以节省大约 16% 的交易费用，相对传统地址，节省 38% 以上的费用。由于这种成本节约，它是最常用的比特币交易地址。

## 主根（Taproot）地址
为了提高区块空间的效率并改善费用，SegWit 在地址的构造方式上引入了一些变化。因此在 SegWit 地址的基础之上，开发出了以「bc1p」开头的 Taproot 地址，翻译为主根地址，这类地址进一步减小了存储空间，提高了交易效率，并提供了更好的隐私性。

https://www.theblockbeats.info/news/37101

<script type="text/javascript" src="https://cdn.mathjax.org/mathjax/latest/MathJax.js?config=default"></script>