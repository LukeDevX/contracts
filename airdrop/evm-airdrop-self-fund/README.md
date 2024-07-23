# evm-airdrop-self-fund

直接 transfer gas：35360 * 2gwei = 0.25 刀  
添加白名单地址 gas：133929 * 2gwei = 1刀     

若把所有信息存在合约里，gas花费爆炸：

优化思路，通过  **索引数据**不在合约里放着，通过**Event** **事件**的方式抛出来，在外部使用一些索引器来去查询相关信息。

https://www.bilibili.com/video/BV112421K7a7?t=741.9

# 相关密钥和地址

airdrop 部署密钥：alley process ritual large balance ski fiber output bulb error damp job  
部署者公钥1：0x75405bB817e5196dD7FE58F292C18e2c70966912  
参与者公钥2：0x1a9662Ddc1bc4EdFF9b680642995aeac70FA383C  

eth测试网：https://rpc2.sepolia.org   
bsc测试网：https://bsc-testnet.public.blastapi.io  

#### ETH

token 地址：0x63a4adbD878d59F2B4ab56202AfF360Ecb4A4263  
airdrop 地址：0x561AC3ea6A669D82e86b94629FFBb77af44a07df  

方法列表：[token-abi](https://chaintool.tech/abi/Sepolia/0x63a4adbD878d59F2B4ab56202AfF360Ecb4A4263?id=31kWxDZEZmOv) 、  [airdrop-abi](https://chaintool.tech/abi/Sepolia/0xED3d6b0747eBA7e60512ABF4D4Ad74CC3a397490?id=VPyz0rWEmRKq)  

#### bsc

token 地址：0xe7A2AcD2c07Eec30E8872151CaC6048644c7E1aA  
airdrop 地址：0x0599485a8894162B5C3454E3cF61Afa6E1E42434  

方法列表：与 ETH 相同

# 合约方法

# 使用流程
① 部署者 先调用 token 合约，往 airdrop 合约中（转入或铸造）一定量的token。  
② 部署者 再调用 airdrop 合约中的setoken 设置要发送的token地址（已完成） 
③ 部署者 调用  setUserMap设置白名单
④ 参与者 调用claimToken 领取对应token