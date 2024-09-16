// src/index.mjs

import { getGroupContract } from './contracts.mjs';
import { getInitialTestAccountsWallets } from "@aztec/accounts/testing";
import {
  createPXEClient,
  AztecAddress,
} from '@aztec/aztec.js';

const { PXE_URL = 'http://localhost:8080' } = process.env;

async function main() {
  const pxe = createPXEClient(PXE_URL);
  const { l1ChainId } = await pxe.getNodeInfo();
  console.log(`Connected to chain ${l1ChainId}`);

  // Get wallets
  // const registeredAccounts = await pxe.getRegisteredAccounts();
  // console.log("registeredAccounts", registeredAccounts);
  const wallets = await getInitialTestAccountsWallets(pxe);

  if (wallets.length > 0) {
    const adminWallet = wallets[0]; 
    // console.log("adminWallet:", adminWallet);
    const aliceWallet = wallets[1];
    // console.log("aliceWallet:", aliceWallet);
    const bobWallet = wallets[2];
    // console.log("bob wallet", bobWallet);

    const adminAddress = adminWallet.getAddress();
    console.log("adminAddress", adminAddress);
    const aliceAddress = aliceWallet.getAddress();
    console.log("aliceAddress", aliceAddress);
    const bobAddress = bobWallet.getAddress();
    console.log("bobAddress", bobAddress);
    
    console.log("Getting group contract");
    const group_contract_admin = await getGroupContract(adminWallet);
    // console.log("group_contract created", group_contract_admin);

    const group_contract_alice = await getGroupContract(aliceWallet);
    // console.log("group_contract_alice created", group_contract_alice);

    const group_contract_bob = await getGroupContract(bobWallet);
    // console.log("group_contract_bob created", group_contract_bob);

    // Get the admin of the contract
    await getadmin(group_contract_admin);

    // // Add alice to the group
    // she should already be in the group so going to comment out
    await add_to_group(group_contract_admin, aliceAddress);

    await is_admin_part_of_the_group(group_contract_admin, adminAddress);
    await is_alice_part_of_group(group_contract_admin, aliceAddress)
    await is_bob_part_of_group(group_contract_admin, bobAddress)

    //add bob to the group

    await add_to_group(group_contract_admin, bobAddress);
    await is_bob_part_of_group(group_contract_admin, bobAddress)

    //make alice owe admin 100
    await increase_balance_alice_admin(group_contract_admin, adminAddress, aliceAddress, 500);
    //makes the balance that alice owes admin 100


    // admin owes alice 50
    await increase_balance_admin_alice(group_contract_alice, aliceAddress, adminAddress, 100);


    //alice pays admin 20
    await make_payment_alice_admin(group_contract_alice, adminAddress, aliceAddress, 100);

    await get_balance_alice_admin(group_contract_admin, adminAddress, aliceAddress);
  } else {
    console.log("No wallets found");
  }
}

main().catch(err => {
  console.error(`Error in app: ${err}`);
  process.exit(1);
});

// Function to get the admin of the contract
async function getadmin(group_contract_admin) {
  console.log("Getting account admin");
  const adminField = await group_contract_admin.methods.admin().simulate();
  console.log("Result of simulate():", adminField);

   // Convert the Field to a BigInt if necessary
   const adminBigInt = adminField.value ? adminField.value : adminField;
   const adminAddress = AztecAddress.fromBigInt(adminBigInt);
   console.log("The admin of the contract is:", adminAddress.toString());
}

async function is_admin_part_of_the_group(group_contract_admin, adminAddress) {
    //with the admin instance this should return true
    const result = await group_contract_admin.methods.in_group(adminAddress).simulate();
    console.log("admin_part_of_group", result)
}

async function is_alice_part_of_group(group_contract_admin, aliceAddress) {
  const result = await group_contract_admin.methods.in_group(aliceAddress).simulate();
    console.log("alice part of the gorup", result);
};

async function is_bob_part_of_group(group_contract_admin, bobAddress) {
  const result = await group_contract_admin.methods.in_group(bobAddress).simulate();
    console.log("bob part of the gorup", result);
};



// Function to add a user to the group
async function add_to_group(group_contract_admin, aliceAddress) {
  const tx = group_contract_admin.methods.add_to_group(aliceAddress, true).send();
  console.log(`Sent add_to_group transaction: ${await tx.getTxHash()}`);
  const receipt = await tx.wait();
  console.log(`Transaction mined in block ${receipt.blockNumber}`);
}



//so far we have added alice to the group with the admin. 
//time to set the balances between the people. 

//between admin and alice, admin 

async function increase_balance_alice_admin(group_contract_admin, adminAddress, aliceAddress, amount) {
  const tx = group_contract_admin.methods.set_balance(adminAddress, aliceAddress, amount).send();
  console.log(`Sent set_balance transaction: ${await tx.getTxHash()}`);
  const receipt = await tx.wait();
  console.log(`Transaction mined in block ${receipt.blockNumber}`);

  await get_balance_alice_admin(group_contract_admin, adminAddress, aliceAddress);

}

async function increase_balance_admin_alice(group_contract_alice, aliceAddress, adminAddress, amount) {
  const tx = group_contract_alice.methods.set_balance(aliceAddress, adminAddress, amount).send();
  console.log(`Sent set_balance transaction: ${await tx.getTxHash()}`);
  const receipt = await tx.wait();
  console.log(`Transaction mined in block ${receipt.blockNumber}`);

  await get_balance_alice_admin(group_contract_alice, adminAddress, aliceAddress);

}



async function get_balance_alice_admin(group_contract_admin, adminAddress, aliceAddress) {
  const alice_to_admin = await group_contract_admin.methods.balance(adminAddress, aliceAddress).simulate();
  console.log("alice to admin", alice_to_admin);

  const admin_to_alice = await group_contract_admin.methods.balance(aliceAddress, adminAddress).simulate();
  console.log("admin to alice", admin_to_alice);

}



//now i need to check the balances
async function make_payment_alice_admin(group_contract_alice, aliceAddress, adminAddress, amount) {
  const tx = group_contract_alice.methods.make_payment(aliceAddress, adminAddress, amount).send();
  console.log(`Sent make_payment transaction: ${await tx.getTxHash()}`);
  const receipt = await tx.wait();
  console.log(`Transaction mined in block ${receipt.blockNumber}`);
}