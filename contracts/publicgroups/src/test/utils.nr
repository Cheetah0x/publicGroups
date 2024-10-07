use dep::aztec::{
    hash::compute_secret_hash, prelude::AztecAddress,
    test::helpers::{cheatcodes, test_environment::TestEnvironment},
    // protocol_types::storage::map::derive_storage_slot_in_map,
    oracle::{execution::{get_block_number, get_contract_address}, unsafe_rand::unsafe_rand, storage::storage_read}
};

use crate::SplitwisePub;


pub fn setup() -> (&mut TestEnvironment, AztecAddress, AztecAddress) {
    let mut env = TestEnvironment::new();

    let admin = env.create_account();

    let initializer_call_interface = SplitwisePub::interface().constructor(admin);
    let group_contract = env.deploy_self("SplitwisePub").with_public_initializer(initializer_call_interface);
    // std::println(voting_contract);
    (&mut env, group_contract.to_address(), admin)
}
// unconstrained pub fn add_to_group(with_account_contracts: bool) -> (&mut TestEnvironment, AztecAddress, AztecAddress, AztecAddress) {
//     let (env, group_contract_address, admin, alice) = setup(with_account_contracts);
//     let add_group_members = PublicGroups::at(group_contract_address).add_to_group(alice, true);
//     env.call_public(add_group_members);
//     env.advance_block_by(2);

//     std::println("Added Alice to the group");

//     (env, group_contract_address, admin, alice)
// }