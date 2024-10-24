import "@stdlib/deploy";
import "@stdlib/ownable";

// base64:te6cckEBAQEAJAAAQ4AAv2awvXugrXaWTVHdOkFnj3RqPsdzCuHqz4eF3jm+kpALswAE
// boc:x{8000BF66B0BD7BA0AD76964D51DD3A41678F746A3EC7730AE1EACF8785DE39BE929_}
// address: EQAF-zWF690Fa7Syao7p0gs8e6NR9juYVw9WfDwu8c30lCum
// Result: 
// x{80131F3880128500CD8BF01CC87BA1D96BF6A9C4F1E3187DF5EB9089610BD40F939_}
// <=>te6cckEBAQEAJAAAQ4ATHziAEoUAzYvwHMh7odlr9qnE8eMYffXrkIlhC9QPk5BQ4HFO

// send()会将控制流发出，若目标消息内没有send操作，控制流则会返回，否则会将控制权转交给目标消息
// self.reply()会将控制流返回给调用者，


contract UserParent with Deployable, Ownable  {

    owner: Address;
    count: Int as uint256 = 0;
    userMap: map<Address, Address>;  // 存储子合约地址和用户地址
    // sender() 只能获取到当前发送者对象，所以需要userMap来存储用户和子合约的关系

    init(owner: Address) {
        self.owner = owner;
    }

    // 拥有者为部署者
    // init() {
    //     self.owner = sender(); // set the owner as the deployer
    // }
    receive("AddUser") {
        // 判断用户是否存在，不存在则会报错，通过bounced创建
        // 若存在，则发送空消息
        // let ctx: Context = context();
        let toAddress = contractAddress(initOf UserChild(myAddress(), sender()));
        self.userMap.set(toAddress, sender());
        send(SendParameters{ // this will forward excess gas
            to: toAddress,
            body:beginCell().endCell(),
            value: ton("0.02"), 
            mode: SendIgnoreErrors
        });

        // 每1000次，清空一次userMap
        if(self.count / 1000 == 0 ){
            self.userMap= emptyMap();
        }

        // 返回剩余gas
        send(SendParameters{
                to:  sender(), // 发消息的地址  let ctx: Context = context(); ctx.sender;
                value: 0,
                mode: SendRemainingValue + SendIgnoreErrors, // 返回剩余gas
                bounce: false // messages 没有成功执行，是否退回给发送者。发送者接收到后，可以执行恢复状态等操作
            });
        // self.reply(NewTodoResponse{seqno: self.numTodos}.toCell()); // this will return excess gas to sender
    }

    // bounced(msg: bounced<AddMsg>){
    bounced(rawMsg: Slice){
        self.count = self.count + 1;
        
        let firstUser = self.userMap.get(sender());

        let init: StateInit = initOf UserChild(myAddress(), firstUser!!);
        // 不能返回任何消息，一返回就报130，参数错误
    // https://testnet.tonviewer.com/transaction/9b13a6b75ee3fba2a58cf325b5c961500874853f9d3e0d474783781efed0df05
        send(SendParameters{    
            to: sender(), // sender()
            body: beginCell().endCell(),//AddMsg{a: 1}.toCell(),
            value: ton("0.018"),             // pay for the deployment and leave some TON in the child for storage 支付部署费用并在子合约中留下一些TON以供存储 不会返回给合约
            mode: SendIgnoreErrors,
            code: init.code,                // prepare the initial code when deploying the child contract
            data: init.data,
            // bounce: false 
        });
            // 返回剩余gas，控制权给子合约后实际并不会执行这里----
        send(SendParameters{
                to: firstUser!!, // 发消息的地址  let ctx: Context = context(); ctx.sender;
                value: 0,
                mode: SendRemainingValue + SendIgnoreErrors, // 返回剩余gas
                bounce: false // messages 没有成功执行，是否退回给发送者。发送者接收到后，可以执行恢复状态等操作
        });
    }

    // 转出所有余额给 合约所有者
    receive("transferAll"){  
    // self.requireOwner(); // 也可判断只有合约所有者才能调用
        let ctx: Context = context();
        require(ctx.sender == self.owner, "Not owner"); 
        send(SendParameters{
                to: ctx.sender, 
                value: 0,
                mode: SendRemainingBalance + SendIgnoreErrors, 
                bounce: false 
            });

    }


    get fun getCount(): Int {
        return self.count;
    }

}


contract UserChild {

    parent: Address;
    userAddress: Address;
 
    init(parent: Address, userAddress: Address) {
        self.parent = parent;
        self.userAddress = userAddress;
    }
    
    receive(){  // 
     }

    // 转出所有余额给 parent
    receive("transferAll"){  //
        send(SendParameters{
                to: self.parent, 
                value: 0,
                mode: SendRemainingBalance + SendIgnoreErrors, 
                bounce: false 
            });
    }

     get fun getAddress(): Address {
        return self.userAddress;
    }
}