import { AztecAddress } from "@aztec/aztec.js";

export async function getGroupMemberAdmin(private_group_contract_admin, group_member) {
    const groupMemberField = await private_group_contract_admin.methods.get_group_members(group_member).simulate();
    console.log("Result of group members admin():", groupMemberField);

    // const groupMemberAddress = AztecAddress.fromBigInt(groupMemberField);
    // console.log("The group member of the contract is:", groupMemberAddress.toString());
}

export async function getGroupMemberAlice(private_group_contract_alice, group_member) {
    const groupMemberField = await private_group_contract_alice.methods.get_group_members(group_member).simulate();
    console.log("Result of simulate():", groupMemberField);

    // const groupMemberAddress = AztecAddress.fromBigInt(groupMemberField);
    // console.log("The group member of the contract is:", groupMemberAddress.toString());
}

export async function getGroupMemberBob(private_group_contract_bob, group_member) {
    const groupMemberField = await private_group_contract_bob.methods.get_group_members(group_member).simulate();
    console.log("Result of simulate():", groupMemberField);

    // const groupMemberAddress = AztecAddress.fromBigInt(groupMemberField);
//     console.log("The group member of the contract is:", groupMemberAddress.toString());
}

//this should fail
export async function getGroupMemberFail(private_group_contract_admin, group_member) {
    const groupMemberField = await private_group_contract_admin.methods.get_group_members(group_member).simulate();
    console.log("Result of simulate():", groupMemberField);

    // const groupMemberAddress = AztecAddress.fromBigInt(groupMemberField);
    // console.log("The group member of the contract is:", groupMemberAddress.toString());
    //nice this fails, this is good
}

