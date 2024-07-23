import "./jetton";
import "./messagesAirdropMint";

// myAddress（）：返回当前合约的地址

contract Airdrop 
{
    owner: Address; // 当前所有者地址
    jettonAddress: Address; // jettion 代币合约地址
    rewardArray: RewardArray;

    // owner 
    init(owner: Address){
        let zero : Int = 0;
        self.owner = owner;
        self.jettonAddress = newAddress(0,zero); // 初始化为空 // “0QAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACkT”
        self.rewardArray = emptyArray();
    }


    receive(msg: JettonAddress){
        let ctx: Context = context();
        require(ctx.sender == self.owner, "Not owner"); // 判断合约所有者才能调用这个消息
        self.jettonAddress = msg.jetton_address;
        send(SendParameters{
                to: ctx.sender, // 发消息的地址
                value: 0,
                mode: SendRemainingValue, // 返回剩余gas
                bounce: false // messages 没有成功执行，是否退回给发送者。发送者接收到后，可以执行恢复状态等操作
            });

    }

    // 个人奖励领取
    receive(msg: RewardAddress){
        let ctx: Context = context();
        // 获取地址
        let receiver: Address = ctx.sender; // 获取发送者地址
        let rewardAmount: Int = self.rewardArray.getAddressAmount(receiver); // 获取地址对应数量
        let mark: Bool = self.rewardArray.getAddressBool(receiver);
        require(mark == true, "Not true"); // 判断是否已经领取
        self.rewardArray.updataAddress(receiver, false, rewardAmount); // 领取状态改为false

        // 直接发送给发送者奖励
        send(SendParameters{
                        to: self.jettonAddress,
                        value: 0,
                        mode: SendRemainingValue, //发送剩余值
                        bounce: false,
                        body: TokenTransfer{ // 0x178d4519 // 发送转账成功消息
                            query_id: msg.query_id,
                            amount: rewardAmount,   // 需要转账的金额——查询金额
                            sender: receiver,   // 目标的地址
                            response_destination: ctx.sender,// 转账成功后的回调wallet地址
                            custom_payload: msg.custom_payload, // beginCell().endCell()
                            forward_ton_amount: msg.forward_ton_amount,
                            forward_payload: msg.forward_payload // 转账附加信息 // beginCell().endCell().asSlice()
                        }.toCell()
                    });
    }

    // 将钱包中的jettion代币转出给拥有者
    receive(msg: TransferToOwner){
        let ctx: Context = context();
        require(ctx.sender == self.owner, "Not owner"); // 判断合约所有者才能调用这个消息
        // 直接发送给发送者奖励
        send(SendParameters{
                to: self.jettonAddress,
                value: 0,
                mode: SendRemainingValue, //发送剩余值
                bounce: false,
                body: TokenTransfer{ // 0x178d4519 // 发送转账成功消息
                    query_id: msg.query_id,
                    amount: msg.amount,   // 需要转账的金额——查询金额
                    sender: ctx.sender,   // 目标的地址——发送者地址
                    response_destination: ctx.sender,// 转账成功后的回调wallet地址
                    custom_payload: beginCell().endCell(),
                    forward_ton_amount: 0,
                    forward_payload: beginCell().endCell().asSlice()
                }.toCell()
            });
    }
    // 更新所有奖励地址
    receive(msg: Replace){
        let ctx: Context = context();
        require(ctx.sender == self.owner, "Not owner"); // 判断合约所有者才能调用这个消息
        self.rewardArray.replaceAddress(msg.ddressBoolMap,msg.addressIntMap,msg.length); // 更新所有地址
        // require(self.rewardArray.getAddressBool(receiver) == true, "Not true");
        send(SendParameters{
                to: ctx.sender, // 发消息的地址
                value: 0,
                mode: SendRemainingValue, // 返回剩余gas
                bounce: false // messages 没有成功执行，是否退回给发送者。发送者接收到后，可以执行恢复状态等操作
            });
    }

    // 增加一个地址
    receive(msg: Append){
        let ctx: Context = context();
        require(ctx.sender == self.owner, "Not owner"); // 判断合约所有者才能调用这个消息
        self.rewardArray.append(msg.receiver, msg.mark, msg.amount); // 更新所有地址
        // let temp: Bool = self.rewardArray.append(msg.receiver, msg.mark, msg.amount); // 更新所有地址
        send(SendParameters{
                to: ctx.sender, // 发消息的地址
                value: 0,
                mode: SendRemainingValue, // 返回剩余gas
                bounce: false // messages 没有成功执行，是否退回给发送者。发送者接收到后，可以执行恢复状态等操作
            });
    }

    // 更新某个地址的信息
    receive(msg: UpdateAddressInfo){
        let ctx: Context = context();
        require(ctx.sender == self.owner, "Not owner"); // 判断合约所有者才能调用这个消息
        self.rewardArray.updataAddress(msg.receiver, msg.mark, msg.amount); // 更新所有地址
        // let temp: Bool = self.rewardArray.updataAddress(msg.receiver, msg.mark, msg.amount); // 更新所有地址
        send(SendParameters{
                to: ctx.sender, // 发消息的地址
                value: 0,
                mode: SendRemainingValue, // 返回剩余gas
                bounce: false // messages 没有成功执行，是否退回给发送者。发送者接收到后，可以执行恢复状态等操作
            });
    }

    // 删除所有奖励地址
    receive("deleteAllRewardMint"){
        let ctx: Context = context();
        require(ctx.sender == self.owner, "Not owner"); // 判断合约所有者才能调用这个消息
        self.rewardArray.deleteAll();
        send(SendParameters{
                to: ctx.sender, // 发消息的地址
                value: 0,
                mode: SendRemainingValue, // 返回剩余gas
                bounce: false // messages 没有成功执行，是否退回给发送者。发送者接收到后，可以执行恢复状态等操作
            });
    }


    get fun get_AirdropJetton_info(): Address{
        return self.jettonAddress;
    }


        // 获取奖励地址所有的奖励信息
    get fun get_RewardArrayAll_info(): RewardArray {
        return
            RewardArray{
                addressBoolMap: self.rewardArray.addressBoolMap,
                addressIntMap: self.rewardArray.addressIntMap,
                length: self.rewardArray.length
            };
    }

    // 获取空投最大奖励地址个数
    get fun get_MaxArraySize(): Int {
        return MaxArraySize;
    }

    //"0QCHbKE2GVK3HdItkAhp3lHhT0mTGRhfGojDrVhLO31p_0VJ"
    // 查询某个地址的奖励状态
    get fun get_RewardArray_info(receiver: Address): Append {
        // let receiver: Address = address("0QDiUISMHHfjHjqFgGAhT9d9OpPO5puVewBSXKCwzpG3l57p");
        // EQDiUISMHHfjHjqFgGAhT9d9OpPO5puVewBSXKCwzpG3l3im
        return
            Append{
                receiver: receiver,
                mark: self.rewardArray.addressBoolMap.get(receiver)!!, // 是否可以领取
                amount: self.rewardArray.addressIntMap.get(receiver)!!
            };
    }

    // get获取地址方法 
    // boc ——  https://test-explorer.toncoin.org/
    // address —— https://testnet.ton.cx/

    // 获取map地址列表
  

    // 获取当前奖励数组长度
    get fun get_RewardArrayLenght(): Int {
        return self.rewardArray.length;
    }

}