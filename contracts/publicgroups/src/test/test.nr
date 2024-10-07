use crate::test::utils;

use dep::aztec::test::{helpers::{cheatcodes, test_environment::TestEnvironment}};
use dep::aztec::protocol_types::storage::map::derive_storage_slot_in_map;
use dep::aztec::note::note_getter::{MAX_NOTES_PER_PAGE, view_notes};
use dep::aztec::note::note_viewer_options::NoteViewerOptions;
use dep::aztec::hash::compute_secret_hash;

use dep::aztec::{oracle::{execution::{get_block_number, get_contract_address}, unsafe_rand::unsafe_rand, storage::storage_read}};

use crate::SplitwisePub;

#[test]
unconstrained fn test_environment_setup() {
    let mut env = TestEnvironment::new();
    let account = env.create_account();
    assert(account.is_zero(), "Account creation failed");
}


#[test]
unconstrained fn test_initializer() {
    let (_, group_contract_address, admin) = utils::setup();

    let block_number = get_block_number();
    let admin_slot = SplitwisePub::storage_layout().admin.slot;
    let admin_storage_value = storage_read(group_contract_address, admin_slot, block_number);
    assert(admin_storage_value == admin, "Vote ended should be false");
}


// #[test]
// unconstrained fn check_admin() {
//     let (mut env, group_contract_address, admin, alice) = utils::setup(true);

//     env.impersonate(group_contract_address);
//     let two = 2;
//     assert(two == 2, "two is not two");



//     //check the admin is being made correctly
//     let check_admin_interface = PublicGroups::at(group_contract_address).admin();
//     let result = env.call_public(check_admin_interface);
//     assert(admin.to_field() == result, "admin is not the admin");
// }

// #[test]
// unconstrained fn add_group_member_success() {

//     let (mut env, group_contract_address, admin, alice) = utils::setup(true);

//     std::println("Impersonating admin");
//     env.impersonate(admin);

//     std::println("Adding Alice to the group");
//     let add_alice_interface = PublicGroups::at(group_contract_address).add_to_group(alice, true);
//     env.call_public(add_alice_interface);
//     std::println("Call to add_to_group completed");

//     std::println("Checking if Alice is in the group");
//     let check_membership_interface = PublicGroups::at(group_contract_address).in_group(alice);
//     let is_member = env.call_public(check_membership_interface);
//     std::println(f"Alice membership status: {is_member}");
//     assert(is_member == true, "Alice is not a member");
// }
