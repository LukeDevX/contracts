//const fee:Int=ton("0.01");
//struct NftCollection{
//    address:Address;
//    nftItemMeta:Cell;
//}
//
//contract ServiceNftMinter {
//    owner: Address;
//    nftRootCode: Cell;
//    index: Int as int8 = 0;
//    minterIndex:Int as int8 ;
//    record: map<Int, NftCollection>;
//    init(owner: Address, nftRootCode: Cell,index:Int) {
//        self.owner = owner;
//        self.nftRootCode = nftRootCode;
//        self.minterIndex=index;
//    }
//    /*
//     * 创建 nftCollection
//     * 0:渠道商nft集合
//     * 1:创作者nft集合
//     * 2:玩家nft集合
//     */
//    receive(msg: CreateNftCollection) {
//        let ctx: Context = context();
//        require(ctx.sender == self.owner, "Invalid sender");
//        let init: StateInit = StateInit {
//            data: msg.initData,
//            code: self.nftRootCode
//        };
//        self.record.set(self.index, NftCollection{
//            address:contractAddress(init),
//            nftItemMeta:msg.nftItemMeta
//        });
//        self.index = self.index + 1;
//        send(SendParameters{
//            to: contractAddress(init),
//            value: 0,
//            mode: 64,
//            bounce: false,
//            body: beginCell().endCell(),
//            code: init.code,
//            data: init.data
//        });
//    }
//   /*
//    * 修改 nftCollection 的meta数据
//    */
//    receive(msg: UpdateNftCollection) {
//        let ctx: Context = context();
//        require(ctx.sender == self.owner, "Invalid sender");
//        let result:NftCollection=self.record.get(msg.index)!!;
//        self.record.set(self.index, NftCollection{
//            address:result.address,
//            nftItemMeta:msg.nftItemMeta
//        });
//    }
//    /*
//     * Mini身份的nft(index nftCollection的约定好的序号)
//     *
//     */
//    receive(msg: MintIdentity) {
//        require(context().value >= ton("0.15"), "not enough money");
//        let remainValue:Int=context().value-fee;
//        let result:NftCollection=self.record.get(msg.collectionIndex)!!;
//        send(SendParameters{
//            to: result.address,
//            value: 0,
//            bounce: true,
//            mode: SendRemainingValue,
//            body: MintCollectionMessage{
//                queryId:1,
//                itemIndex:msg.itemIndex,
//                mintAmount:remainValue,
//                nftItemMeta:result.nftItemMeta
//            }.toCell()
//        });
//    }
//    /*
//    * Mini作品的Nft
//    *
//    */
//    receive(msg: MintWorks) {
//        require(context().value >= ton("0.15"), "not enough money");
//        let remainValue:Int=context().value-fee;
//        let result:NftCollection=self.record.get(msg.collectionIndex)!!;
//        send(SendParameters{
//            to: result.address,
//            value: 0,
//            bounce: true,
//            mode: SendRemainingValue,
//            body: MintCollectionMessage{
//            queryId:1,
//            itemIndex:msg.itemIndex,
//            mintAmount:remainValue,
//            nftItemMeta:msg.itemMeta
//        }.toCell()
//        });
//    }
//
//    /*
//     * 获取当前管理的nftCollection的总量
//     */
//    get fun get_index(): Int {
//        return self.index;
//    }
//    /*
//      * 获取某个nftCollection的合约地址
//      */
//    get fun get_address_by_index(index: Int): Address {
//        return self.record.get(index)!!.address;
//    }
//
//
//
//
//
//
//
//
//
//
//    /*
//   *  接受直接充值
//   */
//    receive() {
//
//    }
//    /*
//     *  提现NftMinter的到拥有者
//     */
//    receive("withMinter") {
//        let ctx: Context = context();
//        require(ctx.sender == self.owner, "Invalid sender");
//        send(SendParameters{
//        to: self.owner,
//        mode:SendRemainingBalance,
//        value:myBalance(),
//        body:beginString()
//        .concat("withMinter")
//        .toString().asComment()
//        });
//    }
//    /*
//     *  提现Collection的到拥有者
//     */
//    receive(msg:WithCollection) {
//        let ctx: Context = context();
//        require(ctx.sender == self.owner, "Invalid sender");
//        send(SendParameters{
//        to: self.record.get(msg.index)!!.address,
//        value: 0,
//        mode: 64,
//        bounce: false,
//        body:MintCollectionwithdrawalMessage{
//        address:ctx.sender
//        }.toCell()});
//    }
//    /*
//     * 更改合约的当前拥有者
//     */
//    receive(msg: MinterOwnerUpdate) {
//        let ctx: Context = context();
//        require(ctx.sender == self.owner, "Invalid sender");
//        self.owner=msg.address;
//    }
//    /*
//    * 更改指定nftCollection的拥有者
//    */
//    receive(msg: CollectionOwnerUpdate) {
//        let ctx: Context = context();
//        require(ctx.sender == self.owner, "Invalid sender");
//        send(SendParameters{
//        to: self.record.get(msg.index)!!.address,
//        value: 0,
//        mode: 64,
//        bounce: false,
//        body:MintCollectionOwnerUpdateMessage{
//        address:msg.address
//        }.toCell()
//        });
//    }
//
//    get fun getNftItemInit(item_index: Int): StateInit {
//        return initOf NfT(myAddress(), item_index);
//    }
//}
//
