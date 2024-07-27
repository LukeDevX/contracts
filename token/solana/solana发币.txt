import {
  getAccount,
  getOrCreateAssociatedTokenAccount,
} from "@solana/spl-token";
import { PublicKey } from "@solana/web3.js";
import { keypairIdentity, token, Metaplex } from "@metaplex-foundation/js";

const mintAuthority = pg.wallet.keypair;

const decimals = 9;

let [tokenAccountOwnerPda] = PublicKey.findProgramAddressSync(
  [Buffer.from("token_account_owner_pda")],
  pg.PROGRAM_ID
);
console.log("tokenAccountOwnerPda", tokenAccountOwnerPda.toString());
const metaplex = new Metaplex(pg.connection).use(
  keypairIdentity(pg.wallet.keypair)
);

const createdSFT = await metaplex.nfts().createSft({
  uri: "https://shdw-drive.genesysgo.net/AzjHvXgqUJortnr5fXDG2aPkp2PfFMvu4Egr57fdiite/PirateCoinMeta",
  name: "GDXS",
  symbol: "GDXS",
  sellerFeeBasisPoints: 100,
  updateAuthority: mintAuthority,
  mintAuthority: mintAuthority,
  decimals: decimals,
  tokenStandard: "Fungible",
  isMutable: true,
});