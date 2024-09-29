use dep::aztec::{
    hash::compute_secret_hash, prelude::AztecAddress,
    test::helpers::{cheatcodes, test_environment::TestEnvironment},
    protocol_types::storage::map::derive_storage_slot_in_map,
    oracle::{execution::{get_block_number, get_contract_address}, unsafe_rand::unsafe_rand, storage::storage_read}
};

use crate::PublicGroups;
use dep::std;

unconstrained pub fn setup(with_account_contracts: bool) -> (&mut TestEnvironment, AztecAddress, AztecAddress, AztecAddress) {
    let mut env = TestEnvironment::new();

    std::println("Creating accounts");

    let (admin, alice) = if with_account_contracts {
        let admin = env.create_account_contract(1);
        let alice = env.create_account_contract(2);
        let _auth_registry = env.deploy("./@auth_registry_contract", "AuthRegistry").without_initializer();
        std::println("Created account contracts for admin and alice");
        std::println(f"Admin contract address: {admin}");
        std::println(f"Alice contract address: {alice}");
        (admin, alice)
    } else {
        let admin = env.create_account();
        let alice = env.create_account();
        std::println("Created simple accounts for admin and alice");
        std::println(f"Admin address: {admin}");
        std::println(f"Alice address: {alice}");
        (admin, alice)
    };

    std::println("Impersonating admin");
    env.impersonate(admin);

    let initializer_call_interface = PublicGroups::interface().constructor(admin);
    std::println("Deploying PublicGroups contract");
    let group_contract = env.deploy_self("PublicGroups").with_public_initializer(initializer_call_interface);

    std::println("PublicGroups contract deployed");
    let group_contract_address = group_contract.to_address();

    env.advance_block_by(1);

    std::println("Returning setup data");

    (&mut env, group_contract_address, admin, alice)
}

unconstrained pub fn add_to_group(with_account_contracts: bool) -> (&mut TestEnvironment, AztecAddress, AztecAddress, AztecAddress) {
    let (env, group_contract_address, admin, alice) = setup(with_account_contracts);
    let add_group_members = PublicGroups::at(group_contract_address).add_to_group(alice, true);
    env.call_public(add_group_members);
    env.advance_block_by(2);

    std::println("Added Alice to the group");

    (env, group_contract_address, admin, alice)
}