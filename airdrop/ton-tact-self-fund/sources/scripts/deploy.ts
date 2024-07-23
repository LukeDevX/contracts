import { Address, Dictionary, beginCell, contractAddress, toNano, TonClient4, WalletContractV4, internal, fromNano } from "@ton/ton";
import { mnemonicToPrivateKey } from "ton-crypto";
import { buildOnchainMetadata } from "../utils/jetton-helpers";

import { SampleJetton, storeMint } from "../output/SampleJetton_SampleJetton";

import { printSeparator } from "../utils/print";
import * as dotenv from "dotenv";
dotenv.config();


(async () => {

    // 设置测试网链接信息
    const client4 = new TonClient4({
        endpoint: "https://sandbox-v4.tonhubapi.com", // 测试网
        // endpoint: "https://mainnet-v4.tonhubapi.com",

    });

    // 钱包1 信息
    const mnemonics = "iron correct shaft party music degree term view radar goat load poet stumble awful opera trouble ill apple remain window caught control flower wheel"; // 助记词
    let keyPair = await mnemonicToPrivateKey(mnemonics.split(" ")); // 转密钥
    let secretKey = keyPair.secretKey; // 私钥
    let workchain = 0; //we are working in basechain.
    let deployer_wallet = WalletContractV4.create({ workchain, publicKey: keyPair.publicKey });
    console.log(deployer_wallet.address);
    let deployer_wallet_contract = client4.open(deployer_wallet); // 打开钱包1

    // 钱包2 信息
    const mnemonics2 = "mixed negative fox bread appear hole renew clarify move argue prepare amused gold cattle decline smoke mango purity eyebrow sauce bracket shed talk item";
    let keyPair2 = await mnemonicToPrivateKey(mnemonics2.split(" ")); // 转密钥
    let secretKey2 = keyPair2.secretKey;
    let workchain2 = 0; //we are working in basechain.
    let deployer_wallet2 = WalletContractV4.create({ workchain, publicKey: keyPair2.publicKey });
    console.log(deployer_wallet2.address);
    let deployer_wallet_contract2 = client4.open(deployer_wallet2); // 打开钱包2


    //----- 调用合约固定信息，每次设置后不要修改---
    // ENT 代币信息
    const jettonParams = {
        name: "Entertainment Coins0713",
        description: "The governance token of the 4Arts platform",
        symbol: "ENT",
        image: "https://www.4arts.cc/home/ent-token-icon.png",
    };
    let content = buildOnchainMetadata(jettonParams);
    let max_supply = toNano(60000000000); // 设置最大供应量
    // 连接编译后的合约，传入创建合约的地址和初始值
    let init = await SampleJetton.init(deployer_wallet_contract.address, content, max_supply);
    let jettonMaster = contractAddress(workchain, init);
    let deployAmount = toNano("0.15");   // 设置gas


    //--------------------------------------



    // *合约创建者调用
    // *铸币消息
    let supply = toNano(600000);         // 设置供应代币数额
    let packed_msg = beginCell()
        .store(
            storeMint({
                $$type: "Mint", // 合约创建者铸币
                amount: supply, // 铸币数额
                receiver: deployer_wallet_contract.address, // 接收者地址
            })
        )
        .endCell();



    // *添加一个空投奖励地址
    // let packed_Append = beginCell()
    //     .store(
    //         storeAppend({
    //             $$type: "Append",
    //             receiver: deployer_wallet_contract2.address, // 领取奖励的地址
    //             mark: true, // 是否可以领取
    //             amount: toNano(7778) // 数量
    //         })
    //     )
    //     .endCell();

    // // *设置要空头奖励的地址
    // let _addressBoolMap = Dictionary.empty<Address, boolean>(Dictionary.Keys.Address(), Dictionary.Values.Bool());
    // let _addressIntMap = Dictionary.empty<Address, bigint>(Dictionary.Keys.Address(), Dictionary.Values.BigUint(256));
    // let p3 = Address.parse("0QDiUISMHHfjHjqFgGAhT9d9OpPO5puVewBSXKCwzpG3l57p");
    // _addressBoolMap.set(p3, true); //地址，是否可以领取，true可以领取，false不可领取
    // _addressIntMap.set(p3, toNano(200)); // 地址，领取的数量

    // // *添加所有地址
    // let packed_Replace = beginCell()
    //     .store(
    //         storeReplace({
    //             $$type: "Replace",
    //             ddressBoolMap: _addressBoolMap,
    //             addressIntMap: _addressIntMap,
    //             length: BigInt(1)
    //         })
    //     )
    //     .endCell();

    // // *更新奖励地址信息
    // let packed_UpdateAddressInfo = beginCell()
    //     .store(
    //         storeUpdateAddressInfo({
    //             $$type: "UpdateAddressInfo",
    //             receiver: p3, // 更新领取奖励的地址
    //             mark: false, // 更新领取状态，false为不可领取
    //             amount: toNano(8) // 更新数量
    //         })
    //     )
    //     .endCell();



    // *打开铸币，任何人都无法铸币（默认开启）
    let packed_MintOpen = beginCell()
        .storeUint(0, 32)
        .storeStringTail("Owner: MintOpen")
        .endCell();

    // *关闭铸币后，任何人都无法铸币
    let packed_MintClose = beginCell()
        .storeUint(0, 32)
        .storeStringTail("Owner: MintClose")
        .endCell();



    // 任何人都可以调用
    // 个人奖励领取奖励
    let packed_RewardAddress = beginCell()
        .storeUint(0, 32)
        .storeStringTail("RewardAddress")
        .endCell();


    // send a message on new address contract to deploy it 发送消息到新地址合约来部署它
    let seqno: number = await deployer_wallet_contract.getSeqno(); // 序号
    let seqno2: number = await deployer_wallet_contract2.getSeqno();

    // 钱包发送消息
    await deployer_wallet_contract.sendTransfer({ // 合约调用者
        seqno: seqno, // 序列号
        secretKey: secretKey, // 发送者私钥
        messages: [
            internal({
                to: jettonMaster, // 调用的信息
                value: deployAmount, // gas 
                init: { // 合约参数
                    code: init.code,
                    data: init.data,
                },
                body: packed_msg, // 调用合约的消息（铸币消息）
            }),
        ],
    });


})();

