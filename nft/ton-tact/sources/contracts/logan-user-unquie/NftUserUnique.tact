import "@stdlib/deploy";
contract NftUserUnique {
    collection_address: Address;
    wallet_address: Address;
    is_initialized: Bool;
    init(collection_address: Address, wallet: Address){
        self.collection_address = collection_address;
        self.wallet_address = wallet;
        self.is_initialized = false;
    }
    receive(msg: MintCollectionMessage){
       if(!self.is_initialized){//没被调用过才调用mint方法
         send(SendParameters{
                   to: self.collection_address,
                   value: 0,
                   bounce: true,
                   mode: SendRemainingValue,
                   body: msg.toCell()
          });
           self.is_initialized = true;
       }
    }
}
