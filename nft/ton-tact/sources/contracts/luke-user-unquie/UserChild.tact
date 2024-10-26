contract UserChild {

    parent: Address;
    userAddress: Address;
 
    init(parent: Address, userAddress: Address) {
        self.parent = parent;
        self.userAddress = userAddress;
    }
    
    receive(){}

    receive(msg: OnlyUser){
    }

    receive("transferAll"){  
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