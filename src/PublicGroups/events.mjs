import { getGroupContract } from './contracts.mjs';
import { getInitialTestAccountsWallets } from "@aztec/accounts/testing";
import {
  createPXEClient,
  AztecAddress,
  Contract,
  Fr
} from '@aztec/aztec.js';
import { hexToString } from 'viem';
import GroupContractJson from "../../contracts/publicgroups/target/publicgroups-PublicGroups.json" assert { type: 'json' };
import { readFileSync } from "fs";2



const { PXE_URL = 'http://localhost:8080' } = process.env;

async function main() {
  const pxe = createPXEClient(PXE_URL);
  const { l1ChainId } = await pxe.getNodeInfo();
  console.log(`Connected to chain ${l1ChainId}`);

  const fromBlock = await pxe.getBlockNumber();
  const logFilter = {
    fromBlock,
    toBlock: fromBlock + 1,
  };
  const unencryptedLogs = (await pxe.getUnencryptedLogs(logFilter)).logs;
  console.log("unencryptedLogs", unencryptedLogs);
  // const frombuffer = Fr.fromBuffer(unencryptedLogs[0].log.data);
  // const fromhex = hexToString(frombuffer);
  console.log("frombuffer", frombuffer);
  console.log("fromhex", fromhex);
  const asciiLogs = unencryptedLogs.map(extendedLog => extendedLog.log.data.toString('ascii'));
  console.log("asciiLogs", asciiLogs);

  const readableLogs = unencryptedLogs.map(log => {
    const data = log.log.data.toString('utf-8'); // Decode data as UTF-8 string
    let parsedData;
    try {
      parsedData = JSON.parse(data); // Try parsing as JSON
    } catch (e) {
      parsedData = data; // Fallback to raw data if not JSON
    }
    return {
      ...log,
      data: parsedData,
    };
  });

  

  console.log("readableLogs", readableLogs);

//   // Initialize the GroupContract instance
//   const addresses = JSON.parse(readFileSync('addresses.json'));
//   const groupContract = Contract.at(AztecAddress.fromString(addresses.group), GroupContractJson, pxe);

//   // Example of calling a method on the GroupContract
//   const groupInfo = await groupContract.methods.getGroupInfo().simulate();
//   console.log("Group Info:", groupInfo);
}




main();