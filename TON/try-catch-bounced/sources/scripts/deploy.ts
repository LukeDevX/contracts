import { beginCell, contractAddress, toNano, TonClient4, WalletContractV4, internal, fromNano, Address } from "@ton/ton";
import { mnemonicToPrivateKey } from "ton-crypto";
// @ts-ignore
import { Minter } from "../build/Minter/tact_Minter.ts";
import { Cell } from '@ton/core';
import { SampleTactContract } from "../output/contract_SampleTactContract";


(async () => {
    //create client for testnet sandboxv4 API - alternative endpoint
    const client4 = new TonClient4({
        endpoint: "https://sandbox-v4.tonhubapi.com",
        // endpoint: "https://mainnet-v4.tonhubapi.com",
        timeout: 500000
    });

    // UQCeqFZ2fNvPHSpRlJaGGYQPvnVuGn-MvABofND7dpUH10Zr
    // 0QBZhX-35v_tGP_Zq4iPHjFtBa-7v2Nnwp4D9W3susdYLpl6
    // let mnemonics = "glove input item control potato elevator veteran sample crew filter trip satisfy hungry leaf salt truth tobacco leader exchange step forward mixed dutch elephant"; // 🔴 Change to your own, by creating .env file!


    // 0QCHbKE2GVK3HdItkAhp3lHhT0mTGRhfGojDrVhLO31p_0VJ
    let mnemonics = "gym deal bike dream vibrant wrist round toe spend say census come mass already error night reveal model cross evoke vessel become fuel chimney";
    let keyPair = await mnemonicToPrivateKey(mnemonics.split(" "));
    let secretKey = keyPair.secretKey;
    let workchain = 0; //we are working in basechain.
    let deployer_wallet = WalletContractV4.create({ workchain, publicKey: keyPair.publicKey });
    let deployer_wallet_contract = client4.open(deployer_wallet);
    let init = await SampleTactContract.init(deployer_wallet_contract.address);
    let contactAddress = contractAddress(workchain, init);

    // let deployAmount = toNano("0.1"); // 部署
    let deployAmount = toNano("0.03"); // mint init
    // let deployAmount = toNano("0.16"); // mint
    let seqno: number = await deployer_wallet_contract.getSeqno();
    let balance: bigint = await deployer_wallet_contract.getBalance();
    // console.log("Your contact owner wallet address  " + keyPair.publicKey);
    console.log("deployer_wallet   " + deployer_wallet.address);
    console.log("Your contact owner wallet contact address  " + deployer_wallet_contract.address);
    console.log("Your contact Seqno: ", seqno + "\n");
    console.log("Your wallet balance: ", fromNano(balance).toString(), "💎TON");
    console.log("Your contactAddress address: ", contactAddress);


    // 发送字符串消息
    let packed_IdoOpen = beginCell()    // 开启ido
        .storeUint(0, 32)
        .storeStringTail("trycatch")
        .endCell();


    await deployer_wallet_contract.sendTransfer({
        seqno,
        secretKey,
        messages: [
            internal({
                to: contactAddress,
                value: deployAmount,
                init: {
                    code: init.code,
                    data: init.data,
                },
                // body: packed_NewTodo
                body: packed_IdoOpen
            })
        ],
    });

    console.log("Your contactAddress deploy Done:", contactAddress);
})();
