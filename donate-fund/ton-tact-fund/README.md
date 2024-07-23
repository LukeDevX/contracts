# ton-tact-fund

1. 捐款开关
2. 所有人转ton到 合约中，并记录其地址和金额。捐款上限 3w
3. 转出 ton 到部署者地址
4. 查询捐款地址
5. 返回合约捐款地址

sources/scripts/ido.ts 部署 ido 奖励合约

# 相关密钥和地址

ido 部署密钥：subway art acoustic fatal present sell duck guitar oak comfort wonder hollow subject install legal argue point dry issue tiger scare meat cricket laptop  
公钥：0QBoypbqIVDUmjnmBMiQnoNRvYfYB5ybhAPRRokl2lzExZZ8  


ido参与者密钥：senior setup opera refuse uniform tomato talent glance session bullet exercise museum phrase cloth car eagle leg original reflect banana pass ignore fetch person  
公钥：0QBaxahf4D6Rv-ixnHZ2avKFdo11lCIzW3kTSMldDoU61GWC


ido 合约地址：kQAtqyu15rqQ7SWz4nxoNEmkSHBB_lsbcxB9utwCd6R9CVSa

# 开始
确保具备node环境，需要安装 yarn 
```shell
npm install -g yarn 
```
加载环境
```shell
yarn install
```

运行部署 ido.ts  
```shell
yarn ido
```
