import "./message.tact";
import "./NftItemFinal.tact";
import "@stdlib/deploy";
import "./UserChild.tact";
const minTonsForStorage: Int = ton("0.02");
const gasConsumption: Int = ton("0.02");

message OnlyUser{
    index: Int as int256;
}

contract NftCollection {
    next_item_index: Int as uint32 = 0;
    owner_address: Address;
    response_address: Address;
    royalty_params: RoyaltyParams?;
    collection_content: Cell;
    minterIndex:Int as int8 ;
	
	
    metaDataFilePath: Cell; // 保存元数据地址
    userMap: map<Address, Address>; // 保存UserChild 和 用户地址的映射
    count: Int as uint256; // 计数控制用户数量

    init(owner_address: Address, response_address:Address,collection_content: Cell, royalty_params: RoyaltyParams,minterIndex:Int){
        self.owner_address = owner_address;
        self.collection_content = collection_content;
        self.royalty_params = royalty_params;
        self.response_address = response_address;
        self.minterIndex=minterIndex;
        self.metaDataFilePath = emptyCell();
        self.count = 0;
        self.userMap = emptyMap();
    }

    receive(miniMsg:MintCollectionMessage){
        self.metaDataFilePath = miniMsg.metaDataFilePath;
        let toAddress: Address = contractAddress(initOf UserChild(myAddress(), miniMsg.nftOwner));
        self.userMap.set(toAddress, miniMsg.nftOwner);
        send(SendParameters{ // this will forward excess gas
            to: toAddress,
            body:OnlyUser{index: 0}.toCell(),
            value: 0, 
            mode: SendRemainingValue + SendIgnoreErrors
        });        
    }

    // ===== Private Methods ===== //
    // fun mint(msgValue: Int,miniMsg:MintCollectionMessage) {
    fun mint(msgValue: Int,nftOwner: Address) {

        require(self.next_item_index >= 0, "non-sequential NFTs");
        let nft_init: StateInit = self.getNftItemInit(self.next_item_index);
        send(SendParameters{
        to: contractAddress(nft_init),
        value: msgValue,
        bounce: false,
        mode: SendIgnoreErrors,
        body: Transfer {
            query_id: 0,// miniMsg.queryId,
            new_owner: nftOwner, // 拥有过这个NFT的用户地址
            response_destination: nftOwner, // 拥有过这个NFT的用户地址
            custom_payload: self.metaDataFilePath, 
            forward_amount: 0,
            forward_payload: emptySlice()
            }.toCell(),
            code: nft_init.code,
            data: nft_init.data
        });
        // dump(self.next_item_index); // Reference at: https://tact-by-example.org/03-emit
        self.next_item_index = self.next_item_index + 1;
    }

    receive(msg: GetRoyaltyParams) {
        let ctx: Context = context(); // get sender Info
        send(SendParameters{
            to: ctx.sender,
            value: 0,
            mode: 64,
            bounce: false,
            body: ReportRoyaltyParams {
            query_id: msg.query_id,
            numerator:  (self.royalty_params!!).numerator,
            denominator: (self.royalty_params!!).denominator,
            destination: self.owner_address
            }.toCell()
        });
    }

   bounced(msg: bounced<OnlyUser>){

    //mint操作
        let firstUser: Address = self.userMap.get(sender())!!;
        let ctx: Context = context(); // get sender Info
        let msgValue: Int = ctx.value;
        let tonBalanceBeforeMsg: Int = myBalance() - msgValue;
        let storageFee: Int = minTonsForStorage - min(tonBalanceBeforeMsg, minTonsForStorage);
        msgValue = msgValue - (storageFee + gasConsumption);
        self.mint(msgValue,firstUser);
        emit(LogEventMintRecord{ minter: firstUser, item_id: self.next_item_index, generate_number: nativeRandom() }.toCell());
        
		
    // 创建用户
		self.count = self.count + 1;
        let init: StateInit = initOf UserChild(myAddress(), firstUser);
        if(self.count % 1000 == 0 ){ // 达到1000，清空map
            self.userMap= emptyMap();
        }
        send(SendParameters{    
            to: sender(), 
            body: beginCell().endCell(),
            value: ton("0.01"),             
            mode: SendIgnoreErrors,
            code: init.code,                
            data: init.data,
            bounce: false 
        });
        
    }
    // ------------------ Get Function  ------------------ //
	get fun getCount(): Int {
        return self.count;
    }
    get fun get_collection_data(): CollectionData {
        return CollectionData{
            next_item_index: self.next_item_index,
            collection_content:self.collection_content.asSlice().loadRef(),
            owner_address: self.owner_address
        };
    }

    get fun get_nft_address_by_index(item_index: Int): Address?{
        let initCode: StateInit = self.getNftItemInit(item_index);
        return contractAddress(initCode);
    }

    get fun getNftItemInit(item_index: Int): StateInit {
        return initOf NftItemFinal(myAddress(), item_index);
    }
    //Item会调用这个方法，用来寻找他metaData
    get fun get_nft_content(index: Int, individual_content: Cell): Cell {
     let cs:Slice=self.collection_content.beginParse();
        cs.loadRef();
     let common_content:Slice=cs.loadRef().beginParse();
      return beginCell()
        .storeUint(1, 8)
        .storeSlice(common_content)
        .storeRef(individual_content)
        .endCell();
    }

    get fun royalty_params(): RoyaltyParams {
        return self.royalty_params!!;
    }

    /*
     *  接受直接充值
     */
    receive() {

    }
    /*
   *  提现NftMinter的到拥有者
   */
    receive( msg:MintCollectionwithdrawalMessage) {
        let ctx: Context = context();
        require(ctx.sender == self.owner_address, "Invalid sender");
        send(SendParameters{
            to: msg.address,
            mode:SendRemainingBalance,
            value:myBalance(),
            body:beginString()
            .concat("withMinter")
            .toString().asComment()
        });
    }
    /*
    *  修改NftCollection的拥有者
    */
    receive( msg:MintCollectionOwnerUpdateMessage) {
        require(sender() == self.owner_address, "Invalid sender");
        self.owner_address=msg.address;
    }
}
