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
import GroupContractJson from "../../contracts/publicgroups/target/publicgroups-PublicGroups.json" assert { type: "json" };

const { PXE_URL = "http://localhost:8080" } = process.env;

async function main() {
  const pxe = createPXEClient(PXE_URL);
  console.log("pxe", pxe);

  const [adminWallet] = await getInitialTestAccountsWallets(pxe);
  const adminAddress = adminWallet.getCompleteAddress();


  const GroupContractArtifact = loadContractArtifact(GroupContractJson);
  const group_contract = await Contract.deploy(
    adminWallet,
    GroupContractArtifact,
    [adminAddress]  // Pass admin address only
  ).send().deployed();
  
  console.log(`Contract deployed at ${group_contract.address.toString()}`);
  

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


