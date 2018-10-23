---
layout: post
title: Fabric_tutorials_build_network
description:
categories: Fabric_tutorials_build_network
author: cooli7wa
---
之前看过了 fabric 整体的架构和一些关键概念，对 fabric 有了整体的了解，这篇终于可以上手了 :)，这次学习下网络的构建过程。

在构建之前，需要做一些准备，比如需要安装好 docker 环境，下载 fabric sample 和 docker 镜像，这些就不详述了，可以参考[官方文档](https://hyperledger-fabric.readthedocs.io/en/release-1.3/install.html)。

这些准备好了之后，我们就可以开始构建网络。

先进入 first-network 目录:

```
cd fabric-samples/first-network
```

这里提供了一个脚本 byfn.sh，这个脚本会执行一系列的操作，这里的所有操作在后面“手动构建网络”的时候，都会一步步用到，所以这里就是给我们一个整体的印象，执行下面的命令就可以:

```
# 生成网络相关数据，证书、genesis block、channel config、anchor peer update
# genesis block 在 ordering service 会被使用
./byfn.sh generate
# 启动网络，这里会比较久，等 END 出现就结束了
./byfn.sh up
# 关闭网络，这个比较快
./byfn.sh down
```

在看完后面的手动构建网络之后，再回头看这个流程中打印的 log，就可以发现，和手动流程是很类似的。

在做手动构建网络的时候，有一点需要留意，就是下面提供的命令，在 host 机上执行的都是在 first-network 目录下执行，在 container 上执行的都是在 /opt/gopath/src/github.com/hyperledger/fabric/peer 目录下。

### 手动构建网络

1. 生成证书相关

   ```
   # 注意这里是在 first-network 目录下执行
   ../bin/cryptogen generate --config=./crypto-config.yaml
   ```

2. 生成创世块

   ```
   export FABRIC_CFG_PATH=$PWD && ../bin/configtxgen -profile TwoOrgsOrdererGenesis -outputBlock ./channel-artifacts/genesis.block
   ```

3. 创建 channel config

   ```
   export CHANNEL_NAME=mychannel  && ../bin/configtxgen -profile TwoOrgsChannel -outputCreateChannelTx ./channel-artifacts/channel.tx -channelID $CHANNEL_NAME
   ```

4. 创建 anchor peer

   ```
   ../bin/configtxgen -profile TwoOrgsChannel -outputAnchorPeersUpdate ./channel-artifacts/Org1MSPanchors.tx -channelID $CHANNEL_NAME -asOrg Org1MSP
   ../bin/configtxgen -profile TwoOrgsChannel -outputAnchorPeersUpdate ./channel-artifacts/Org2MSPanchors.tx -channelID $CHANNEL_NAME -asOrg Org2MSP
   ```

5. 启动网络

   ```
   docker-compose -f docker-compose-cli.yaml up -d
   ```

6. 进入 cli 容器（默认是和 peer0/org1 连接）

   ```
   docker exec -it cli bash
   ```

7. 创建和加入 channel

   ```
   # 这里的 --cafile 是传入 order 节点的根证书，用来校验 order 节点
   # 这个命令会返回一个 创世 block，用来加入 channel
   export CHANNEL_NAME=mychannel
   peer channel create -o orderer.example.com:7050 -c $CHANNEL_NAME -f ./channel-artifacts/channel.tx --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
   ```

   ```
   # 将 peer0/org1 加入 channel
   peer channel join -b mychannel.block
   # 将 peer0/org2 加入 channel，因为默认是与 peer0/org1 连接，这里需要前置下环境变量
   CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp  CORE_PEER_ADDRESS=peer0.org2.example.com:7051 
   CORE_PEER_LOCALMSPID="Org2MSP" 
   CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt
   peer channel join -b mychannel.block
   ```

8. 更新 anchor peer

   ```
   # update peer0/org1
   peer channel update -o orderer.example.com:7050 -c $CHANNEL_NAME -f ./channel-artifacts/Org1MSPanchors.tx --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
   # update peer0/org2
   CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp CORE_PEER_ADDRESS=peer0.org2.example.com:7051 CORE_PEER_LOCALMSPID="Org2MSP" CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt peer channel update -o orderer.example.com:7050 -c $CHANNEL_NAME -f ./channel-artifacts/Org2MSPanchors.tx --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
   ```

9. 安装和实例化 chaincode

   ```
   # 安装，这条是在 peer0/org1 安装了 chaincode，-n 是名字，-v 是版本
   peer chaincode install -n mycc -v 1.0 -p github.com/chaincode/chaincode_example02/go/
   # 在 peer0/org2 也需要安装，需要前置下环境变量
   CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp CORE_PEER_ADDRESS=peer0.org2.example.com:7051 CORE_PEER_LOCALMSPID="Org2MSP" CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt peer chaincode install -n mycc -v 1.0 -p github.com/chaincode/chaincode_example02/go/
   # 实例化，-P 是代表需要 org1 和 org2 一起背书
   peer chaincode instantiate -o orderer.example.com:7050 --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem -C $CHANNEL_NAME -n mycc -v 1.0 -c '{"Args":["init","a", "100", "b","200"]}' -P "AND ('Org1MSP.peer','Org2MSP.peer')"
   ```

10. query 和 invoke

    ```
    # query，获取 a 的值，返回 100
    peer chaincode query -C $CHANNEL_NAME -n mycc -c '{"Args":["query","a"]}'
    # invoke，a 给 b 10，这里需要提供 order org1 org2 的证书
    peer chaincode invoke -o orderer.example.com:7050 --tls true --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem -C $CHANNEL_NAME -n mycc --peerAddresses peer0.org1.example.com:7051 --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt --peerAddresses peer0.org2.example.com:7051 --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt -c '{"Args":["invoke","a","b","10"]}'
    ```

    这里 a b 的值可以是负值

<script type="text/javascript" src="https://cdn.mathjax.org/mathjax/latest/MathJax.js?config=default"></script>
