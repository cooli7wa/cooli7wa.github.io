---
layout: post
title: Fabric_tutorials_private_data
description:
categories: study
author: cooli7wa
---
这篇文章，学习操作下 private data，[教程](https://hyperledger-fabric.readthedocs.io/en/release-1.3/private_data_tutorial.html)的示例很清晰，没什么需要多说的，所以这篇会很短。

private data 用 collection 表示的，collection definition 文件描述了有权限使用、保存和传播私有数据的节点，以及私有数据应该被保存多久。

collection definition 只有 5 个参数：

- name，名字
- policy，定义了哪些节点有权限保存私有数据
- requiredPeerCount，背书节点传播私有数据到其他节点，这个参数定义的是传播的最小数量
- maxPeerCount，这个参数定义的是传播的最大数量
- blockToLive，定义了私有数据应该被保存的时间，以区块数量为单位，超期之后会被删除，如果想永久保存，那么就设为 0

collection definition 被保存为 json 文件，在合约实例化的时候，通过 --collections-config 参数传入，官网的例子如下：

```
// collections_config.json
[
  {
       "name": "collectionMarbles",
       "policy": "OR('Org1MSP.member', 'Org2MSP.member')",
       "requiredPeerCount": 0,
       "maxPeerCount": 3,
       "blockToLive":1000000
  },

  {
       "name": "collectionMarblePrivateDetails",
       "policy": "OR('Org1MSP.member')",
       "requiredPeerCount": 0,
       "maxPeerCount": 3,
       "blockToLive":3
  }
]
```

需要注意的是，在合约内，也需要配套的私有数据结构体定义：

```
// Peers in Org1 and Org2 will have this private data in a side database
type marble struct {
  ObjectType string `json:"docType"`
  Name       string `json:"name"`
  Color      string `json:"color"`
  Size       int    `json:"size"`
  Owner      string `json:"owner"`
}

// Only peers in Org1 will have this private data in a side database
type marblePrivateDetails struct {
  ObjectType string `json:"docType"`
  Name       string `json:"name"`
  Price      int    `json:"price"`
}
```

在这个例子里，org1 和 org2 可以操作名字为 collectionMarbles 的数据，org1 可以操作 collectionMarblePrivateDetails 的数据。

合约实例化的命令如下，可以看到使用了上面的 json 文件：

```
peer chaincode instantiate -o orderer.example.com:7050 --tls --cafile $ORDERER_CA -C mychannel -n marblesp -v 1.0 -c '{"Args":["init"]}' -P "OR('Org1MSP.member','Org2MSP.member')" --collections-config  $GOPATH/src/github.com/chaincode/marbles02_private/collections_config.json
```

<script type="text/javascript" src="https://cdn.mathjax.org/mathjax/latest/MathJax.js?config=default"></script>
