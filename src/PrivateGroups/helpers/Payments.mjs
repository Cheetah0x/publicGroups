import { AztecAddress } from "@aztec/aztec.js";

export async function set_Initial_Balance_Admin_Alice(private_group_contract_admin, admin_address, alice_address, amount) {
    console.log("setting balance of admin and alice");
    const tx = await private_group_contract_admin.methods.set_balance(admin_address, alice_address, amount).send();
    console.log("tx sent", tx);
}

export async function get_Initial_Balance_Admin_Alice(private_group_contract_admin, admin_address, alice_address) {
    console.log("getting balance of admin and alice");
    const balance = await private_group_contract_admin.methods.read_balance_credit(admin_address, alice_address).simulate();
    console.log("balance", balance);
}


export async function get_alice_debt(private_group_contract_alice, admin_address, alice_address) {
    console.log("getting alice's debt to admin");
    const debt = await private_group_contract_alice.methods.read_balance_debt(admin_address, alice_address).simulate();
    console.log("debt", debt);
}

//next one is to see if alice can read how much she owes
// export async function get_Balance_Alice_Admin(private_group_contract_alice, admin_address, alice_address) {
//     console.log("getting balance of alice and admin");
//     const balance = await private_group_contract_alice.methods.read_balance(admin_address, admin_address).simulate();
//     console.log("balance", balance);
// }

//make a payment from alice to admin
export async function make_Payment_Alice_Admin(private_group_contract_alice, admin_address, alice_address, amount) {
    console.log("making payment from alice to admin");
    const tx = await private_group_contract_alice.methods.make_payment(admin_address, alice_address, amount).send();
    console.log("tx sent", tx);
}



export async function setBalanceBetweenTwoMembers(contract_instance, creditor, debtor, amount) {
    console.log("new balance for creditor and debtor");
    const tx = await contract_instance.methods.new_set_balance(creditor, debtor, amount).send();
    console.log("tx sent", tx);
}