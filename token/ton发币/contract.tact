import "./jetton";

struct EntData {
    total_supply: Int as coins;
    mintable: Bool; 
    max_supply: Int as coins;
}

message Mint {
    amount: Int;
    receiver: Address; 
}

contract SampleJetton with Jetton {
    total_supply: Int as coins;
    owner: Address;
    content: Cell;
    mintable: Bool;
    max_supply: Int as coins; // Extract parameter we set here. The Jetton Standards doesn't have this parameter.
    init(owner: Address, content: Cell, max_supply: Int){
        self.total_supply = 0;
        self.owner = owner;
        self.mintable = true;
        self.content = content;
        self.max_supply = max_supply;
    }

    receive(msg: Mint){
        // 0xfc708bd2
        let ctx: Context = context();
        require(ctx.sender == self.owner, "Not owner"); 
        require(self.mintable, "Not mintable"); 
        require((self.total_supply + msg.amount) <= self.max_supply, "Max supply exceeded");
        self.mint(msg.receiver, msg.amount, self.owner); // (to, amount, response_destination) 
    }



    receive("Owner: MintClose"){
        let ctx: Context = context();
        require(ctx.sender == self.owner, "Not owner"); 
        self.mintable = false;
         send(SendParameters{
                to: ctx.sender, 
                value: 0,
                mode: SendRemainingValue, 
                bounce: false // messages 
            });
        
    }

    get fun get_jetton_info(): EntData {
        return
            EntData{
                total_supply: self.total_supply,
                mintable: self.mintable, 
                max_supply: self.max_supply
            };
    }

    
}
