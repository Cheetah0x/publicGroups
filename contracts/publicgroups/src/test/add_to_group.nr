// File: src/test/add_to_group.nr

use crate::test::utils;
use dep::aztec::oracle::unsafe_rand::unsafe_rand;
use dep::authwit::cheatcodes as authwit_cheatcodes;
use crate::PublicGroups;
use dep::std;

#[test]
unconstrained fn add_group_member_success() {
    std::println("setting up contract");
    let (mut env, group_contract_address, admin, alice) = utils::setup(true);

    env.impersonate(admin);

    let add_alice_interface = PublicGroups::at(group_contract_address).add_to_group(alice, true);
    env.call_public(add_alice_interface);

    // // Verify that Alice is now in the group
    let check_membership_interface = PublicGroups::at(group_contract_address).in_group(alice);
    let is_member = env.call_public(check_membership_interface);
    assert(is_member == true, "Alice is not member");
}