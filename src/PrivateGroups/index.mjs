// src/index.mjs

import { getPrivateGroupContract } from './contracts.mjs';
import { getInitialTestAccountsWallets } from "@aztec/accounts/testing";
import {
  createPXEClient,
  AztecAddress,
} from '@aztec/aztec.js';
import { getadmin } from './helpers/getadmin.mjs';
import { getsecret, getsecretalice, getsecretbob } from './helpers/getsecret.mjs';
import { getnewsharedsecretadmin, getnewsharedsecretalice, getnewsharedsecretbob } from './helpers/getnewsharedsecret.mjs';
import { getGroupMemberAdmin, getGroupMemberAlice, getGroupMemberBob, getGroupMemberFail } from './helpers/getGroupembers.mjs';
import { set_Initial_Balance_Admin_Alice, get_Initial_Balance_Admin_Alice,  make_Payment_Alice_Admin, get_alice_debt } from './helpers/Payments.mjs';
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
    const aliceWallet = wallets[1];
    const bobWallet = wallets[2];

    const adminAddress = adminWallet.getAddress();
    console.log("adminAddress", adminAddress);
    const aliceAddress = aliceWallet.getAddress();
    const bobAddress = bobWallet.getAddress();

    //private group contract instances for all of the wallets
    const private_group_contract_admin = await getPrivateGroupContract(adminWallet);
    const private_group_contract_alice = await getPrivateGroupContract(aliceWallet);
    const private_group_contract_bob = await getPrivateGroupContract(bobWallet);


    // do not have bob as a group member, his stuff should fail

    const groupMembers = [adminAddress,aliceAddress];


    //get the admin of the contract
    await getadmin(private_group_contract_admin);

    //get the shared secret of the contract, old verion
    // await getsecret(private_group_contract_admin);
    // await getsecretalice(private_group_contract_alice);
    // await getsecretbob(private_group_contract_bob);

    //get the new shared secret of the contract
    await getnewsharedsecretadmin(private_group_contract_admin, adminAddress);
    await getnewsharedsecretalice(private_group_contract_alice, aliceAddress);
    // await getnewsharedsecretbob(private_group_contract_bob, bobAddress);

    //get the group members of the contract
    await getGroupMemberAdmin(private_group_contract_admin, adminAddress);
    await getGroupMemberAlice(private_group_contract_alice, aliceAddress);
    // await getGroupMemberBob(private_group_contract_bob, bobAddress);
    // await getGroupMemberFail(private_group_contract_admin, aliceAddress); this one fails, this is good

    //let's see if admin can see alice address now
    console.log("admin fetching alice address");
    await getGroupMemberAdmin(private_group_contract_admin, aliceAddress);

    //set initial balance of admin and alice
    const amount = 100;

    await set_Initial_Balance_Admin_Alice(private_group_contract_admin, adminAddress, aliceAddress, amount);
    //get initial balance of admin and alice

    await get_Initial_Balance_Admin_Alice(private_group_contract_admin, adminAddress, aliceAddress);
    await get_alice_debt(private_group_contract_alice, adminAddress, aliceAddress);
    // await get_Balance_Alice_Admin(private_group_contract_admin, aliceAddress, adminAddress);
    // console.log("getting balance of how much alice owes admin");
    // await get_Balance_Alice_Admin(private_group_contract_alice, aliceAddress, adminAddress);

    //make a payment from alice to admin

    const amount1 = 50;
    await make_Payment_Alice_Admin(private_group_contract_alice, adminAddress, aliceAddress, amount1);
    await get_Initial_Balance_Admin_Alice(private_group_contract_admin, adminAddress, aliceAddress);
    await get_alice_debt(private_group_contract_alice, adminAddress, aliceAddress);
    //get balance of alice and admin

    // await get_Initial_Balance_Admin_Alice(private_group_contract_admin, adminAddress, aliceAddress);

  }
}

main();


