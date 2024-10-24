# Tact template project


1. UserParent 合约为控制合约，控制多个user合约，类似树。实现无上限存储  
2. 通过UserParent合约地址与用户地址，计算user合约地址 contractAddress(initOf UserChild(myAddress(), sender()))
3. 因为sender() 只能获取到当前发送者对象，所以需要userMap来存储用户和子合约的关系
4. 达到一定数量清空userMap,以防止随着存储数量增加而 产生高额gas并且