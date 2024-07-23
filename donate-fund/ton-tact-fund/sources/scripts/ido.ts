import { Address, beginCell, contractAddress, toNano, TonClient4, internal, fromNano, WalletContractV4 } from "@ton/ton";
import { mnemonicToPrivateKey } from "ton-crypto";

import { Ido } from "../output/Ido_ido";

import * as dotenv from "dotenv";

dotenv.config();

(async () => {
    const client4 = new TonClient4({
        endpoint: "https://sandbox-v4.tonhubapi.com", // 测试网
        // endpoint: "https://mainnet-v4.tonhubapi.com",

    });
    let workchain = 0; //we are working in basechain.

    const mnemonics2 = "subway art acoustic fatal present sell duck guitar oak comfort wonder hollow subject install legal argue point dry issue tiger scare meat cricket laptop";
    let keyPair2 = await mnemonicToPrivateKey(mnemonics2.split(" ")); // 转密钥
    let secretKey2 = keyPair2.secretKey;
    let deployer_wallet2 = WalletContractV4.create({ workchain, publicKey: keyPair2.publicKey });
    console.log(deployer_wallet2.address);
    let deployer_wallet_contract2 = client4.open(deployer_wallet2);


    const mnemonics3 = "senior setup opera refuse uniform tomato talent glance session bullet exercise museum phrase cloth car eagle leg original reflect banana pass ignore fetch person";
    let keyPair3 = await mnemonicToPrivateKey(mnemonics3.split(" ")); // 转密钥
    let secretKey3 = keyPair3.secretKey;
    let deployer_wallet3 = WalletContractV4.create({ workchain, publicKey: keyPair3.publicKey });
    console.log(deployer_wallet3.address);
    let deployer_wallet_contract3 = client4.open(deployer_wallet3);

    let IdoEveryoneInit = await Ido.init(deployer_wallet_contract2.address);
    let IdoEveryoneAddress = contractAddress(workchain, IdoEveryoneInit);
    let deployAmount = toNano("0.15");

    // 发送idol金额，含gas
    let ido_gas = toNano("1");
    let packed_Ido = beginCell()  // 用户ido转账
        .storeUint(0, 32)
        .storeStringTail("Ido")
        .endCell();


    let packed_TransferAll = beginCell()   // 转出合约所有ton到部署者钱包
        .storeUint(0, 32)
        .storeStringTail("TransferAll")
        .endCell();


    let packed_IdoClose = beginCell()   // 关闭ido
        .storeUint(0, 32)
        .storeStringTail("Owner: IdoClose")
        .endCell();


    let packed_IdoOpen = beginCell()    // 开启ido
        .storeUint(0, 32)
        .storeStringTail("Owner: IdoOpen")
        .endCell();

    // 返回ido所有信息
    // get fun get_idoEveryone_info(): map<Address, Int>{
    //     return self.addressIntMap;
    // }

    // 返回某个用户ido金额信息
    //  get fun get_person_info(receiver: Address): Int {
    //     return self.addressIntMap.get(receiver)!!;
    // }


    // send a message on new address contract to deploy it 发送消息到新地址合约来部署它
    let seqno2: number = await deployer_wallet_contract2.getSeqno();
    let seqno3: number = await deployer_wallet_contract3.getSeqno();

    // 钱包2，部署合约，管理合约
    // await deployer_wallet_contract2.sendTransfer({ // 合约调用者
    //     seqno: seqno2,
    //     secretKey: secretKey2,
    //     messages: [
    //         internal({
    //             to: IdoEveryoneAddress,
    //             value: deployAmount, // gas 
    //             init: {
    //                 code: IdoEveryoneInit.code,
    //                 data: IdoEveryoneInit.data,
    //             },
    //             // body: packed_TransferAll // 转出余额给owner
    //             // body: packed_IdoClose // 关闭ido
    //             // body: packed_IdoOpen // 开启ido，默认
    //         }),
    //     ],
    // });



    // 钱包3，领取奖励
    await deployer_wallet_contract3.sendTransfer({ // 合约调用者
        seqno: seqno3,
        secretKey: secretKey3,
        messages: [
            internal({
                to: IdoEveryoneAddress,
                value: ido_gas,
                init: {
                    code: IdoEveryoneInit.code,
                    data: IdoEveryoneInit.data,
                },
                body: packed_Ido // 发送ido
            }),
        ],
    });




})();



