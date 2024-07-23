import "./jetton";

struct EntData {
    total_supply: Int as coins;
    mintable: Bool; // 是否可以铸币  true -1 false 0
    max_supply: Int as coins;
}

message Mint {
    amount: Int; // 数量
    receiver: Address; // 接收者地址
}

contract SampleJetton with Jetton {
    total_supply: Int as coins;
    owner: Address;
    content: Cell;
    mintable: Bool;
    // 额外设置的最大供应量
    max_supply: Int as coins; // Extract parameter we set here. The Jetton Standards doesn't have this parameter.
    init(owner: Address, content: Cell, max_supply: Int){
        self.total_supply = 0;
        self.owner = owner;
        self.mintable = true;
        self.content = content;
        self.max_supply = max_supply;
    }

    // 合约所有者铸币
    receive(msg: Mint){
        // 0xfc708bd2
        let ctx: Context = context();
        require(ctx.sender == self.owner, "Not owner"); // 判断合约所有者才能调用这个消息
        require(self.mintable, "Not mintable"); // 判断是否可铸币
        require((self.total_supply + msg.amount) <= self.max_supply, "Max supply exceeded"); // 总供应量+当前供应量 是否 超过最大供应量
        self.mint(msg.receiver, msg.amount, self.owner); // (to, amount, response_destination) // 调用方法进行铸币
    }


    //所有人发消息，都可以铸100币
    // receive("Mint: 100") { // Public Minting
    //     let ctx: Context = context();
    //     require(self.mintable, "Not mintable");
    //     require(self.total_supply + 100 <= self.max_supply, "Max supply exceeded");
    //     self.mint(ctx.sender, 100, self.owner); // 🔴
    // }

     
   
    // 发送合约中剩余  TON 所有余额（或部分余额）
    // https://docs.tact-lang.org/book/message-mode




    // 关闭铸币后，任何人都无法铸币
    receive("Owner: MintClose"){
        let ctx: Context = context();
        require(ctx.sender == self.owner, "Not owner"); // 判断合约所有者才能调用这个消息
        self.mintable = false;
         send(SendParameters{
                to: ctx.sender, // 发消息的地址
                value: 0,
                mode: SendRemainingValue, // 返回剩余gas
                bounce: false // messages 没有成功执行，是否退回给发送者。发送者接收到后，可以执行恢复状态等操作
            });
        
    }

    // 获取当前 jetton 数据
    get fun get_jetton_info(): EntData {
        return
            EntData{
                total_supply: self.total_supply,
                mintable: self.mintable, // 铸币开关
                max_supply: self.max_supply
            };
    }



    
}

// 0QDiUISMHHfjHjqFgGAhT9d9OpPO5puVewBSXKCwzpG3l57p
// base64 te6cckEBAQEAJAAAQ4AcShCRg478Y8dQsAwEKfrvp1J53NNyr2AKS5QWGdI28vDDuwGQ
// boc x{801C4A1091838EFC63C750B00C0429FAEFA75279DCD372AF600A4B941619D236F2F_}
// address EQDiUISMHHfjHjqFgGAhT9d9OpPO5puVewBSXKCwzpG3l3im


// int -1
// coins -0.000000001
// hex -1
// base64 /w==