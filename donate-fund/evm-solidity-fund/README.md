# donate-fund-evm

1. 开启关闭捐款开关  
2. 设置  
3. eth捐款 FundMe.sol  
4. erc20-token 捐款  
5. 提出捐款到某一地址  

6. mapping实现： 154350 gas * 2 = 1刀
   event实现： 25679 gas * 2 = 0.17刀


# 相关密钥和地址

ido 部署密钥：alley process ritual large balance ski fiber output bulb error damp job  
部署者公钥1：0x75405bB817e5196dD7FE58F292C18e2c70966912  
参与者公钥2：0x1a9662Ddc1bc4EdFF9b680642995aeac70FA383C  

eth测试网：https://rpc2.sepolia.org   
bsc测试网：https://bsc-testnet.public.blastapi.io  

##### ETH

USDT 地址：0x50946e308aA06359455cfC348371761ECc2838C1   
ido 地址：0x52058078f42BF821F8C5a5A8c9E1d04a6368755f     

方法列表：[USDT-abi](https://chaintool.tech/abi/Sepolia/0x50946e308aA06359455cfC348371761ECc2838C1?id=nyQYEdRxlDBX) 、  [ido-abi](https://chaintool.tech/abi/Sepolia/0x52058078f42BF821F8C5a5A8c9E1d04a6368755f?id=kRlaEmox1J4y)  

##### BSC

USDT 地址：0x63a4adbD878d59F2B4ab56202AfF360Ecb4A4263  
ido 地址：0xED3d6b0747eBA7e60512ABF4D4Ad74CC3a397490    

方法列表：与eth相同

# 合约方法

IdoLog(address indexed from, uint256 _amount);  记录发送者和发送数量    

Keccak-256("IdoLog(address,uint256)") : 4c0814b34a0310e80de0a0606723eaabf27252570e2cbaf9898f8abc7b29a5ce

## ido 合约
**ido部署者调用**   
sendUSDT(address _to, uint256 _amount) ：提取usdt到钱包；  
idoOpen(), idoClose(), 打开/关闭ido;  
getUSDTBalance() return uint256：返回当前合约余额；  
**参与者调用**  
 ido(uint256 _amount) ：往ido合约里转账；   



# 使用流程
① 参与者 先调用 usdt代币 approve(address spender, uint256 value);ido合约地址授权30U数量；  
② 参与者 再调用 ido(uint256 _amount) 往ido合约里转账  
③ ido合约部署者调用 sendUSDT(address _to, uint256 _amount)，将usdt提出   