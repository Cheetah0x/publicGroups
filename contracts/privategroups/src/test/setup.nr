
use crate::test::utils;

use dep::aztec::test::{helpers::{cheatcodes, test_environment::TestEnvironment}};
use dep::aztec::protocol_types::storage::map::derive_storage_slot_in_map;
use dep::aztec::note::note_getter::{MAX_NOTES_PER_PAGE, view_notes};
use dep::aztec::note::note_viewer_options::NoteViewerOptions;
use dep::aztec::hash::compute_secret_hash;
use dep::aztec::{
        protocol_types::address::AztecAddress,
        encrypted_logs::encrypted_note_emission::encode_and_encrypt_note_with_keys,
        keys::getters::get_public_keys,
        macros::{storage::storage, events::event, functions::{public, initializer, private, internal}}
    };

use dep::aztec::{oracle::{execution::{get_block_number, get_contract_address}, unsafe_rand::unsafe_rand, storage::storage_read}};
use crate::types::NewAddressNote::NewAddressNote;


use dep::std::println;
use crate::PrivateGroups;

#[test]
unconstrained fn test_environment_setup() {
    let mut env = TestEnvironment::new();
    let account = env.create_account();
    assert(!account.is_zero(), "Account creation failed");
}

#[test]
unconstrained fn test_contract_deployment() {
    let ( env, private_group_contract, admin, alice, bob, shared_secret) = utils::setup();
    assert(!private_group_contract.is_zero(), "Contract not deployed");
}

//test to see the admin is being set correctly
#[test]
unconstrained fn test_admin_set() {
    let ( env, private_group_contract, admin, alice, bob, shared_secret) = utils::setup();
    env.impersonate(admin);

    let admin_slot = PrivateGroups::storage_layout().admin.slot;
    let admin_keys = get_public_keys(admin);

    env.advance_block_by(1);

    // env.add_note(
    //     &mut NewAddressNote::new(admin, shared_secret, admin_keys.npk_m.hash()),
    //     admin_slot,
    //     private_group_contract,
    // );
    // println("Admin note added");
    env.advance_block_by(1);
    let block_number = get_block_number();


    println(f"Admin slot: {admin_slot}");
    let admin_storage_value : NewAddressNote = storage_read(private_group_contract, admin_slot, block_number);

    let admin_address : AztecAddress = admin_storage_value.address;
    println(f"Admin storage value: {admin_storage_value}");
    println("past");
    // let admin_slot = PrivateGroups::admin();
    println(f"Admin slot: {admin_slot}");
    assert(admin_slot != 0, "Admin not set correctly");
}