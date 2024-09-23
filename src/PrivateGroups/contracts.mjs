// src/PrivateGroups/contracts.mjs

import { readFileSync } from "fs";
import { AztecAddress, loadContractArtifact } from "@aztec/aztec.js";
// import { PublicGroupsContract } from "../publicgroups/src/artifacts/PublicGroups.ts";
import PrivateGroupContractJson from "../../contracts/privategroups/target/privategroups-PrivateGroups.json" assert { type: 'json' };
import { Contract
 } from "@aztec/aztec.js";

export async function getPrivateGroupContract(wallet) {
  const addresses = JSON.parse(readFileSync('addresses.json'));
  return await Contract.at(
    AztecAddress.fromString(addresses.private_group_contract),
    loadContractArtifact(PrivateGroupContractJson),
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
  