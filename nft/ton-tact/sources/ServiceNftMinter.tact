import "./NftCollection.tact";
import "@stdlib/deploy";
const fee:Int=ton("0.01");
struct NftCollectionRecord{

    address:Address;
    identityFilePath:Cell;
}
contract ServiceNftMinter {
    owner: Address;
    index: Int as int8 = 0;
    record: map<Int, NftCollectionRecord>;
    init(owner: Address) {
        self.owner = owner;
    }
    /*
     * 创建 nftCollection
     * 0:渠道商nft集合
     * 1:创作者nft集合
     * 2:玩家nft集合
     */
    // message createNftCollection  
    // royalty_params: RoyaltyParams;
    // collectionContent:Cell;
    // identityFilePath:Cell;

    receive(msg: CreateNftCollection) {
        let ctx: Context = context();
        require(ctx.sender == self.owner, "Invalid sender");
        let init: StateInit = self.getNftCollectionInit(msg,self.index);
        self.record.set(self.index, NftCollectionRecord{
            address:contractAddress(init),
            identityFilePath:msg.identityFilePath
        });
        self.index = self.index + 1;
        send(SendParameters{
            to: contractAddress(init),
            value: 0,
            mode: 64, 
            bounce: false,
            body: beginCell().endCell(),
            code: init.code,
            data: init.data
        });
    }
   /*
    * 修改 nftCollection 的meta数据
    */
    receive(msg: UpdateNftCollection) {
        let ctx: Context = context();
        require(ctx.sender == self.owner, "Invalid sender");
        let result:NftCollectionRecord=self.record.get(msg.index)!!;
        self.record.set(self.index, NftCollectionRecord{
            address:result.address,
            identityFilePath:msg.identityFilePath
        });
    }
    /*
     * Mini身份的nft(index nftCollection的约定好的序号)
     *
     */
    receive(msg: MintIdentity) {
        require(context().value >= ton("0.15"), "not enough money");
        let remainValue:Int=context().value-fee;
        let result:NftCollectionRecord=self.record.get(msg.collectionIndex)!!;
        send(SendParameters{
            to: result.address,
            value: 0,
            bounce: true,
            mode: SendRemainingValue,
            body: MintCollectionMessage{
                queryId:msg.queryId,
                nftOwner:sender(),
                metaDataFilePath:result.identityFilePath,
                forward_amount:0
            }.toCell()
        });
    }
    /*
    * Mini作品的Nft
    *
    */
    receive(msg: MintWorks) {
        require(context().value >= ton("0.15"), "not enough money");
        let remainValue:Int=context().value-fee;
        let result:NftCollectionRecord=self.record.get(msg.collectionIndex)!!;
        send(SendParameters{
            to: result.address,
            value: 0,
            bounce: true,
            mode: SendRemainingValue,
            body: MintCollectionMessage{
                    queryId:msg.queryId,
                    nftOwner:sender(),
                    metaDataFilePath:msg.metaDataFilePath,
                    forward_amount:0
                }.toCell()
        });
    }
    /*
     *  接受直接充值
     */
    receive() {

    }











    /*
     *  提现NftMinter的到拥有者
     */
    receive("withMinter") {
        let ctx: Context = context();
        require(sender() == self.owner, "Invalid sender");
        send(SendParameters{
        to: self.owner,
        mode:SendRemainingBalance,
        value:myBalance(),
        body:beginString()
        .concat("withMinter")
        .toString().asComment()
        });
    }
    /*
     *  提现Collection的到拥有者
     */
    receive(msg:WithCollection) {
        let ctx: Context = context();
        require(ctx.sender == self.owner, "Invalid sender");
        send(SendParameters{
        to: self.record.get(msg.index)!!.address,
        value: 0,
        mode: SendRemainingValue,
        bounce: false,
        body:MintCollectionwithdrawalMessage{
        address:ctx.sender
        }.toCell()});
    }
    /*
     * 更改合约的当前拥有者
     */
    receive(msg: MinterOwnerUpdate) {
        let ctx: Context = context();
        require(ctx.sender == self.owner, "Invalid sender");
        self.owner=msg.address;
    }
    /*
    * 更改指定nftCollection的拥有者
    */
    receive(msg: CollectionOwnerUpdate) {
        let ctx: Context = context();
        require(ctx.sender == self.owner, "Invalid sender");
        send(SendParameters{
        to: self.record.get(msg.index)!!.address,
        value: 0,
        mode: SendRemainingValue,
        bounce: false,
        body:MintCollectionOwnerUpdateMessage{
        address:msg.address
        }.toCell()
        });
    }
    /*
    * 获取当前管理的nftCollection的总量
    */
    get fun get_index(): Int {
        return self.index;
    }
    /*
      * 获取某个nftCollection的合约地址
      */
    get fun get_address_by_index(index: Int): Address {
        return self.record.get(index)!!.address;
    }
    get fun getNftCollectionInit(msg:CreateNftCollection,index:Int): StateInit {
        return initOf NftCollection(myAddress(),self.owner,msg.collectionContent,msg.royalty_params,index);
    }
}

