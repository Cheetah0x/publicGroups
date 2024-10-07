// src/deploy.mjs

import { getSchnorrAccount } from '@aztec/accounts/schnorr'; 
import {
  Fr, 
  GrumpkinScalar,
} from "@aztec/aztec.js";

export async function newAccount(pxe) {
    const walletSecret = Fr.random();
    const walletSigningPrivateKey = GrumpkinScalar.random();
    
    // Await the wallet setup
    const wallet = await getSchnorrAccount(pxe, walletSecret, walletSigningPrivateKey).waitSetup();
    
    // Get the wallet address and complete address
    const walletCompleteAddress = wallet.getCompleteAddress();
    const walletAddress = wallet.getAddress();
    
    // Return the wallet, wallet address, and wallet complete address
    return {
        wallet,
        walletAddress,
        walletCompleteAddress
    };
}
