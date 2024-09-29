// File: src/test/add_to_group.nr

use crate::test::utils;
use dep::aztec::oracle::unsafe_rand::unsafe_rand;
use dep::authwit::cheatcodes as authwit_cheatcodes;
use crate::PublicGroups;
use dep::std;

#[test]
unconstrained fn add_group_member_success() {

    let (mut env, group_contract_address, admin, alice) = utils::setup(true);

    std::println("Impersonating admin");
    env.impersonate(admin);

    std::println("Adding Alice to the group");
    let add_alice_interface = PublicGroups::at(group_contract_address).add_to_group(alice, true);
    env.call_public(add_alice_interface);
    std::println("Call to add_to_group completed");

    std::println("Checking if Alice is in the group");
    let check_membership_interface = PublicGroups::at(group_contract_address).in_group(alice);
    let is_member = env.call_public(check_membership_interface);
    std::println(f"Alice membership status: {is_member}");
    assert(is_member == true, "Alice is not a member");
}
