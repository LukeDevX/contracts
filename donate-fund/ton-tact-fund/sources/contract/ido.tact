
contract Ido
{
    owner: Address; 
    addressIntMap: map<Address, Int>;  
    isIdo: Bool;   
 
    init(owner: Address){
        self.owner = owner;
        self.addressIntMap = emptyMap();
        self.isIdo = true;
    }


    receive("Ido"){
        let ctx: Context = context();
         require(self.isIdo, "Not IDO"); 
        let receiver: Address = ctx.sender;
        let amount: Int = ctx.value; 

        if(self.addressIntMap.get(receiver) == null){
            self.addressIntMap.set(receiver, amount);
        }else{
            amount += self.addressIntMap.get(receiver)!!;
            self.addressIntMap.set(receiver, amount);
        }
    }


    receive("TransferAll"){
        let ctx: Context = context();
        require(ctx.sender == self.owner, "Not owner"); 
        send(SendParameters{
                to: ctx.sender, 
                value: 0,
                mode: SendRemainingBalance, 
                bounce: false 
            });
    }
    

    // 关闭ido
    receive("Owner: IdoClose"){
        let ctx: Context = context();
        require(ctx.sender == self.owner, "Not owner");
        self.isIdo = false;
         send(SendParameters{
                to: ctx.sender, 
                value: 0,
                mode: SendRemainingValue,
                bounce: false 
            });
    }

    // 开启ido
    receive("Owner: IdoOpen"){
        let ctx: Context = context();
        require(ctx.sender == self.owner, "Not owner");
        self.isIdo = true;
         send(SendParameters{
                to: ctx.sender, 
                value: 0,
                mode: SendRemainingValue,
                bounce: false
            });
    }

	// 查询所有map集合
    get fun get_idoEveryone_info(): map<Address, Int>{
        return self.addressIntMap;
    }

	// 查询某个地址 ido 金额
     get fun get_person_info(receiver: Address): Int {
        return self.addressIntMap.get(receiver)!!;
    }
	
	// 返回当前合约金额
	get fun get_balance(): Int{
		return myBalance();
	}

}