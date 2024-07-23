import { Address, beginCell, contractAddress, toNano, TonClient4, internal, fromNano, WalletContractV4 } from "@ton/ton";
import { deploy } from "../utils/deploy";
import { printAddress, printDeploy, printHeader, printSeparator } from "../utils/print";
import { buildOnchainMetadata } from "../utils/jetton-helpers";
import { mnemonicToPrivateKey } from "ton-crypto";
import * as dotenv from "dotenv";
dotenv.config();

import { SampleJetton, storeTokenTransfer, storeMint } from "../output/SampleJetton_SampleJetton";


// let NewOnwer_Address = Address.parse("0QD4YF6Hv76S1GxezQZ3bMRAXJYSMH93g-ll1VaeO1Y7Jl9s"); // 🔴 接收者地址.

let NewOnwer_Address = Address.parse("0QDiUISMHHfjHjqFgGAhT9d9OpPO5puVewBSXKCwzpG3l57p"); // 🔴 接收者地址.

// let NewOnwer_Address = Address.parse("kQDypVz2gTWGQPSb0Fuc6jKho9-nEzhtwoxIr_w6BI77sTqZ"); // 🔴 接收者地址.

(async () => {


    // ========================================
    const client4 = new TonClient4({
        endpoint: "https://sandbox-v4.tonhubapi.com", // 测试网
        // endpoint: "https://mainnet-v4.tonhubapi.com",
    });

    // 连接钱包
    let mnemonics = "iron correct shaft party music degree term view radar goat load poet stumble awful opera trouble ill apple remain window caught control flower wheel"; // 🔴 Change to your own, by creating .env file!
    let keyPair = await mnemonicToPrivateKey(mnemonics.split(" "));
    let secretKey = keyPair.secretKey;
    let workchain = 0;
    let wallet = WalletContractV4.create({
        workchain,
        publicKey: keyPair.publicKey,
    });

    let wallet_contract = client4.open(wallet);


    // jetton 信息
    const jettonParams = {
        name: "Airdrop ",
        description: "Airdrop2",
        symbol: "ABC",
        image: "https://avatars.githubusercontent.com/u/104382459?s=200&v=4",
    };
    // Create content Cell
    let content = buildOnchainMetadata(jettonParams);
    let max_supply = toNano(60000000000); // 🔴 Set the specific total supply in nano

    // init 参数
    // Compute init data for deployment 计算部署的初始化数据
    // NOTICE: the parameters inside the init functions were the input for the contract address 注意：初始化函数中的参数是合约地址的输入
    // which means any changes will change the smart contract address as well. 这意味着任何更改也会改变智能合约地址。
    let init = await SampleJetton.init(wallet_contract.address, content, max_supply);
    let jetton_masterWallet = contractAddress(workchain, init);
    let contract_dataFormat = SampleJetton.fromAddress(jetton_masterWallet); // 获取master 合约信息，
    let contract = client4.open(contract_dataFormat); // 打开合约
    let jetton_wallet = await contract.getGetWalletAddress(wallet_contract.address);// 获取发送者的代币钱包地址，需保证 master代币 合约已经部署，否则报错
    // let jetton_wallet = contractAddress(workchain, init);
    console.log("✨ " + jetton_masterWallet + "'s contract_dataFormat ==> ");
    // ========================================


    let supply = toNano(600000);         // 设置供应代币数额
    let packed_msg = beginCell()
        .store(
            storeMint({
                $$type: "Mint", // 合约创建者铸币
                amount: supply, // 铸币数额
                receiver: wallet_contract.address, // 接收者地址
            })
        )
        .endCell();


    // ✨Pack the forward message into a cell
    const test_message_left = beginCell()
        .storeBit(0) // 🔴  whether you want to store the forward payload in the same cell or not. 0 means no, 1 means yes.
        .storeUint(0, 32)
        .storeBuffer(Buffer.from("空投奖励", "utf-8"))
        .endCell();

    // const test_message_right = beginCell()
    //     .storeBit(1) // 🔴 whether you want to store the forward payload in the same cell or not. 0 means no, 1 means yes.
    //     .storeRef(beginCell().storeUint(0, 32).storeBuffer(Buffer.from("Hello, GM. -- Right", "utf-8")).endCell())
    //     .endCell();

    // 调用TokenTransfer 消息
    let forward_string_test = beginCell().storeBit(1).storeUint(0, 32).storeStringTail("EEEEEE").endCell();
    let packed = beginCell()

        .store(
            storeTokenTransfer({
                $$type: "TokenTransfer",
                query_id: 0n,
                amount: toNano(7777777), //转装金额
                // sender: NewOnwer_Address, // 目标地址
                sender: Address.parse("kQAZPdoZta4p5kcMrYLFr9WdveOetPyExO-Y6QdDG4a4O2tJ"),
                response_destination: wallet_contract.address, // Original Owner, aka. First Minter's Jetton Wallet 发送者的jetton钱包
                custom_payload: forward_string_test,
                forward_ton_amount: toNano("0.000000001"),
                // forward_ton_amount: toNano("0"),
                forward_payload: test_message_left,
            })
        )
        .endCell();

    let deployAmount = toNano("0.3"); // gas设置
    let seqno: number = await wallet_contract.getSeqno();
    let balance: bigint = await wallet_contract.getBalance();
    // ========================================
    printSeparator();
    console.log("Current deployment wallet balance: ", fromNano(balance).toString(), "💎TON");
    console.log("\n🛠️ Calling To JettonWallet:\n" + jetton_wallet + "\n");

    // 发送消息
    await wallet_contract.sendTransfer({ // 发送者对象
        seqno,
        secretKey,
        messages: [
            internal({
                to: jetton_wallet, // 发送到的目标合约
                value: deployAmount,
                init: {
                    code: init.code,
                    data: init.data,
                },
                bounce: true,
                // body: packed_msg,
                body: packed
            }),
        ],
    });

})();
