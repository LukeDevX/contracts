import { Address, Dictionary, beginCell, contractAddress, toNano, TonClient4, WalletContractV4, internal, fromNano, address } from "@ton/ton";
import { mnemonicToPrivateKey } from "ton-crypto";
import { buildOnchainMetadata } from "../utils/jetton-helpers";

import { SampleJetton, storeMint, storeTokenBurn } from "../output/SampleJetton_SampleJetton";
import { JettonDefaultWallet } from "../output/SampleJetton_JettonDefaultWallet";
import { Airdrop, storeRewardAddress, storeJettonAddress, storeTransferToOwner, storeReplace, storeAppend, storeUpdateAddressInfo, } from "../output/Airdrop_airdrop";

import { printSeparator } from "../utils/print";
import * as dotenv from "dotenv";
dotenv.config();

(async () => {
    const client4 = new TonClient4({
        endpoint: "https://sandbox-v4.tonhubapi.com", // 测试网
        // endpoint: "https://mainnet-v4.tonhubapi.com",

    });
    const mnemonics = "iron correct shaft party music degree term view radar goat load poet stumble awful opera trouble ill apple remain window caught control flower wheel";
    let keyPair = await mnemonicToPrivateKey(mnemonics.split(" ")); // 转密钥
    let secretKey = keyPair.secretKey;
    let workchain = 0; //we are working in basechain.
    let deployer_wallet = WalletContractV4.create({ workchain, publicKey: keyPair.publicKey });
    console.log(deployer_wallet.address);
    let deployer_wallet_contract = client4.open(deployer_wallet);


    const mnemonics2 = "mixed negative fox bread appear hole renew clarify move argue prepare amused gold cattle decline smoke mango purity eyebrow sauce bracket shed talk item";
    let keyPair2 = await mnemonicToPrivateKey(mnemonics2.split(" ")); // 转密钥
    let secretKey2 = keyPair2.secretKey;
    let workchain2 = 0; //we are working in basechain.
    let deployer_wallet2 = WalletContractV4.create({ workchain, publicKey: keyPair2.publicKey });
    console.log(deployer_wallet2.address);
    let deployer_wallet_contract2 = client4.open(deployer_wallet2);


    const mnemonics3 = "guess gloom focus wood shield thing orient asset major hint soon cotton sugar tuna absorb limit cram sword private review track alarm fix dash";
    let keyPair3 = await mnemonicToPrivateKey(mnemonics3.split(" ")); // 转密钥
    let secretKey3 = keyPair3.secretKey;
    let workchain3 = 0; //we are working in basechain.
    let deployer_wallet3 = WalletContractV4.create({ workchain, publicKey: keyPair3.publicKey });
    console.log(deployer_wallet3.address);
    let deployer_wallet_contract3 = client4.open(deployer_wallet3);



    const jettonParams = {
        name: "Entertainment Coins",
        description: "The governance token of the 4Arts platform",
        symbol: "ENT",
        image: "https://www.4arts.cc/home/ent-token-icon.png",
    };
    let content = buildOnchainMetadata(jettonParams);
    let max_supply = toNano(60000000000); // 设置最大供应量 // 部署后固定不变，即使后面增大供应，初始化值也不变
    // let max_supply = toNano(100000000000); // 🔴 Set the specific total supply in nano
    let deployAmount = toNano("0.15");


    let init = await SampleJetton.init(deployer_wallet_contract.address, content, max_supply);
    let jettonMaster = contractAddress(workchain, init);


    let contract_dataFormat = SampleJetton.fromAddress(jettonMaster); // 获取master 合约信息，
    let contract = client4.open(contract_dataFormat); // 打开合约
    let jetton_wallet = await contract.getGetWalletAddress(deployer_wallet_contract.address);

    // parameter：合约拥有者，master钱包地址
    // return：获取airdrop合约地址
    let airdropInit = await Airdrop.init(deployer_wallet_contract2.address);
    let airdropAddress = contractAddress(workchain, airdropInit);

    // parameter：airdrop合约地址，master钱包地址
    // return：获取jetton代币地址
    // let jettonInit = await JettonDefaultWallet.init(airdropAddress, jettonMaster);
    // let airdropJetton = contractAddress(workchain, jettonInit);


    console.log("------------jettonMaster--------" + jettonMaster);    // kQCh0pOy1E5V0yT9h4Y2HIWozhOoxuGBdEeReeb2Tie1Qxha
    console.log("------------airdropAddress--------" + airdropAddress); // kQAZPdoZta4p5kcMrYLFr9WdveOetPyExO-Y6QdDG4a4O2tJ
    // console.log("------------airdropJetton--------" + airdropJetton); //  kQCEbpAoD17HtNui-AQIJaQzT-LMjOOYahfopCXEdHts-Ujc



    let p3 = Address.parse("0QCHbKE2GVK3HdItkAhp3lHhT0mTGRhfGojDrVhLO31p_0VJ");
    let _addressBoolMap = Dictionary.empty<Address, boolean>(Dictionary.Keys.Address(), Dictionary.Values.Bool());
    _addressBoolMap.set(p3, true);
    let _addressIntMap = Dictionary.empty<Address, bigint>(Dictionary.Keys.Address(), Dictionary.Values.BigUint(256));
    _addressIntMap.set(p3, toNano(200));

    // *设置合约的jetton钱包
    let jettonAddress = Address.parse("kQBC_oNIjR-28AhT5mkijEn8MnInmslZRqR-RiYtw3Op0rit");
    let packed_JettonAddress = beginCell()
        .store(
            storeJettonAddress({
                $$type: "JettonAddress", // 个人奖励铸币
                jetton_address: jettonAddress, // 领取奖励的地址和数量
            })
        ).endCell();

    // 
    let packed_TransferToOwner = beginCell()
        .store(
            storeTransferToOwner({
                $$type: "TransferToOwner", // 个人奖励铸币
                query_id: 0n,
                amount: toNano(999999), // 领取奖励的地址和数量
            })
        ).endCell();


    // *添加一个奖励了地址 
    let packed_Append = beginCell()
        .store(
            storeAppend({
                $$type: "Append", // 个人奖励铸币
                receiver: deployer_wallet_contract3.address, // 领取奖励的地址和数量
                mark: true, // 是否可以领取
                amount: toNano(7778) // 数量
            })
        )
        .endCell();

    // *更新奖励地址信息
    let packed_UpdateAddressInfo = beginCell()
        .store(
            storeUpdateAddressInfo({
                $$type: "UpdateAddressInfo", // 个人奖励铸币
                receiver: p3, // 领取奖励的地址和数量
                mark: true, // 是否可以领取
                amount: toNano(888) // 数量
            })
        )
        .endCell();

    // *添加所有地址
    let packed_Replace = beginCell()
        .store(
            storeReplace({
                $$type: "Replace", // 个人奖励铸币
                ddressBoolMap: _addressBoolMap, // 接收者地址
                addressIntMap: _addressIntMap,
                length: BigInt(1)
            })
        )
        .endCell();

    // *清空所有地址
    let packed_deleteRewardMint = beginCell()
        .storeUint(0, 32)
        .storeStringTail("deleteAllRewardMint")
        .endCell();


    const test_message_left = beginCell()
        .storeBit(0) // 🔴  whether you want to store the forward payload in the same cell or not. 0 means no, 1 means yes.
        .storeUint(0, 32)
        .storeBuffer(Buffer.from("空投奖励", "utf-8"))
        .endCell();
    let forward_string_test = beginCell().storeBit(1).storeUint(0, 32).storeStringTail("EEEEEE").endCell();
    let packed_RewardAddress = beginCell()
        .store(
            storeRewardAddress({
                $$type: "RewardAddress",
                query_id: 0n,
                custom_payload: beginCell().endCell(),
                forward_ton_amount: toNano("0.000000001"),
                forward_payload: test_message_left,
            })
        )
        .endCell();

    // send a message on new address contract to deploy it 发送消息到新地址合约来部署它
    let seqno: number = await deployer_wallet_contract.getSeqno();
    let seqno2: number = await deployer_wallet_contract2.getSeqno();
    let seqno3: number = await deployer_wallet_contract3.getSeqno();




    // 钱包2，部署合约，管理合约
    // await deployer_wallet_contract2.sendTransfer({ // 合约调用者
    //     seqno: seqno2,
    //     secretKey: secretKey2,
    //     messages: [
    //         internal({
    //             to: airdropAddress,
    //             value: deployAmount, // gas 
    //             init: {
    //                 code: airdropInit.code,
    //                 data: airdropInit.data,
    //             },
    //             // body: packed_Append, // 调用消息
    //             body: packed_JettonAddress// 调用设置jetton地址
    //             // body: packed_UpdateAddressInfo // 更新奖励地址信息
    //             // body: packed_TransferToOwner// 转出余额给owner
    //         }),
    //     ],
    // });



    // // // 钱包3，领取奖励
    await deployer_wallet_contract3.sendTransfer({ // 合约调用者
        seqno: seqno3,
        secretKey: secretKey3,
        messages: [
            internal({
                to: airdropAddress,
                value: deployAmount, // gas
                init: {
                    code: airdropInit.code,
                    data: airdropInit.data,
                },
                body: packed_RewardAddress, // 调用消息
            }),
        ],
    });




})();