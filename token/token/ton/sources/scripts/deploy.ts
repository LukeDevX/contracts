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
        // endpoint: "https://sandbox-v4.tonhubapi.com", // 测试网
        endpoint: "https://mainnet-v4.tonhubapi.com",// 主网

    });
    // 钱包1 信息
    const mnemonics = "word word word"; // 助记词
    let keyPair = await mnemonicToPrivateKey(mnemonics.split(" ")); // 转密钥
    let secretKey = keyPair.secretKey; // 私钥
    let workchain = 0; //we are working in basechain.
    let deployer_wallet = WalletContractV4.create({ workchain, publicKey: keyPair.publicKey });
    console.log(deployer_wallet.address);
    let deployer_wallet_contract = client4.open(deployer_wallet); // 打开钱包1

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

    let seqno: number = await deployer_wallet_contract.getSeqno();

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

