import { AztecAddress } from "@aztec/aztec.js";

export async function getnewsharedsecretadmin(private_group_contract_admin, memberaddress) {
    const newSharedSecretField = await private_group_contract_admin.methods.get_shared_secret(memberaddress).simulate();
    console.log("Result of simulate():", newSharedSecretField);

    const newSharedSecretString = newSharedSecretField.toString();
    console.log("The new shared secret of the contract is:", newSharedSecretString);
}

export async function getnewsharedsecretalice(private_group_contract_alice, memberaddress) {
    const newSharedSecretField = await private_group_contract_alice.methods.get_shared_secret(memberaddress).simulate();
    console.log("Result of simulate():", newSharedSecretField);

    const newSharedSecretString = newSharedSecretField.toString();
    console.log("The new shared secret of the contract is:", newSharedSecretString);
}

export async function getnewsharedsecretbob(private_group_contract_bob, memberaddress) {
    const newSharedSecretField = await private_group_contract_bob.methods.get_shared_secret(memberaddress).simulate();
    console.log("Result of simulate():", newSharedSecretField);

    const newSharedSecretString = newSharedSecretField.toString();
    console.log("The new shared secret of the contract is:", newSharedSecretString);
}


//interesting, this is showing the shared secret to be the same for everyone
//guess this is ok for now, if you know the secret you can decrypt everything??
