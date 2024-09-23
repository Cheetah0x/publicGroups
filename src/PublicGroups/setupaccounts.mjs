import { createPXEClient, Fr, AztecAddress } from '@aztec/aztec.js';

const { PXE_URL = 'http://localhost:8080' } = process.env;

async function setupAccountsInPXE() {
  const pxe = createPXEClient(PXE_URL);
  
  // Example account details (you should repeat for each account)
  const accounts = [
    {
      address: '0x0e20e49d48db51ac34ac2802829deea4a2f5d3f00fa3aa82f2e736dde8d12c4a',
      secretKey: '0x2153536ff6628eee01cf4024889ff977a18d9fa61d0e414422f7681cf085c281',
      partialAddress: '0x2d12d3b7ab76a977e9949cda9fa3c22372b7963fd6bdeedaeaed07ce979b973d'
    },
    {
      address: '0x2a11eb1c48455fb74f05bcca4e4f7c7ed711a77a007eec3d753f88c657235409',
      secretKey: '0x0aebd1b4be76efa44f5ee655c20bf9ea60f7ae44b9a7fd1fd9f189c7a0b0cdae',
      partialAddress: '0x27c6a0a0e7e09e58cdf40a74a3c381c1658de5746e1fdec1f50a07d1ed8a45b1'
    },
    {
      address: '0x17dd922f9ffb793149efebc21f777126b7976dd101d4e127e3233553c6ad6ab3',
      secretKey: '0x0f6addf0da06c33293df974a565b03d1ab096090d907d98055a8b7f4954e120c',
      partialAddress: '0x0799f069719d7a2d213043f25a37909d1637483f3b942753645df57efce1e4bb'
    }
  ];

  for (let account of accounts) {
    const secretKey = Fr.fromString(account.secretKey);
    const partialAddress = Fr.fromString(account.partialAddress);

    // Register the account
    const completeAddress = await pxe.registerAccount(secretKey, partialAddress);
    console.log(`Registered account with address: ${completeAddress}`);
    console.log(`Registered account with address: ${completeAddress.address.toString()}`);

    
  }
}

setupAccountsInPXE().catch((err) => {
  console.error(`Error setting up accounts: ${err}`);
  process.exit(1);
});
