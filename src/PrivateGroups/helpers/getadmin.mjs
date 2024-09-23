import { AztecAddress } from "@aztec/aztec.js";

export async function getadmin(private_group_contract_admin) {
    console.log("Getting admin account");
    const adminField = await private_group_contract_admin.methods.get_admin().simulate();
    console.log("Result of simulate():", adminField);

    // Convert the Field to a BigInt if necessary
    const adminBigInt = adminField.value ? adminField.value : adminField;
    const adminAddress = AztecAddress.fromBigInt(adminBigInt);
    console.log("The admin of the contract is:", adminAddress.toString());
}