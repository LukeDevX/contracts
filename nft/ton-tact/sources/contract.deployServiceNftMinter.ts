import { beginCell, contractAddress, toNano, TonClient4, WalletContractV4, internal, fromNano, Address } from "@ton/ton";
import { mnemonicToPrivateKey } from "ton-crypto";
// @ts-ignore
import { Minter } from "../build/Minter/tact_Minter.ts";
import { Cell } from '@ton/core';
import { ServiceNftMinter, storeCreateNftCollection, storeMintIdentity } from "./output/sample_ServiceNftMinter";
import { createNftCollectionContent, NftContent } from "./utils/utils";
// import { loadExcesses, storeExcesses } from "./output/sample_NftItem";


(async () => {
    //create client for testnet sandboxv4 API - alternative endpoint
    const client4 = new TonClient4({
        endpoint: "https://sandbox-v4.tonhubapi.com",
        // endpoint: "https://mainnet-v4.tonhubapi.com",
        timeout: 500000
    });

    // 0QAsndRoSnjB_eMnGHhuYRSUMS-Ivt5YEc3o4T7qsYYuNoWq
    // const mnemonics = (process.env.MNEMONICS || "").toString(); // 获取的密钥文件不知道在哪里
    // 0QCHbKE2GVK3HdItkAhp3lHhT0mTGRhfGojDrVhLO31p_0VJ
    let mnemonics = "guess gloom focus wood shield thing orient asset major hint soon cotton sugar tuna absorb limit cram sword private review track alarm fix dash";
    let keyPair = await mnemonicToPrivateKey(mnemonics.split(" "));
    let secretKey = keyPair.secretKey;
    let workchain = 0; //we are working in basechain.
    let deployer_wallet = WalletContractV4.create({ workchain, publicKey: keyPair.publicKey });
    let deployer_wallet_contract = client4.open(deployer_wallet);
    let init = await ServiceNftMinter.init(deployer_wallet_contract.address);
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


    const NftChannel: NftContent = {
        name: "NFT's Channel",
        description: "Channel Partner channels the creations to the platform and earns from the revenue sharing of RWAs, as well as from community activity rewards.",
        image: "https://www.4arts.cc/images/nft/img/NFTChannel.png",
    };
    let packed_CreateNftCollectionChannel = beginCell().store(
        storeCreateNftCollection({
            $$type: "CreateNftCollection",
            royalty_params: {
                $$type: 'RoyaltyParams',
                numerator: 11n,//版本比例分子
                denominator: 1000n,
                //比例比例坟 
                destination: Address.parse("0QAsndRoSnjB_eMnGHhuYRSUMS-Ivt5YEc3o4T7qsYYuNoWq")// 部署人 // UQCeqFZ2fNvPHSpRlJaGGYQPvnVuGn-MvABofND7dpUH10Zr
            },
            collectionContent: await createNftCollectionContent({
                collectionContent: NftChannel,
                commonContent: "https://www.4arts.cc/images/nft/" //commonContentPrfix
            }),
            identityFilePath: beginCell().storeStringRefTail("item-identity/NFTChannel.json").endCell(),
        })
    ).endCell();


    const NftCreator: NftContent = {
        name: "NFT's Creator",
        description: "The creator will upload their creative works to earn $ENT & $ART and earn 60% reward for their RWA debut.",
        image: "https://www.4arts.cc/images/nft/img/NFTCreator.png",
    };
    let packed_CreateNftCollectionCreator = beginCell().store(
        storeCreateNftCollection({
            $$type: "CreateNftCollection",
            royalty_params: {
                $$type: 'RoyaltyParams',
                numerator: 11n,//版本比例分子
                denominator: 1000n,
                //比例比例坟
                destination: Address.parse("UQCeqFZ2fNvPHSpRlJaGGYQPvnVuGn-MvABofND7dpUH10Zr")// 部署人
            },
            collectionContent: await createNftCollectionContent({
                collectionContent: NftCreator,
                commonContent: "https://www.4arts.cc/images/nft/" //commonContentPrfix
            }),
            identityFilePath: beginCell().storeStringRefTail("item-identity/NFTCreator.json").endCell(),
        })
    ).endCell();


    const NftPlayer: NftContent = {
        name: "NFT's Player",
        description: "Entertainee can earn $ENT from watching entertainment works and interaction, as well as rewards for inviting new users.",
        image: "https://www.4arts.cc/images/nft/img/NFTPlayer.png",
    };
    let packed_CreateNftCollectionPlayer = beginCell().store(
        storeCreateNftCollection({
            $$type: "CreateNftCollection",
            royalty_params: {
                $$type: 'RoyaltyParams',
                numerator: 11n,//版本比例分子
                denominator: 1000n,
                //比例比例坟
                destination: Address.parse("UQCeqFZ2fNvPHSpRlJaGGYQPvnVuGn-MvABofND7dpUH10Zr")// 部署人
            },
            collectionContent: await createNftCollectionContent({
                collectionContent: NftPlayer,
                commonContent: "https://www.4arts.cc/images/nft/" //commonContentPrfix
            }),
            identityFilePath: beginCell().storeStringRefTail("item-identity/NFTPlayer.json").endCell(),
        })
    ).endCell();

    let packed_MintIdentityChannel = beginCell().store(
        storeMintIdentity({
            $$type: "MintIdentity",
            collectionIndex: 7n,//7
            queryId: 0n,
        })
    ).endCell();



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
                // body: packed_CreateNftCollectionChannel,
                // body: packed_CreateNftCollectionCreator,
                body: packed_CreateNftCollectionPlayer,
            }),
        ],
    });

    console.log("Your contactAddress deploy Done:", contactAddress);
})();
