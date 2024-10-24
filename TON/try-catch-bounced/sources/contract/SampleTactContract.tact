import "@stdlib/deploy";

message Add {
    amount: Int as uint32;
}

contract SampleTactContract with Deployable {

    owner: Address;
    counter: Int as uint32;

    init(owner: Address) {
        self.owner = owner;
        self.counter = 0;
    }


    receive("trycatch") {

        try { 
            // 对合约发送空消息，判断用户子合约是否已经存在。不存在则抛出错误，增加用户。存在则返回gas
            // 1. 模拟链上错误,无法捕捉
            // send(SendParameters{ 
            //     to: contractAddress(initOf UserChild(myAddress(), sender())),
            //     body: beginCell().endCell(),
            //     value: 0, 
            //     mode: SendRemainingValue + SendIgnoreErrors 
            // });

            // 2. 程序执行错误
            let a = 10/0;
        } catch (err)  {
             // 没有则继续mint
             self.counter +=1;
        }
    }


    receive("bouncederror"){

        // 对合约发送空消息，判断用户子合约是否已经存在。不存在则抛出错误，增加用户。存在则返回gas
        // 第一次模拟链上错误
        send(SendParameters{ // this will forward excess gas
            to: contractAddress(initOf UserChild(myAddress(), sender())),
            body: beginCell().endCell(),
            value: 0, 
            mode: SendRemainingValue + SendIgnoreErrors 
        });

    }

// 接收所有回退消息
    bounced(rawMsg: Slice){
        self.counter +=10;
    }

    get fun counter(): Int {
        return self.counter;
    }
}


contract UserChild {
    parent: Address;
    userAddress: Address;
 
    init(parent: Address, userAddress: Address) {
        self.parent = parent;
        self.userAddress = userAddress;
    }

     get fun getAddress(): Address {
        return self.userAddress;
    }

}