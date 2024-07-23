
struct RewardArray {
    // 领取奖励的地址和数量
    addressBoolMap: map<Address, Bool>; // 地址，是否已经领取 true -1 false 0
    addressIntMap: map<Address, Int>; // 地址，领取数量
    length: Int = 0; 
}
const MaxArraySize: Int = 10000; // 最大存储1w个地址，


// 设置奖励发送jetton地址
message JettonAddress{
    jetton_address: Address;

}
// 发送剩余jetton
message TransferToOwner{
    query_id: Int as uint64;
    amount: Int as coins; // 数量
}

// 个人奖励领取
message RewardAddress { 
    query_id: Int as uint64;
    custom_payload: Cell?;
    forward_ton_amount: Int as coins;
    forward_payload: Slice as remaining;
}
// 增加一个地址的奖励
message Append {
    receiver: Address; // 领取奖励的地址和数量
    mark: Bool; // 是否已经领取
    amount: Int; // 数量
}
// 更新某个地址信息
message UpdateAddressInfo {
    receiver: Address; // 领取奖励的地址和数量
    mark: Bool; // 是否已经领取
    amount: Int; // 数量
}
message Replace {
    // rewardArray: RewardArray; // 领取奖励的地址和数量
    ddressBoolMap: map<Address, Bool>;
    addressIntMap: map<Address, Int>;
    length: Int;
}

// 由于智能合约状态大小的上限约为 65000  个 Cell 类型的项，
// 因此它将整个合约的映射存储限制限制为约 30000 个键值对。
// 两个map的总和不能超过3w，1个1w；


// 增加一个地址和数量
extends mutates fun append(self: RewardArray, receiver: Address, mark: Bool, amount: Int): Bool {
    require((self.length + 1) <= MaxArraySize, "No space in the array left for new items!");
    if(self.addressIntMap.get(receiver) == null){
        self.length += 1; // 长度+1
    }
    
    self.addressIntMap.set(receiver, amount);
    self.addressBoolMap.set(receiver, mark);
    
    return true;
}

// 获取地址对应数量
extends fun getAddressAmount(self: RewardArray, receiver: Address): Int {
    require(self.length > 0, "No items in the array!");
    return self.addressIntMap.get(receiver)!!;
}
// 获取地址领取状态
extends fun getAddressBool(self: RewardArray, receiver: Address): Bool {
    require(self.length > 0, "No items in the array!");
    return self.addressBoolMap.get(receiver)!!;
}

// 更新某个地址的奖励数量与领取状态
extends  mutates  fun updataAddress(self: RewardArray, receiver: Address, mark: Bool, amount: Int): Bool {
    require(self.length > 0, "No items in the array to update!");
    self.addressBoolMap.set(receiver, mark);
    self.addressIntMap.set(receiver, amount);
    return true;
}

// 更新所有地址
extends  mutates  fun replaceAddress(self: RewardArray,
    addressBoolMap: map<Address, Bool>,
    addressIntMap: map<Address, Int>,
    length: Int) {
    // require(self.length == 0, "No items in the array to update!");
    self.addressBoolMap = addressBoolMap;
    self.addressIntMap = addressIntMap;
    self.length = length;
}

// 删除固定地址，将领取状态改为false，领取值为null
extends  mutates  fun deleteAddress(self: RewardArray, receiver: Address): Bool {
    require(self.length > 0, "No items in the array to delete!");
    self.addressBoolMap.set(receiver, null);
    self.addressIntMap.set(receiver, null);
    return true;
}
// 删除所有
extends  mutates  fun deleteAll(self: RewardArray) {
    self.addressIntMap = emptyMap();
    self.addressBoolMap = emptyMap();
    self.length = 0;
}

// Global static function for creating an empty Array
fun emptyArray(): RewardArray {
    return RewardArray{addressIntMap: emptyMap(), addressBoolMap: emptyMap(), length: 0};
}
