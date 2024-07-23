# 4arts
  
deploy.ts tokens代币部署
airdrop.ts 空投代币部署

# 开始
确保具备node环境，需要安装 yarn 
```shell
npm install -g yarn 
```
加载环境
```shell
yarn install
```

编译合约
```shell
yarn build
```
运行部署 deploy.ts  
```shell
yarn deploy
```
运行部署 airdrop.ts  
```shell
yarn airdrop
```
# 测试进度
|测项|状态|
|---|----|
| 添加、修改、删除空投奖励地址| pass |  
| 个人空投奖励地址领取|pass| 
| 更新所有奖励地址，权限测试 | pass |  
| 增加奖励地址，权限测试 | pass|  
| 外部获取铸币状态信息 | pass |  

超过 2w，3w+ 地址的情况，数据过大会导致溢位

# 注意事项
1. Tact里的sender()只可以获取到上一个发送者的地址，而不会获取最早的第一个发送者的地址。
2. 发送消息时如果Mode包含SendPayGasSeparately，如果加上的话，发送消息给其他合约时，直接从当前合约的余额Ton coin中扣，如果不加上的话，从发送消息附带的余额中扣。
3. 测试FT的Jetton转帐时，如果新注册一个钱包账户，即使已经使用机器人水龙头获得一定的测试Ton coin，并且调用Jetton Master合约mint了一定Jetton币到这个钱包账户，这个钱包账户的状态依然是uninit状态，必须要主动使用这个钱包执行一次交易，可以是发送Ton coin或者发送Jetton 币到其他地址后，这样钱包的状态才会更改成Active.
4. 如果想让返回的消息更加让人理解，需要使用StringBuilder手动构造返回的字符串内容。
5. receive函数中的处理，如果不reply的话，不会返回多余的Ton给发送者。
6. https://github.com/kojhliang/tact-template/blob/main/Note.md

# 常见问题

Error: timeout of 5000ms exceeded
访问超时，添加代理配置 （clash）
```shell
yarn config set proxy http://127.0.0.1:7890 
yarn config set https-proxy http://127.0.0.1:7890
```
## 错误代码
# Error Codes
2: Stack undeflow
3: Stack overflow
4: Integer overflow
5: Integer out of expected range
6: Invalid opcode
7: Type check error
8: Cell overflow
9: Cell underflow
10: Dictionary error
13: Out of gas error
32: Method ID not found
34: Action is invalid or not supported
37: Not enough TON
38: Not enough extra-currencies
128: Null reference exception
129: Invalid serialization prefix
130: Invalid incoming message
131: Constraints error
132: Access denied
133: Contract stopped
134: Invalid argument
135: Code of a contract was not found
136: Invalid address
137: Masterchain support is not enabled for this contract
3688: Not mintable
4429: Invalid sender
5862: No items in the array to update!
6947: No items in the array!
12241: Max supply exceeded
14534: Not owner
16059: Invalid value
17848: No items in the array to delete!
18668: Can't Mint Anymore
23951: Insufficient gas
32846: Not true
42469: No space in the array left for new items!
42708: Invalid sender!
43422: Invalid value - Burn
62972: Invalid balance