---
layout: post
title: RLP和VarInt
description:
categories: study
author: cooli7wa
---
在区块链的世界里，一方面由于是分布式存储，一样的数据存储在所有的节点里，如果数据中包含无用的字节，那么在所有节点中浪费的总量就很客观，另一方面虽然数字货币的交易速率都不高，但是至少也有每秒几笔（比特币）到几十笔（以太坊），如果每笔交易中都包含一定的无用字节，那么时间长了，就会浪费掉非常大的空间。

所以在比特币和以太坊中都有一些为了减少浪费而做的设计。



### 比特币 VarInt

VarInt (VI) 在比特币的 transaction 里面使用很多，用来表示后面跟的数据的字节数。在之前的 [比特币-交易体](http://cooli7wa.com//2018/08/20/%E6%AF%94%E7%89%B9%E5%B8%81-%E4%BA%A4%E6%98%93%E4%BD%93/) 有过一些介绍，为了方便阅读这里再重复下，看下面这张图：

![]({{site.baseurl}}/images/md/transaction_3.png)

这是 transation TxIn 的一部分，里面的 VI 就是 VarInt，VI 的长度根据后面所跟数据的长度来变化，具体的定义：

![]({{site.baseurl}}/images/md/transaction_2.png)

如果数据长度小于 0xFD，那么就只有一个字节长度，本身就代表长度。

如果数据长度大于0xFD，那么第一个字节就是一个标示符，代表的是后面跟着的字节是什么类型的 Int，比如 uint16、uint32、uint64，这个 int 是数据的长度。

这种设计方式，目前已经为比特币节省了 10 多 G的存储空间。



### 以太坊 RLP（Recursive Length Prefix）

以太坊没有比特币那样复杂的交易体，只是一个简单的结构体，RLP 是用来解决结构体的编码问题。**注意必须是大端字节序**。

在 RLP 内也需要表示数据长度，所以也有类似 VarInt 的设计，先总体说下，然后看下代码。

#### 1. 概述

RLP 只针对两种数据结构，字符串和列表，对于字典数据，以太坊有两种建议的方式，一种是通过二维数组表达键值对，比如`[[k1,v1],[k2,v2]...]`，并且对键进行字典序排序；另一种方式是通过以太坊文档中提到的高级的[基数树](https://github.com/ethereum/wiki/wiki/Patricia-Tree) 编码来实现。

具体编码规则和例子如下：

![]({{site.baseurl}}/images/md/RLP_VarInt_0.png)

**字符串长度为 1 的情况比较特殊，列表的编码实际是个递归的过程，下面会说**

#### 2. 代码

这段代码来自 web3j，编码过程。

```java
public class RlpEncoder {

  	// 判断编码类别，字符串还是列表
    public static byte[] encode(RlpType value) {
        if (value instanceof RlpString) {
            return encodeString((RlpString) value);
        } else {
            return encodeList((RlpList) value);
        }
    }

  	// 编码流程，字符串和列表都是通过这个函数编码，只不过列表有一个迭代的过程
    private static byte[] encode(byte[] bytesValue, int offset) {
      	// 对应于字符串编码，且长度为 1 的情况
        if (bytesValue.length == 1
                && offset == OFFSET_SHORT_STRING // OFFSET_SHORT_STRING = 0x80
                && bytesValue[0] >= (byte) 0x00
                && bytesValue[0] <= (byte) 0x7f) {
          	// 直接返回字符串原文
            return bytesValue;
        // 长度小于 55 的情况
        } else if (bytesValue.length < 55) {
            byte[] result = new byte[bytesValue.length + 1];
            // offset，字符串是0x80，列表是0xc0
            result[0] = (byte) (offset + bytesValue.length);
            System.arraycopy(bytesValue, 0, result, 1, bytesValue.length);
            return result;
        } else {
          	// 得到长度的长度的字节数组
            byte[] encodedStringLength = toMinimalByteArray(bytesValue.length);
            byte[] result = new byte[bytesValue.length + encodedStringLength.length + 1];
			// offset，字符串是 0x80，列表是 0xc0，加上 0x37 之后，分别为 0xb7 和 0xf7
            result[0] = (byte) ((offset + 0x37) + encodedStringLength.length);
            System.arraycopy(encodedStringLength, 0, result, 1, encodedStringLength.length);
            System.arraycopy(
                    bytesValue, 0, result, encodedStringLength.length + 1, bytesValue.length);
            return result;
        }
    }

    static byte[] encodeString(RlpString value) {
        return encode(value.getBytes(), OFFSET_SHORT_STRING);
    }

  	// 根据长度的长度计算字节流，按照大端的顺序写入到字节数组里，选择非 0 的最小段
    private static byte[] toMinimalByteArray(int value) {
        byte[] encoded = toByteArray(value);

        for (int i = 0; i < encoded.length; i++) {
            if (encoded[i] != 0) {
                return Arrays.copyOfRange(encoded, i, encoded.length);
            }
        }

        return new byte[]{ };
    }

  	// 根据数值计算出字节流，按照大端顺序写入数组
    private static byte[] toByteArray(int value) {
        return new byte[] {
                (byte) ((value >> 24) & 0xff),
                (byte) ((value >> 16) & 0xff),
                (byte) ((value >> 8) & 0xff),
                (byte) (value & 0xff)
        };
    }

  	// 将列表迭代编码
    static byte[] encodeList(RlpList value) {
        List<RlpType> values = value.getValues();
        if (values.isEmpty()) {
            return encode(new byte[]{ }, OFFSET_SHORT_LIST); // OFFSET_SHORT_LIST = 0xc0
        } else {
            byte[] result = new byte[0];
            for (RlpType entry:values) {
                result = concat(result, encode(entry));
            }
            return encode(result, OFFSET_SHORT_LIST); // OFFSET_SHORT_LIST = 0xc0
        }
    }

  	// 链接数组
    private static byte[] concat(byte[] b1, byte[] b2) {
        byte[] result = Arrays.copyOf(b1, b1.length + b2.length);
        System.arraycopy(b2, 0, result, b1.length, b2.length);
        return result;
    }
}
```



<script type="text/javascript" src="https://cdn.mathjax.org/mathjax/latest/MathJax.js?config=default"></script>
