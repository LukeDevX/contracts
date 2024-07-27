import { beginCell, Cell, Dictionary } from "@ton/ton";
import { sha256_sync } from "@ton/crypto";


// name	集合名称
// description	集合描述
// image	将显示为头像的图片链接。支持的链接格式：https、ipfs、TON Storage。
// cover_image	将显示为集合封面图片的图片链接。
// social_links	项目社交媒体配置文件的链接列表。使用不超过10个链接。
export interface NftContent {
    name?: string,
    description?: string,
    image?: string,
    imageData?: Buffer,
    cover_image?: string,	//将显示为集合封面图片的图片链接。
    social_links?: []	//项目社交媒体配置文件的链接列表。使用不超过10个链接。
}
export function nftContentToInternal(content: NftContent) {
    return {
        name: content.name,
        description: content.description,
        image: content.image,
        image_data: content.imageData?.toString('base64'),
    };
}

// const OFFCHAIN_CONTENT_PREFIX = 0x01;
// const string_first = "https://s.getgems.io/nft-staging/c/628f6ab8077060a7a8d52d63/meta.json"; // Change to the content URL you prepared
// let newContent = beginCell().storeInt(OFFCHAIN_CONTENT_PREFIX, 8).storeStringRefTail(string_first).endCell();
export async function createNftCollectionContent(content: { collectionContent?: NftContent, nftCollectionMetaUrl?: string, commonContent: string }) {
    return beginCell()
        .storeRef(content.nftCollectionMetaUrl != undefined ? internalOffchainContentToCell(content.nftCollectionMetaUrl!!) : internalOnchainContentToCell(nftContentToInternal(content.collectionContent!!)))
        .storeRef(beginCell().storeStringTail(content.commonContent))
        .endCell()
}
export function internalOnchainContentToCell(internal: Record<string, string | number | undefined>): Cell {
    const dict = Dictionary.empty(Dictionary.Keys.Buffer(32), Dictionary.Values.Cell());
    for (const k in internal) {
        if ((internal as any)[k] === undefined) {
            continue;
        }
        const b = beginCell();
        if (k === 'image_data') {
            const chunks = Dictionary.empty(Dictionary.Keys.Uint(32), Dictionary.Values.Cell());
            const buf = Buffer.from((internal as any)[k], 'base64');
            for (let i = 0; i * 127 < buf.length; i++) {
                chunks.set(i, beginCell().storeBuffer(buf.subarray(i * 127, (i + 1) * 127)).endCell());
            }
            b.storeUint(1, 8).storeDict(chunks).endCell();
        } else {
            b.storeUint(0, 8).storeStringTail((internal as any)[k].toString());
        }
        dict.set(sha256_sync(k), b.endCell());
    }
    return beginCell().storeUint(0, 8).storeDict(dict).endCell();
}
function internalOffchainContentToCell(url: string) {
    return beginCell()
        .storeUint(0x01, 8)
        .storeStringTail(url)
        .endCell();
}

