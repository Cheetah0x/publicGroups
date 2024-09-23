// src/contracts.mjs

import { readFileSync } from "fs";
import { AztecAddress, loadContractArtifact } from "@aztec/aztec.js";
// import { PublicGroupsContract } from "../publicgroups/src/artifacts/PublicGroups.ts";
import GroupContractJson from "../../contracts/publicgroups/target/publicgroups-PublicGroups.json" assert { type: 'json' };
import { Contract
 } from "@aztec/aztec.js";

export async function getGroupContract(wallet) {
  const addresses = JSON.parse(readFileSync('addresses.json'));
  return await Contract.at(
    AztecAddress.fromString(addresses.group_contract),
    loadContractArtifact(GroupContractJson),
    wallet
  );
}

// //this is the instance for an address
// export async function getGroupContract(wallet) {
//   const addresses = JSON.parse(readFileSync('addresses.json'));
//   return await PublicGroupsContract.at(
//     AztecAddress.fromString(addresses.group_contract),
//     wallet
//   );
// }
  