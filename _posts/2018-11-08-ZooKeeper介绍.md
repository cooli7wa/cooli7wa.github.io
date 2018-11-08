---
layout: post
title: ZooKeeper介绍
description:
categories: study
author: cooli7wa
---
这篇来学习下 ZooKeeper，全部内容来源于网上两篇文章（在参考内），将两篇内容融合在一起，先有个大体的了解，算是入门吧。

### 1. 基础概念

ZooKeeper 是一个开源的分布式协调服务，分布式应用程序可以基于 ZooKeeper 实现诸如数据发布/订阅、负载均衡、命名服务、分布式协调/通知、集群管理、Master 选举、分布式锁和分布式队列等功能。

ZooKeeper 的设计目标是将那些复杂且容易出错的分布式一致性服务封装起来，构成一个高效可靠的原语集，并以一系列简单易用的接口提供给用户使用。

### 2. 一些特性

- ZooKeeper 本身就是一个分布式程序，为了保证高可用，最好是以集群形态来部署，这样只要集群中大部分机器是可用的（能够容忍一定的机器故障），那么 ZooKeeper 本身仍然是可用的。
- ZooKeeper 将数据保存在内存中，这也就保证了高吞吐量和低延迟（但是内存限制了能够存储的容量不太大，此限制也是保持 ZNode 中存储的数据量较小的进一步原因）。
- ZooKeeper 是高性能的。 在“读”多于“写”的应用程序中尤其地高性能，因为“写”会导致所有的服务器间同步状态。（“读”多于“写”是协调服务的典型场景。）
- ZooKeeper 有临时节点的概念。 当创建临时节点的客户端会话一直保持活动，瞬时节点就一直存在。而当会话终结时，瞬时节点被删除。持久节点是指一旦这个 ZNode 被创建了，除非主动进行 ZNode 的移除操作，否则这个 ZNode 将一直保存在 Zookeeper 上。
- ZooKeeper 底层其实只提供了两个功能：①管理（存储、读取）用户程序提交的数据；②为用户程序提交数据节点监听服务。
- ZooKeeper 最好使用奇数台服务器构成集群，因为使用的是 ZAB 算法，而 ZAB 是多数算法，所以在保证可靠性一样的情况下，奇数可以减少一台服务器的使用。

### 3. 集群角色

ZooKeeper 中没有选择传统的 Master/Slave 概念，而是引入了Leader、Follower 和 Observer 三种角色。

![]({{site.baseurl}}/images/md/zookeeper_0.png)

ZooKeeper 集群中的所有机器通过一个 Leader 选举过程来选定一台称为 “Leader” 的机器，Leader 既可以为客户端提供写服务又能提供读服务。除了 Leader 外，Follower 和 Observer 都只能提供读服务。Follower 和 Observer 唯一的区别在于 Observer 机器不参与 Leader 的选举过程，也不参与写操作的“过半写成功”策略，因此 Observer 机器可以在不影响写性能的情况下提升集群的读性能。

![]({{site.baseurl}}/images/md/zookeeper_1.png)

### 4. Session

Session 指的是 ZooKeeper 服务器与客户端会话。在 ZooKeeper 中，一个客户端连接是指客户端和服务器之间的一个 TCP 长连接。客户端启动的时候，首先会与服务器建立一个 TCP 连接，从第一次连接建立开始，客户端会话的生命周期也开始了。通过这个连接，客户端能够通过心跳检测与服务器保持有效的会话，也能够向  Zookeeper 服务器发送请求并接受响应，同时还能够通过该连接接收来自服务器的 Watch 事件通知。 Session的sessionTimeout 值用来设置一个客户端会话的超时时间。当由于服务器压力太大、网络故障或是客户端主动断开连接等各种原因导致客户端连接断开时，只要在 sessionTimeout 规定的时间内能够重新连接上集群中任意一台服务器，那么之前创建的会话仍然有效。

在为客户端创建会话之前，服务端首先会为每个客户端都分配一个 sessionID。由于 sessionID 是 Zookeeper 会话的一个重要标识，许多与会话相关的运行机制都是基于这个 sessionID 的，因此，无论是哪台服务器为客户端分配的 sessionID，都务必保证全局唯一。

### 5. Znode

在谈到分布式的时候，一般节点指的是组成集群的每一台机器。而 ZooKeeper 中的数据节点是指数据模型中的数据单元，称为 ZNode。ZooKeeper 将所有数据存储在内存中，数据模型是一棵树（ZNode Tree），由斜杠（/）进行分割的路径，就是一个 ZNode，如 /hbase/master,其中 hbase 和 master 都是 ZNode。每个 ZNode上都会保存自己的数据内容，同时会保存一系列属性信息。

在 ZooKeeper 中，ZNode 可以分为持久节点和临时节点两类。

**持久节点**

所谓持久节点是指一旦这个 ZNode 被创建了，除非主动进行 ZNode 的移除操作，否则这个 ZNode 将一直保存在 ZooKeeper 上。

**临时节点**

临时节点的生命周期跟客户端会话绑定，一旦客户端会话失效，那么这个客户端创建的所有临时节点都会被移除。

另外，ZooKeeper 还允许用户为每个节点添加一个特殊的属性：SEQUENTIAL。一旦节点被标记上这个属性，那么在这个节点被创建的时候，ZooKeeper 就会自动在其节点后面追加上一个整型数字，这个整型数字是一个由父节点维护的自增数字。

### 6. 版本

ZooKeeper 的每个 ZNode 上都会存储数据，对应于每个 ZNode，ZooKeeper 都会为其维护一个叫作 Stat 的数据结构，Stat 中记录了这个 ZNode 的三个数据版本，分别是 version（当前ZNode的版本）、cversion（当前 ZNode子节点的版本）和 aversion（当前 ZNode 的 ACL 版本）。

### 7. 事务操作

在 ZooKeeper 中，能改变 ZooKeeper 服务器状态的操作称为事务操作。一般包括数据节点创建与删除、数据内容更新和客户端会话创建与失效等操作。对应每一个事务请求，ZooKeeper 都会为其分配一个全局唯一的事务ID，用 ZXID 表示，通常是一个64位的数字。每一个ZXID对应一次更新操作，从这些 ZXID 中可以间接地识别出 ZooKeeper 处理这些事务操作请求的全局顺序。

### 8. Watcher

Watcher（事件监听器），是 ZooKeeper 中一个很重要的特性。ZooKeeper 允许用户在指定节点上注册一些Watcher，并且在一些特定事件触发的时候，ZooKeeper 服务端会将事件通知到感兴趣的客户端上去。该机制是ZooKeeper 实现分布式协调服务的重要特性。

### 9. ACL

ZooKeeper 采用 ACL（Access Control Lists）策略来进行权限控制。ZooKeeper定义了如下5种权限。

- CREATE: 创建子节点的权限。
- READ: 获取节点数据和子节点列表的权限。
- WRITE：更新节点数据的权限。
- DELETE: 删除子节点的权限。
- ADMIN: 设置节点ACL的权限。

注意：CREATE 和 DELETE 都是针对子节点的权限控制。

### 10. 参考

https://zhuanlan.zhihu.com/p/44731983

http://blog.jobbole.com/110388/<script type="text/javascript" src="https://cdn.mathjax.org/mathjax/latest/MathJax.js?config=default"></script>
