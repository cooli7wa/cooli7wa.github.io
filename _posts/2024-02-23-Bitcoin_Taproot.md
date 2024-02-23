---
layout: post
title: Bitcoin Taproot
description:
categories: study
author:
  name: cooli7wa
  link: https://cooli7wa67@163.com
---

Taproot 是 Bitcoin 2021 的一次重要升级，再上一次还是 2017 年的 SegWit。

Taproot 带来的好处是更快、更便宜，也提升了隐私性、扩展性和可编程性。

包含三个 BIP，BIP340、BIP341、BIP342。

## BIP 340 - Schnorr Signatures

引入了 Schnorr 签名算法，替代之前的 ECDSA。这个算法是 Claus Schnorr 在 1991 年提出的，好处是什么呢？签名更小、验证速度更快、抗攻击性更好。 签名更小，体现在可以将多个签名聚合成一个签名。另外因为是聚合签名，所以更难分辨出单个签名用户，带了个更好的隐私性。对于抵抗虚假签名方面，也更出色。

## BIP 341 - Taproot

主要是引入了两个特性 MAST 和 P2TR。

MAST (Merkelized Alternative Script Trees)，类似于之前的 P2SH 使用的单个脚本，MAST 支持多个脚本，同样是在转账交易里植入脚本默克尔树的根，提取这笔钱就需要提供对应的脚本。

P2TR (Pay-to-Taproot) ，类似于之前的 P2SH 和 P2PK，新增的一种花费 Bitcoin 的方法而已。

## BIP 342 - Tapscript

这个使 Bitcoin 的脚本语言支持 Schnorr 算法、MAST 和 P2TR。

## 参考

https://chain.link/education-hub/schnorr-signature#:~:text=Schnorr%20allows%20for%20smaller%20signature,the%20sum%20of%20its%20keys.
https://trustmachines.co/learn/bitcoin-taproot-upgrade-basic-breakdown/

<script type="text/javascript" src="https://cdn.mathjax.org/mathjax/latest/MathJax.js?config=default"></script>
<script type="text/javascript" src="https://cdn.mathjax.org/mathjax/latest/MathJax.js?config=default"></script>
