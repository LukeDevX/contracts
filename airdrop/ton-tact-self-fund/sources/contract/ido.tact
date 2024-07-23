
contract Ido
{
    owner: Address; // 当前所有者地址
    addressIntMap: map<Address, Int>;  // 地址和转账数量，最大上限3w条
    isIdo: Bool;    // 是否继续ido
 
    init(owner: Address){
        self.owner = owner;
        self.addressIntMap = emptyMap();
        self.isIdo = true;
    }


    // 个人ido
    receive("Ido"){
        let ctx: Context = context();
         require(self.isIdo, "Not IDO"); // 判断是否可ido
        // 获取地址
        let receiver: Address = ctx.sender; // 获取发送者地址
        let amount: Int = ctx.value; // 获取转账金额

        if(self.addressIntMap.get(receiver) == null){
            self.addressIntMap.set(receiver, amount);
        }else{
            amount += self.addressIntMap.get(receiver)!!;
            self.addressIntMap.set(receiver, amount);
        }
    }


   // 将钱包中的ton余额给拥有者
    receive("TransferAll"){
        let ctx: Context = context();
        require(ctx.sender == self.owner, "Not owner"); // 判断合约所有者才能调用这个消息
        send(SendParameters{
                to: ctx.sender, // 发消息的地址
                value: 0,
                mode: SendRemainingBalance, // 返回合约中所有余额给拥有者
                bounce: false // messages 没有成功执行，是否退回给发送者。发送者接收到后，可以执行恢复状态等操作
            });
    }
    

    // 关闭ido
    receive("Owner: IdoClose"){
        let ctx: Context = context();
        require(ctx.sender == self.owner, "Not owner"); // 判断合约所有者才能调用这个消息
        self.isIdo = false;
         send(SendParameters{
                to: ctx.sender, // 发消息的地址
                value: 0,
                mode: SendRemainingValue, // 返回剩余gas
                bounce: false // messages 没有成功执行，是否退回给发送者。发送者接收到后，可以执行恢复状态等操作
            });
    }

    // 开启ido
    receive("Owner: IdoOpen"){
        let ctx: Context = context();
        require(ctx.sender == self.owner, "Not owner"); // 判断合约所有者才能调用这个消息
        self.isIdo = true;
         send(SendParameters{
                to: ctx.sender, // 发消息的地址
                value: 0,
                mode: SendRemainingValue, // 返回剩余gas
                bounce: false // messages 没有成功执行，是否退回给发送者。发送者接收到后，可以执行恢复状态等操作
            });
    }

    get fun get_idoEveryone_info(): map<Address, Int>{
        return self.addressIntMap;
    }

    // 查询某个地址转入金额 
     get fun get_person_info(receiver: Address): Int {
        return self.addressIntMap.get(receiver)!!;
    }

}