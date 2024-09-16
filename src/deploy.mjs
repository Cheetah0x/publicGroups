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
import { getInitialTestAccountsWallets, getDeployedTestAccountsWallets } from "@aztec/accounts/testing";
import GroupContractJson from "../publicgroups/target/publicgroups-PublicGroups.json" assert { type: "json" };

const { PXE_URL = "http://localhost:8080" } = process.env;

async function main() {
  const pxe = createPXEClient(PXE_URL);
  console.log("pxe", pxe);
  // const deployedAccounts = await getDeployedTestAccountsWallets(pxe);
  // console.log("deployedAccounts", deployedAccounts);
  // const accounts = await getInitialTestAccountsWallets(pxe);
  // console.log("accounts", accounts);
  const [adminWallet] = await getInitialTestAccountsWallets(pxe);
  const adminAddress = adminWallet.getCompleteAddress();
  console.log("admin", adminAddress.toString());

  //register the account in the pxe

  // // Secret key and partial address from the account information
  // const secretKey = Fr.fromString('0x2153536ff6628eee01cf4024889ff977a18d9fa61d0e414422f7681cf085c281');
  // const partialAddress = Fr.fromString('0x00d213e34441cf9c29a4b5c87da74337a8c0dc929dc79ec291fa88c97a98b674');

  //   // Register the account with the PXE service
  //   const newAccount = await pxe.registerAccount(secretKey, partialAddress);
  //   console.log('Account registered with complete address:', newAccount.address.toString());
  //   const newAccountAddress = newAccount.address.toString();



  const GroupContractArtifact = loadContractArtifact(GroupContractJson);
  const group_contract = await Contract.deploy(
    adminWallet,
    GroupContractArtifact,
    [adminAddress]  // Pass admin address only
  ).send();
  
  // Wait for deployment confirmation and retrieve the deployed contract instance
  const deployedContract = await group_contract.deployed();
  console.log(`Contract deployed at ${deployedContract.address.toString()}`);
  

  console.log(
    `Group contract deployed at ${group_contract.address.toString()}`
  );

  const addresses = { group_contract: group_contract.address.toString() };
  writeFileSync("addresses.json", JSON.stringify(addresses, null, 2));
}

main().catch((err) => {
  console.error(`Error in deployment script: ${err}`);
  process.exit(1);
});



async function createSchnorrAccount() {
  const pxe = createPXEClient(PXE_URL);
  const secretKey = Fr.random(); // Generate a random secret key
  
  const schnorrAccount = await getSchnorrAccount(pxe, secretKey);
  console.log("Schnorr account created:", schnorrAccount);
  const schnorrAddress = schnorrAccount.getAddress();
  console.log("Schnorr address:", schnorrAddress);

  const schnorrWallet = await getSchnorrWallet(pxe, schnorrAddress, secretKey);

  
  // Register the Schnorr account
  const completeAddress = await pxe.registerAccount(secretKey, schnorrAccount);
  console.log("Schnorr account registered with address:", completeAddress.address.toString());
  return completeAddress;
}