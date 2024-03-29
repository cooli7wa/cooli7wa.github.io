---
layout: post
title: Fabric_tutorials_add_org
description:
categories: study
author:
  name: cooli7wa
  link: https://cooli7wa67@163.com
---
这篇学习下如何在 fabric 内添加一个组织和对应的节点，官方文档在 [这里](https://hyperledger-fabric.readthedocs.io/en/release-1.3/channel_update_tutorial.html)，总结下整个流程和注意事项。

### 自动操作

与之前一样，官方提供了自动操作的脚本

```
./eyfn.sh up
```

### 手动操作

1. 创建 org3 的证书和 json 配置文件

   ```
   # 创建证书
   cd org3-artifacts
   ../../bin/cryptogen generate --config=./org3-crypto.yaml
   # 生成配置文件，org3.json
   export FABRIC_CFG_PATH=$PWD && ../../bin/configtxgen -printOrg Org3MSP > ../channel-artifacts/org3.json
   # 将网络的 order 证书复制到 org3 目录，方便后续的 org3 节点操作
   cd ../ && cp -r crypto-config/ordererOrganizations org3-artifacts/crypto-config/
   ```

2. 进入 cli 获取生成新的 channel config

   ```
   # 进入 cli 并准备下环境变量
   docker exec -it cli bash
   export ORDERER_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem  && export CHANNEL_NAME=mychannel

   # 获取当前的 channel config
   peer channel fetch config config_block.pb -o orderer.example.com:7050 -c $CHANNEL_NAME --tls --cafile $ORDERER_CA

   # 从 pb 转换为 json 格式
   configtxlator proto_decode --input config_block.pb --type common.Block | jq .data.data[0].payload.data.config > config.json

   # 将 org3 的配置加到 json 内，这里使用到了之前制作的 org3 的配置文件 org3.json
   jq -s '.[0] * {"channel_group":{"groups":{"Application":{"groups": {"Org3MSP":.[1]}}}}}' config.json ./channel-artifacts/org3.json > modified_config.json

   # 将原始的 json 转换为 pb 
   configtxlator proto_encode --input config.json --type common.Config --output config.pb

   # 将加入 org3 之后的 json 转换为 pb
   configtxlator proto_encode --input modified_config.json --type common.Config --output modified_config.pb

   # 对比 pb，计算出 update 部分
   configtxlator compute_update --channel_id $CHANNEL_NAME --original config.pb --updated modified_config.pb --output org3_update.pb

   # 将 update.pb 转换为 json
   configtxlator proto_decode --input org3_update.pb --type common.ConfigUpdate | jq . > org3_update.json

   # 包装下 json
   echo '{"payload":{"header":{"channel_header":{"channel_id":"mychannel", "type":2}},"data":{"config_update":'$(cat org3_update.json)'}}}' | jq . > org3_update_in_envelope.json

   # 将包装后的 json 转换为 pb
   configtxlator proto_encode --input org3_update_in_envelope.json --type common.Envelope --output org3_update_in_envelope.pb
   ```

   这里的 pb 和 json 的转换流程很繁琐，我觉得是因为 configtxlator 这个工具有些限制，不过只需要知道一点就好，这步是为了得到一个只包含升级部分的 pb 文件

3. 签名和提交 config 的 update

   这里需要 org1 和 org2 的签名

   ```
   # peer0/org1 签名
   peer channel signconfigtx -f org3_update_in_envelope.pb

   # peer0/org2 签名和提交 update
   export CORE_PEER_LOCALMSPID="Org2MSP"
   export CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt
   export CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp
   export CORE_PEER_ADDRESS=peer0.org2.example.com:7051

   peer channel update -f org3_update_in_envelope.pb -c $CHANNEL_NAME -o orderer.example.com:7050 --tls --cafile $ORDERER_CA
   ```

   到这步完事，config 就处理好了，org3 就可以正式加入到 channel 了

4. org3 加入 channel

   ```
   # 这里启动三个新的 container，两个是 org3 的 peer，一个是 org3 专属的 cli
   docker-compose -f docker-compose-org3.yaml up -d

   # 连接到 org3 的 cli container
   docker exec -it Org3cli bash

   # 配置环境变量
   export ORDERER_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem && export CHANNEL_NAME=mychannel

   # 从 order 节点获得创世块，这里为什么不使用 gossip 的方式，最后再说
   peer channel fetch 0 mychannel.block -o orderer.example.com:7050 -c $CHANNEL_NAME --tls --cafile $ORDERER_CA

   # 加入 channel
   peer channel join -b mychannel.block
   ```

5. 升级和调用合约

   ```
   # 这里还是安装之前那个合约（完全相同），只不过这次因为多了一个 org，这里版本号取为 2.0
   peer chaincode install -n mycc -v 2.0 -p github.com/chaincode/chaincode_example02/go/

   # 切换会之前的整个网络的 cli，然后在 org1 和 org2 上分别安装 version 2.0 的这个合约
   peer chaincode install -n mycc -v 2.0 -p github.com/chaincode/chaincode_example02/go/

   export CORE_PEER_LOCALMSPID="Org1MSP"
   export CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
   export CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
   export CORE_PEER_ADDRESS=peer0.org1.example.com:7051
   peer chaincode install -n mycc -v 2.0 -p github.com/chaincode/chaincode_example02/go/

   # 接下来是实例化合约，这里使用的不是 instantiate，而是 upgrade，同样需要提供背书策略，这里的策略是需要 org1-3 的背书
   peer chaincode upgrade -o orderer.example.com:7050 --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA -C $CHANNEL_NAME -n mycc -v 2.0 -c '{"Args":["init","a","90","b","210"]}' -P "OR ('Org1MSP.peer','Org2MSP.peer','Org3MSP.peer')"

   # 接下来就是在 org3 的 cli 里执行 query 和 invoke 等操作，证明 org3 已经被加入了
   peer chaincode query -C $CHANNEL_NAME -n mycc -c '{"Args":["query","a"]}'
   peer chaincode invoke -o orderer.example.com:7050  --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA -C $CHANNEL_NAME -n mycc -c '{"Args":["invoke","a","b","10"]}'
   peer chaincode query -C $CHANNEL_NAME -n mycc -c '{"Args":["query","a"]}'
   ```

### 一些注意地方

- 在新组织的新节点加入到 channel 的时候，为什么不直接使用 gossip 方法获取区块，而是要通过 order 节点？

  这个是因为新的节点加入的时候，只有创世块，这个创世块里不包含新节点对应的组织加入的信息（组织加入的信息是在后面的块里），所以新节点无法验证从其他节点发送过来的信息（我觉得这里的其他节点也是后续加入的新节点，因为创世的节点，是可以被验证的），所以无法使用 gossip ，只能从 order 节点获取区块。因此需要配置为如下两种形式之一：

  ```
  # static leader
  CORE_PEER_GOSSIP_USELEADERELECTION=false
  CORE_PEER_GOSSIP_ORGLEADER=true
  ```

  ```
  # dynamic leader
  CORE_PEER_GOSSIP_USELEADERELECTION=true
  CORE_PEER_GOSSIP_ORGLEADER=false
  ```

- 一个节点可以安装同一个合约的不同版本

  这里的同一个合约是指合约代码完全一样。

  这里的不同版本是指 version  不同，实际上就是合约的实例化的初始数据可能不同，背书原则也可以不同。<script type="text/javascript" src="https://cdn.mathjax.org/mathjax/latest/MathJax.js?config=default"></script>
