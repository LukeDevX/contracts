import { Address, Dictionary, beginCell, contractAddress, toNano, TonClient4, WalletContractV4, internal, fromNano, address } from "@ton/ton";
import { mnemonicToPrivateKey } from "ton-crypto";
import { buildOnchainMetadata } from "../utils/jetton-helpers";

import { SampleJetton, storeMint, storeReplace, storeAppend, RewardArray, storeUpdateAddressInfo, storeTokenBurn } from "../output/SampleJetton_SampleJetton";
import { JettonDefaultWallet } from "../output/SampleJetton_JettonDefaultWallet";

import { printSeparator } from "../utils/print";
import * as dotenv from "dotenv";
dotenv.config();


// export type RewardArray = {
//     $$type: 'RewardArray';
//     addressBoolMap: Dictionary<Address, boolean>;
//     addressIntMap: Dictionary<Address, bigint>;
//     length: bigint;
// }

(async () => {

    //create client for testnet sandboxv4 API - alternative endpoint
    const client4 = new TonClient4({
        endpoint: "https://sandbox-v4.tonhubapi.com", // 测试网
        // endpoint: "https://mainnet-v4.tonhubapi.com",

    });
    //  let p1 = Address.parse("0QD4YF6Hv76S1GxezQZ3bMRAXJYSMH93g-ll1VaeO1Y7Jl9s");
    // let mnemonics = (process.env.mnemonics_2 || "").toString(); // 🔴 Change to your own, by creating .env file! // 助记词
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


    const jettonParams = {
        name: "Airdrop ",
        description: "Airdrop2",
        symbol: "ABC",
        image: "https://avatars.githubusercontent.com/u/104382459?s=200&v=4",
    };

    // const jettonParams = {
    //     name: "Entertainment Coins",
    //     description: "The governance token of the 4Arts platform",
    //     symbol: "ENT",
    //     image: "https://www.4arts.cc/home/ent-token-icon.png",
    // };

    // Create content Cell
    let content = buildOnchainMetadata(jettonParams);
    // let max_supply = toNano(100000000000); // 🔴 Set the specific total supply in nano
    // let max_supply = toNano(20000000000);
    let max_supply = toNano(60000000000); // 部署后固定不变，即使后面增大供应，初始化值也不变

    // Compute init data for deployment
    // NOTICE: the parameters inside the init functions were the input for the contract address
    // which means any changes will change the smart contract address as well
    let init = await SampleJetton.init(deployer_wallet_contract.address, content, max_supply);
    let jettonMaster = contractAddress(workchain, init);
    let deployAmount = toNano("0.15");

    // 根据发送者地址.master钱包地址,获取jetton代币地址
    let jettonInit = await JettonDefaultWallet.init(deployer_wallet_contract.address, jettonMaster);
    let jettonWallet = contractAddress(workchain, jettonInit);

    // let init2 = await SampleJetton.init(deployer_wallet_contract2.address, content, max_supply);
    // let jettonMaster2 = contractAddress(workchain, init2);

    // 40000
    let supply = toNano(60000000000); // 🔴 Specify total supply in nano 
    // 铸币
    let packed_msg = beginCell()
        .store(
            storeMint({
                $$type: "Mint", // 合约创建者铸币
                amount: supply,
                receiver: deployer_wallet_contract.address,
            })
        )
        .endCell();

    let p1 = Address.parse("0QD4YF6Hv76S1GxezQZ3bMRAXJYSMH93g-ll1VaeO1Y7Jl9s");
    let p2 = Address.parse("0QAcG9euCnik-vpnbzZ_bWZl98gX8OGmFm2Wr5n-drRaQn7A");
    let p3 = Address.parse("0QDiUISMHHfjHjqFgGAhT9d9OpPO5puVewBSXKCwzpG3l57p");


    // let rewardArray: RewardArray = {
    //     $$type: 'RewardArray',
    //     addressBoolMap: {
    //         //@ts-ignore
    //         p1: true,
    //         p2: false
    //     },
    //     addressIntMap: {
    //         //@ts-ignore
    //         p1: BigInt(100),
    //         p2: BigInt(200)
    //     },
    //     length: BigInt(2)
    // };




    // *关闭铸币后，任何人都无法铸币
    let packed_MintClose = beginCell()
        .storeUint(0, 32)
        .storeStringTail("Owner: MintClose")
        .endCell();


    // 开始构造cell，结束构造cell
    let forward_string_test = beginCell().storeBit(1).storeUint(0, 32).storeStringTail("EEEEEE").endCell();
    let burn_amount = toNano(4000000);
    let packed_TokenBurn = beginCell()
        .store(
            storeTokenBurn({
                $$type: "TokenBurn", // 个人奖励铸币
                query_id: 0n,
                amount: burn_amount,
                response_destination: deployer_wallet_contract.address,//  自己wallet钱包地址
                custom_payload: forward_string_test
            })
        ).endCell();


    // send a message on new address contract to deploy it 发送消息到新地址合约来部署它
    let seqno: number = await deployer_wallet_contract.getSeqno();
    let seqno2: number = await deployer_wallet_contract2.getSeqno();
    console.log("🛠️Preparing new outgoing massage from deployment wallet. \n" + deployer_wallet_contract.address);
    console.log("Seqno: ", seqno + "\n");
    printSeparator(); // 日志打印换行

    // Get deployment wallet balance
    let balance: bigint = await deployer_wallet_contract.getBalance();

    console.log("Current deployment wallet balance = ", fromNano(balance).toString(), "💎TON");
    console.log("Minting:: ", fromNano(supply));
    printSeparator();


    await deployer_wallet_contract.sendTransfer({ // 合约调用者
        seqno: seqno,
        secretKey: secretKey,
        messages: [
            internal({
                to: jettonMaster, // 发送到的 master 钱包地址
                value: deployAmount, // gas 
                init: {
                    code: init.code,
                    data: init.data,
                },
                body: packed_msg, // 调用消息
            }),
        ],
    });
    // console.log("====== Deployment message sent to =======\n", jettonMaster);

    // await deployer_wallet_contract.sendTransfer({ // 合约调用者
    //     seqno: seqno,
    //     secretKey: secretKey,
    //     messages: [
    //         internal({
    //             // to: jettonMaster, // 发送到的 master 钱包地址
    //             to: jettonWallet,
    //             value: deployAmount, // gas 
    //             init: {
    //                 code: jettonInit.code,
    //                 data: jettonInit.data,
    //             },
    //             // body: packed_msg, // 调用消息
    //             body: packed_TokenBurn, // 调用消息
    //         }),
    //     ],
    // });
    console.log("====== Deployment message sent to =======\n", jettonWallet);

})();

