// src/deploy.mjs
import { writeFileSync } from "fs";
import { getSchnorrAccount } from '@aztec/accounts/schnorr'; 
import {
  Contract,
  loadContractArtifact,
  createPXEClient,
  Fr, 
  AztecAddress,
} from "@aztec/aztec.js";
import { toHex } from 'viem';
import { getInitialTestAccountsWallets, getDeployedTestAccountsWallets } from "@aztec/accounts/testing";
import PrivateGroupContractJson from "../../contracts/privategroups/target/privategroups-PrivateGroups.json" assert { type: "json" };
const { PXE_URL = "http://localhost:8080" } = process.env;

async function main() {
  const pxe = createPXEClient(PXE_URL);
  console.log("pxe", pxe);

  const wallets = await getInitialTestAccountsWallets(pxe);

    const adminWallet = wallets[0]; 
    const aliceWallet = wallets[1];
    const bobWallet = wallets[2];

    const adminCompleteAddress = adminWallet.getCompleteAddress();
    const adminAddress = adminWallet.getAddress();
    const aliceAddress = aliceWallet.getAddress();
    const bobAddress = bobWallet.getAddress();
    
    // const groupMembers = [adminAddress,aliceAddress, bobAddress, AztecAddress.ZERO,AztecAddress.ZERO];
    const groupMembers = [adminAddress,aliceAddress];
    // const groupMembers = [ AztecAddress.ZERO, AztecAddress.ZERO, AztecAddress.ZERO, AztecAddress.ZERO];
    // const groupMembers = AztecAddress.ZERO
    // const groupMembers = adminAddress;
    console.log("groupMembers", groupMembers);


    //has to be below 32 characters, else will need to change to the field compressed types
    const sharedSecret = toHex("999");

    const PrivateGroupContractArtifact = loadContractArtifact(PrivateGroupContractJson);

    const private_group_contract = await Contract.deploy(
        adminWallet,
        PrivateGroupContractArtifact,
        [adminCompleteAddress, groupMembers, sharedSecret]
      ).send();
      
    console.log('Transaction sent. Waiting for confirmation...');

    const deployedContract = await private_group_contract.deployed();
    console.log(`Contract deployed at ${deployedContract.address.toString()}`);


  

  console.log(
    `Private group contract deployed at ${private_group_contract.address.toString()}`
  );

  const addresses = { private_group_contract: private_group_contract.address.toString() };
  writeFileSync("addresses.json", JSON.stringify(addresses, null, 2));
}

main().catch((err) => {
  console.error(`Error in deployment script: ${err}`);
  process.exit(1);
});
