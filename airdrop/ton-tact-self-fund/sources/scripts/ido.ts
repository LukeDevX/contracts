import { Address, beginCell, contractAddress, toNano, TonClient4, internal, fromNano, WalletContractV4 } from "@ton/ton";
import { mnemonicToPrivateKey } from "ton-crypto";
import { buildOnchainMetadata } from "../utils/jetton-helpers";


import { SampleJetton, storeMint, storeTokenBurn } from "../output/SampleJetton_SampleJetton";
import { JettonDefaultWallet } from "../output/SampleJetton_JettonDefaultWallet";
import { Ido } from "../output/Ido_ido";

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

    let IdoEveryoneInit = await Ido.init(deployer_wallet_contract2.address);
    let IdoEveryoneAddress = contractAddress(workchain, IdoEveryoneInit);
    let deployAmount = toNano("0.15");

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

    // send a message on new address contract to deploy it 发送消息到新地址合约来部署它
    let seqno: number = await deployer_wallet_contract.getSeqno();
    let seqno2: number = await deployer_wallet_contract2.getSeqno();
    let seqno3: number = await deployer_wallet_contract3.getSeqno();

    // 钱包2，部署合约，管理合约
    await deployer_wallet_contract2.sendTransfer({ // 合约调用者
        seqno: seqno2,
        secretKey: secretKey2,
        messages: [
            internal({
                to: IdoEveryoneAddress,
                value: deployAmount, // gas 
                init: {
                    code: IdoEveryoneInit.code,
                    data: IdoEveryoneInit.data,
                },
                body: packed_TransferAll // 转出余额给owner
                // body: packed_IdoClose // 关闭ido
                // body: packed_IdoOpen // 开启ido，默认
            }),
        ],
    });






})();
