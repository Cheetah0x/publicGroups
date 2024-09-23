import { AztecAddress } from "@aztec/aztec.js";

export async function getsecret(private_group_contract_admin) {
    const secretField = await private_group_contract_admin.methods.get_shared_secret().simulate();
    console.log("Result of simulate():", secretField);

    //this is returning a bigint, need to convert to a string, will need to thing about this.
    const secretString = secretField.toString();
    console.log("The secret of the contract is:", secretString);

    
}


export async function getsecretalice(private_group_contract_alice) {
    const secretField = await private_group_contract_alice.methods.get_shared_secret().simulate();
    console.log("Result of simulate():", secretField);
    //should fail, they are not the admin so cannot decrypt the message
}

export async function getsecretbob(private_group_contract_bob) {
    const secretField = await private_group_contract_bob.methods.get_shared_secret().simulate();
    console.log("Result of simulate():", secretField);
}