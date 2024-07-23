import React, { useEffect, useState } from 'react'
import Header from '../components/Header'
import Footer from '../components/Footer'
import { Slider, Switch, Button, message, Input, Progress, Spin, Modal } from 'antd';
import Image from 'next/image';
import t from "../public/locales"
import { useGlobalContext } from '../GlobalContext';

import { useAnchorWallet, useConnection, useWallet } from '@solana/wallet-adapter-react';
import { AnchorProvider, Provider, getProvider, setProvider, Program } from '@coral-xyz/anchor'
import {
    WalletMultiButton
} from '@solana/wallet-adapter-react-ui';
import * as web3 from "@solana/web3.js";
import * as anchor from '@project-serum/anchor'
import counter from '../idl/counter';
import token from '../idl/token';
import axios from "axios"
import { find_is_init, can_airdrop } from "../util.js"
import {
    getAccount,
    getOrCreateAssociatedTokenAccount,
} from "@solana/spl-token";
export default function Ido() {
    useEffect(() => {
        console.log("6666")
    }, [])

    const wallet = useAnchorWallet();
    const { connection } = useConnection();
    const { publicKey, sendTransaction } = useWallet(); // 获取钱包信息
    let provider = new AnchorProvider(connection, wallet, {});
    const counter_program = new Program(counter.idl, counter.address, provider); // 获取合约对象
    const token_program = new Program(token.idl, token.address, provider);

    const [update, setUpdate] = useState(false);
    const [load, setLoad] = useState(false);
    const { state, dispatch } = useGlobalContext();
    console.log("sate", state)
    const lang = state.lang;
    const [inputValue, setInputValue] = useState(0.01);
    const [value, setValue] = useState("");
    const [allsol, setAllSol] = useState(0);
    const transferSol = async (publicKey, to, amount) => {
        try {
            const txInstructions = [
                web3.SystemProgram.transfer({
                    fromPubkey: publicKey, //this.publicKey,
                    toPubkey: new web3.PublicKey(to), //destination,
                    lamports: amount * 1000000000, //amount,
                }),
            ];
            const {
                context: { slot: minContextSlot },
                value: { blockhash, lastValidBlockHeight },
            } = await connection.getLatestBlockhashAndContext();
            console.log("slot:", minContextSlot);
            console.log("latestBlockhash:", blockhash);

            const messageV0 = new web3.TransactionMessage({
                payerKey: publicKey,
                recentBlockhash: blockhash,
                instructions: txInstructions,
            }).compileToV0Message();

            const trx = new web3.VersionedTransaction(messageV0);
            const signature = await sendTransaction(trx, connection, {
                minContextSlot,
            });
            return signature
        } catch (error) {
            message.error(t[lang].cfail)
        }
    }
    const onChange = (newValue) => {
        setInputValue(newValue);
    };

    const [bought, setBought] = useState(0);

    const get_all_sol = async () => {
        const counters = await counter_program.account.counter.all();
        let sum = 0;
        for (let i = 0; i < counters.length; i++) {
            sum += counters[i].account.count
        }
        setAllSol(sum)
    }

    useEffect(() => {
        get_all_sol()
    }, [])
    const queryInfo = async () => {
        setBought(0)
        const counters = await counter_program.account.counter.all();
        console.log("counters", counters)

        if (publicKey && find_is_init(counters, publicKey.toString())) {
            console.log("find_is_init", find_is_init)
            const res = find_is_init(counters, publicKey.toString())
            setBought(res.account.count)

        }
    }
    useEffect(() => {
        queryInfo();
    }, [publicKey, update])




    const buy = async () => {
        console.log("value", inputValue)
        if (publicKey) {
            const res = await transferSol(publicKey, "5u4Vgj2cXQcXBkKT6adv9RMFXMLEaStHvLgxi4Wvj5q8", inputValue);
            if (res) {
                //转账成功,查询是否存在(判断bought)
                let [couter_account] = anchor.web3.PublicKey.findProgramAddressSync(
                    [
                        wallet.publicKey.toBuffer(),
                    ],
                    counter_program.programId
                );
                console.log("couter_account", couter_account)
                console.log("bought", bought)
                if (bought) {
                    console.log("更新")
                    //如果已经存在就更新
                    console.log("inputValue", inputValue);
                    const sig = await counter_program.methods
                        .updateCounter(inputValue, false)
                        .accounts({
                            counter: couter_account,
                            authority: wallet.publicKey,
                        })
                        .rpc();
                    console.log("sig", sig)
                } else {
                    console.log("创建", inputValue)
                    //不存在就创建,转账多少就是多少
                    const sig = await counter_program.methods
                        .createCounter(inputValue, false)
                        .accounts({
                            counter: couter_account,
                            authority: wallet.publicKey,
                        })
                        .rpc();
                    console.log("创建sig", sig)
                }
                setUpdate(!update);
            } else {
                message.error(t[lang].cfail)
            }
        } else {
            message.error(t[lang].cfail)
        }
    }

    const claim = async () => {
        // let [tokenAccountOwnerPda] = web3.PublicKey.findProgramAddressSync(
        //     [Buffer.from("token_account_owner_pda")],
        //     new web3.PublicKey(token.tokenaddress)
        // );
        if (!publicKey) {
            message.error(t[lang].cfail)
            return
        }

        //先判断是否可以开始空投
        const counters = await counter_program.account.counter.all();
        let can = can_airdrop(counters);
        console.log("can", can)
        if (can) {
            //可以领取空投
            const mintDecimals = Math.pow(10, 9);

            //先更新counter，再领取代币
            let [couter_account] = anchor.web3.PublicKey.findProgramAddressSync(
                [
                    wallet.publicKey.toBuffer(),
                ],
                counter_program.programId
            );
            const sig = await counter_program.methods
                .updateCounter(0, false)
                .accounts({
                    counter: couter_account,
                    authority: wallet.publicKey,
                })
                .rpc();
            console.log("更新sig", sig)

            // console.log("tokenAccountOwnerPda", tokenAccountOwnerPda)
            const tokenAccount = await getOrCreateAssociatedTokenAccount(
                connection,
                wallet.publicKey,
                //token address
                new web3.PublicKey(token.tokenaddress),
                wallet.publicKey
            );
            console.log("tokenAccount", tokenAccount)
            let confirmOptions = {
                skipPreflight: true,
            };
            let txHash = await token_program.methods
                .transferOut(new anchor.BN(bought * 700000 * mintDecimals))
                .accounts({
                    tokenAccountOwnerPda: new web3.PublicKey(token.tokenAccountOwnerPda),
                    vaultTokenAccount: token.vaultTokenAccount,
                    senderTokenAccount: tokenAccount.address,
                    //代币地址
                    mintOfTokenBeingSent: new web3.PublicKey(
                        token.tokenaddress
                    ),
                    signer: wallet.publicKey,
                })
                // .signers([wallet.publicKey])
                .rpc(confirmOptions);
            console.log("txHash", txHash)

        } else {
            //不能领取空投
            message.error(t[lang].cant)
        }
    }
    return (
        <div className='bg-[black] min-h-screen  max-w-full ' >

            <Header ></Header>
            <Button type='primary' onClick={async () => {
                const counters = await counter_program.account.counter.all();
                console.log("counters", counters)
            }}>查询信息</Button>
            {/* <Button type='primary' onClick={buy}>转账</Button> */}
            <div className='text-[white] font-bold  text-center css-513rzv '>
                <div className=' text-[32px] animate__animated  animate__bounce  css-513rzv md:text-[58px] min-[1px]:text-[20px] font-normal'>{t[lang].launchpad}</div>
                <div className='text-[20px] css-513rzv mt-[20px]'>{t[lang].discover}</div>
                <div className='pl-[5px] pb-[5px] mt-[10px]' >{true ? <div suppressHydrationWarning>{t[lang].processing}</div> : <div suppressHydrationWarning>{t[lang].completed}</div>}</div>
            </div>
            <Modal title="" className='load' open={load} onCancel={() => { setLoad(false) }} footer={false} >
                <div className=' text-center'>
                    <Spin />
                </div>
            </Modal>
            <div className='min-[10px]:w-[90%] lg:w-[500px] text-[white] bg-[#333333] pb-[30px] m-auto mt-[60px] mb-[60px] rounded-[10px]'>
                <div className='box-border p-[10px] flex justify-between' >
                    <div>
                        <div className='flex items-center mt-[20px]'>
                            <div className='mr-[10px]'>
                                {/* <BankTwoTone className='text-[30px]' /> */}
                                <img width={35} src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAAAAXNSR0IArs4c6QAAD1NJREFUeF7tmlmMXNldh79z7lL71ot7s8ceZzILo5A9kCd4I/ASJBAJEg888BKEAhIRaAYJ3gBFRIpClIgskEQICR7gEWVekRAwYYISTSaasdv2THfX1tW1V93lLOjcqvbYxjNtd+xpovGRum+p6tate77zX3/nCt7lQ7zL588jAI8s4F1O4JELvMsN4FEQPJULWGt94GmteSpR7GDZEoIGgrKAChAi8Cy48xxlhUUBqYUxlrG1DBA0Q589rXktDHlFCOHOeUfHPQOw1l7Qmk8AHwUuWrDGoixoDEpbLGCMzd53ry1mMRcLQkiQAoFFSokQIjt6AnwpsqO7l9eB//Q8XhBCuNcPfZwIwFrbAJ6zlo8YwxyYaUNsLIkypMagDSitsMpgBRj3xmLetw3HQCARvkRIifQknoPgSwIpCKUgLwRFKbPj94A/F0IMHiaFEwFobb9tBZtYBlox0ZaJMkSpJjGGNE6wSqNTA0kCyk1eYI0hI+OG51ZfZkjcxEU+xHoSEXrIXB4HJgg8Ql+S9yRlz6OMoC4sTc8Tv32mAJSx/4qhpwx9rRmkmkmkiaKIVFnUZI6IImyqQSmE1tjUIBwAZXDTdv+s72MDByOA7LUH+TyimIPQwwtDwmJATgqqYUDVlzSQrPpS/PKZAogT+48W2nFKL1YMYsVkMCEZz1CxwoxnyGQO0wRvrpCJQqYKaSxiaQDuhfA8TOBjchIbhphSDh0GUC5h8j5erYysFMkVQ0o5n3ouYFXARi4UnzpTAPPIfkNpmlPF4WTGcDhk1otIB0P0KEIeDgjjFDFX+MmcwIBMUjwrEdYs0qz0yEJlGKB9gfVC0lyALobotTpJ0YNGA3muhF+pUKqWqRZ81kOPzUJe/M6ZAphG9kvziOYkpdsfMOwOmO4N0EdDGKX4oyNyyuDNU4I0IkgUnvbwjcJbOAAI7ZIi2jcoX2JyJeJ8iPItutIgLvsZCHu+gbdeo7S6SrWcY70QslXKi8+eKYD+xH5hGnPQG3HYHjLa6zJ7o43sDBBxQjCNKcYJvtLkY0NoLZ6JyTlLcK8zABIjBVr4JO6Y84h9SZrLEZdyzPwQvVVHb63DhTUK2ytUzlVZy+fYbpTFH54pgN7Ifn4wodkdc3ityeSNI+adPbx2jIxScumcsrIEcUpRW/LC4mlLaAy+OQYgsFKQepIUUF7A3LckYUAUFJgEknSrhLqwg95cI39xlcpGndV6ma3VqvijMwXQPLKfH01oNoccXm8xu9EnOtjDH04JosWqV7Qz/5SSsuSxBNZkFuBWf+EENqsPtJDESFQAc+kTBSFRXjB21rBSI3psA719jtzlDQobNdbrZTa3Vs4YwOtd+1fDKc03uvSvvk603yNuDgj7E0JlKSQxldSQTw0loygi8K0mb93xGICzgEUpHAtJKj1mvmTuwzzMMQ4EcaPMfKNKemGd8IlL5HZWWWlU2HxsXXzuTC3gett+oT+mtd/jaLdF9PoBaXNIOJgSpppSoqhaS5gkVI2l6Op/Yyg4/xcLK8A6C/BIBcTSAbCZ388CwSz0GUmI6xVmmyskj20QXN4m7wCsVti4tHHGMeDqgf1ib0zr9S6D1/ZJ9jskrRH58Yy8SihGiobR5Kyloiwlawn0AoS8CYDMBZQUzKXIMsFEwkz6zPIeAwegUmWyUSE+v03w5DbB+XUa6xU23rMt/uBMLeDVfful7pj29Q7D3SbxQQfVGlAcjyikhmKiWTGavLZUtaZsILBQcJO3ZpkFBMY1TZ5gbskAjH2PqZSZBRxJQVStMNloMD+/jv/4JuFja9Q3G6w/uXPGafCVN+yXe0PaNzoMr+yT7h+StocUx1OKylBKNQ0NOZ1S14aSC4AOgKt6j9Og8wIhUALmAlLpZ4FvKj2mgUffAagVGa3XiHbW8d+7jX/xHLX1BueeuSB+70wt4OXr9iuHQ9q7bcZXm6R7PXSvS3GkKKaKqnYuYLMgWDeGMpYQkwVBB2ChB4isMVZCMBcyO448wdQXTDyfvvCIGiHDlXVmrhh6z9YCwNYKa89eEr97pgB+eMN+td2ne/2A0W4LfXCE6vQojVOKSlFRijVjyWlDzVrKZgGgkGWBZR2wtAAXBB2AVMJYCqaeZOoHHApJVM8zXG0w36njvWcb+dgmte01Vt93UXzmTAH8z679GwfgRpPxbhO1P0B3ulSmrvDRVJShYV0atFkwLFsIlzHAAcgsgIUFLAAsXGDk2SwGTHyZucC8VGaqLptLs7J5clxgZx6K6swT+bEvhJJ4RiK0C6vOt1yFZaz1FSqnmIbKDkNt9/LavhhE5oWXfzP3XYS4U4+4K8cT9YDv79qvZQBajK/sYQ4G6G6fyjSipAzVNGUVyGuoGpOlRNf1Fqx5sw4QrhRypg+RgER6WeqbiiJq9qx6sr8mdnp1r6Dkg9Eoc8qYxtTeqMbmX/Kl4E9/8Eti+lZWdM8AdptMdw/QrR6mO6A8nVNOLZVUsWItBQM1Y6hYSWA1JVcF3nQBgVlWgs4CElmy6dHP6ScPtv2SdjLZclTnmpWJpjExVCJDITEU40VeXaz64kQt3Z8g9gWznGAeSoZFSb/kcVT2mOWWXRi4Ts1sDdQL1UL463cDcSKA771mv9E6ysrgydUWpn2IPhxRnsypGCgnilXrLEBTz2IA5JYxwBVBWSGUxQBLimQudkzx1V8Q24kvMsPY6ise76ZsHymKyT1Z7YkhYViQHKz4XNkMMyhuVCITPdFSH/7+b+V+dOsFTgTw0hLA1QOm1zoZANMZUZ5GlLWlkixcwAVBlwWqVmQdoesJXCm86AZdDLAoERBd/Q37eBQIsdVP+diViNr8WDY5cV6nOqFZ9/ivJwoMix7rI93t/op/7r4A/Per9putHoe7LSbHANoDqrMk6/6cC6wZyBuTuUDVukLoGMAtQdAFP++cET/8FbkVKMuvvjim4ETyd2C0ax7ffX+ZnLI2/sVMnbw5TrSAYwBXmwsLaHWxnSGV+TGAdAEgS4NQsSLrBl0v4ILhcTfoNIGkUtBm9xN2p1v1yaWGD1yPudxJCPTDoTAPBK+cD/nRTi4TJJ7ej/nxp/K3zfneAbSZXmstAYypzKPbLcC5gCVLg28L4OKF6c6/PV2g2XB8yALchcOU7b5ic/CTxQFnT6OCpNnwOWj47K/4WQnqYs1TBwkfvRrx98/V7w/Aiz+2f9s8pHety8QBWMaA6mwJQGnWnBBibGYBxwCKyxrgTQsQpJWi1k9tTnbcxG+s+bxyPkenuigVjoezjMbUUJkvs0BicS6TqStm0VVp9+fdkQUKkkHJQ7kedDmEtVzoKZ7di53/Z+9+5/lTAHBZ4FpnASBzgRFvBaByiwW4mS1CsGuHHYCCNk9tTbZvnbBLX26lDuo+h1WPxL/NRe/bN1zq3BiqzKJ2eur/xJl3GsDtFnAXAHfOcJoT2UpOc65VdHleorxF3ldua8mlFic3uZrb9d2xU2UWdYOrH3Jus+5txsMGcM8ucN9L+4C+cN8A7poF7hYEXQywHLvAiTHgAc3nvi/zYACcnAbvCqC8pfynC9O1+77rB/iFUwP4iQuhiybY/3lqn3xxfGLqfYDzve1SAnH07edrrnJ9M1Oc9GPHpbADsNvC3iyFY0raZKWwW9FFKbxwgRBL3hVCt5bC+7+m14dlT3zye2Nqs4db/r71nORffuf56nP3BeCtmqFpTFlDOU5YdxPOKkFDxQhC1x67OuBWRejGp82Gi+wfvzLniYPkwfS9J63e8vNMkfX5p3/4XO3T4g6d4ERzfOmK/Xp7QPdGm/GVfUzrCH04yLrBcur0ALNsh5eS2LIOKFv3KMQtvUD947Otf3+ymN3S2kjx4esRG4OHVAMvJ+5S5/VzQZZO3/9G8rFvPVd78U5mJwL4/hX7tfbwDkGkR2WaLAURzWpmAXapBzjTt5SweE4XXP6g+cjjwx1X/bnOzPXvbrgK7+JhyuVOSn2qyaX2J7IMt9LjvKRd8zlYCXBN0M/sxTz7RownxOkA3CqJXT1AO0Woc0jZSWJOEVKaVSeJqeM0aAgNFLPVP9YEBebDjw8fc5NOPdg9F/Lq9pu9+purYqlNLRujlOpsIYbk3dazdhJz9uAJxsnLkqxidM3OsCSZ5TwmywLKiSWlyPBEK+G9reSmxiBPC+CH15aiaOt2UXSiKDlRNNWsak0hE0TMTU3Q2fqbT4kJzIcuDi/faX6TvKBZ97MV65e9TNVxE7y/YTNYrn9YG6tMWGncJcieGoCTxTt9Ote7jHYPUE4VbnWoTJaqcAbAuYCiblw7bBeiqLPwm+3wAsB7T5qY082cxDULJfNQkPgiK4G1l22vZSWwa4p8DcXENUuWUmxuSmVvd/1TA3AbI10HoM3IbYzsHWYPR+QHEWXlVOGUhrYU3AaJS4PuGUGrs01SZwE3m6EPPT585iQAD/PzUwN4bd/+dXdI50ZrsTN0cETa6lMcup0hvdAEMwvQ2c5QBUHodoldNnDPAh5nog9eGr7vYU7wpGufGsDVpv1yb0Bnr83gaot4r4faP6I4GGfxqRinCz1Aa2rKWYDbKBUUrM5cYLEzZDEfuDz84Ek3+TA/PzWAa0371dGM1l6Pgdsc3e+StAbk+wNyUUI5Smkom22V191Wmdsac1kgK4JuSYPP7ow/EHgm/zAn+VbXFggjy3Lz7z5b6d53HXCjbf9sFpHrjujvtonbPZKDI8L+iNwkojiNMtPPJWmWEit6IYllLmCWu8NSYFfKSXWjGj2z0HTe2SHg899+vv7Hd/vVE2+m07HlfsynpzFbrR5xe0Ry0CPoDfCnM/KjmFqaZs8IVeOUinIyn3tShFv2Bpebo7V8WqoV589IrNs4eehDwEAI8Sffeq72lbe2jnu8jZdesutH8P7ZjEvdGVv9MeF4SjicU4ljgjimPIuzB6Z85VRhjW+WLiDBPTGoXHbzJDYfJHVscskYs/EwLEII8TLwzSL2W199rt5/uymeaAF3+7K1Vn7xn7mUwMXplPNasRGlbMYJa6lh3T02IxebpDezgHuUOO8x8j26YY7DMKCDMcPpPNqaz/SlVJtLWH7WQv0e12RxmmCOFS8j7A+kkP/h+cEL3/xc4ca9XuNUAO714qc57zN/MWjMhLeN1TsCalaIAtY6MV8KK+cIE1krxp7wm6JgD77++6XOnR3e/fzu/zsA93PzD+LcRwAeBMWf5ms8soCf5tV7EPf+yAIeBMWf5mv8LyftJsiNLJcqAAAAAElFTkSuQmCC" alt="" />
                            </div>
                            <div>
                                <div className='text-[#ffffff80]'>{t[lang].amountforsale}</div>
                                <div>3500,000,000CB</div>
                            </div>
                        </div>
                        <div className='flex items-center mt-[20px]'>
                            <div className='mr-[10px]'>
                                {/* <BankTwoTone className='text-[30px]' /> */}
                                <img width={35} src="data:image/png;base64,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" alt="" />
                            </div>
                            <div>
                                <div className='text-[#ffffff80]'>{t[lang].price}</div>
                                <div>1SOL=700,000CB</div>
                            </div>
                        </div>
                    </div>
                    <div className='text-center'>
                        {/* <Progress type="circle" percent={ido_data && (ido_data.formatted / 175 * 100).toFixed(4)} /> */}
                        <Progress type="circle" percent={allsol ? allsol / 5000 : 0} />
                    </div>
                </div>
                <div className='ml-[10px]' >{t[lang].purchase}</div>
                <div >
                    <div className='bg-[white] min-[1px]:w-[90%]  md:w-[400px] m-auto text-[white] mt-[30px] flex justify-around rounded-[6px]'>
                        <Slider className='basis-4/5' onChange={onChange} defaultValue={0.1} max={20} min={0.1} step={0.1} />
                        <div className='text-[black]  flex items-center' suppressHydrationWarning>{inputValue}</div>
                    </div>
                    {/* <div className='text-center mt-[30px]'><Input defaultValue={""} onChange={(e) => {
                        console.log(e.target.value);
                        setValue(e.target.value);
                    }} className='min-[320px]:w-[90%] md:w-[400px]  ' placeholder={t[lang].iinput} /></div> */}
                    <div className='flex mt-[20px]'> <button className='small-green-button m-auto' onClick={buy}><div className='hover:text-[black]'>{t[lang].iapply}</div></button></div>
                </div>
                {/* <div className='ml-[10px] mt-[30px]'>{t[lang].Claim}</div> */}
                <div className='text-center mt-[40px]'><button className='small-green-button m-auto ' onClick={claim}><div className='hover:text-[black]'>{t[lang].claim_ido}</div></button></div>
                <div className='box-border px-[20px] py-[10px]  border border-solid border-[#76C8FF] mx-[20px] mt-[20px] mb-[20px]'>
                    <div className='flex justify-between'>
                        <div>{t[lang].amountuse}</div>
                        <div suppressHydrationWarning>{bought}SOL</div>
                    </div>
                    <div className='flex justify-between '>
                        <div>{t[lang].yourpurchased}</div>
                        <div suppressHydrationWarning>{(bought * 700000).toFixed(0)} CB</div>
                    </div>
                </div>
            </div>

            {/* <div className={' text-center mt-[20px]' + (owner && (owner === address) ? " " : " hidden")}> <div onClick={start_end} className={' small-green-button text-[white] '}>{t[lang].end_ido}</div></div>
            <div className={' text-center mt-[20px]' + (owner && (owner === address) ? " " : " hidden")}> <div onClick={sweep} className={' small-green-button text-[white] '}>提取募资的eth</div></div> */}
            <Footer></Footer>
            {/* <div className='text-center mt-[30px]'> <div onClick={start} className={' small-green-button text-[white] '}>{t[lang].end_ido}</div></div> */}
        </div >
    )
}
