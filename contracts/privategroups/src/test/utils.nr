use dep::aztec::{
    hash::compute_secret_hash, prelude::AztecAddress,
    test::helpers::{cheatcodes, test_environment::TestEnvironment},
    // protocol_types::storage::map::derive_storage_slot_in_map,
    oracle::{execution::{get_block_number, get_contract_address}, unsafe_rand::unsafe_rand, storage::storage_read}
};
use dep::std::println;
use crate::PrivateGroups;

unconstrained pub fn setup() -> (&mut TestEnvironment, AztecAddress, AztecAddress, AztecAddress, AztecAddress, Field) {
    let mut env = TestEnvironment::new();
    env.private();

    let admin = env.create_account();
    let alice = env.create_account();
    let bob = env.create_account();
    let ZERO_ADDRESS: AztecAddress = AztecAddress::from_field(0x0000000000000000000000000000000000000000000000000000000000000000);

    env.advance_block_by(1);
    //size 10 array, 8 zeroaddresses, admin, alice
    // let group_members = [admin, alice, ZERO_ADDRESS, ZERO_ADDRESS, ZERO_ADDRESS, ZERO_ADDRESS, ZERO_ADDRESS, ZERO_ADDRESS, ZERO_ADDRESS, ZERO_ADDRESS];
    let group_members = [admin, alice];

    let shared_secret = 80;
    env.advance_block_by(1);

    env.impersonate(admin);

    let initializer_call_interface = PrivateGroups::interface().constructor(
        admin,
        group_members,
        shared_secret
    );
    // env.call_private_void(initializer_call_interface);
    env.advance_block_by(1);

    env.impersonate(admin);
    let private_group_contract = env.deploy_self("PrivateGroups").with_private_initializer(initializer_call_interface);
    // env.call_private_void(private_group_contract); // this is broken, need to look at this

    // let my_private_initializer_call_interface = PrivateGroups::interface().constructor(
    //     admin,
    //     group_members,
    //     shared_secret
    // );
    // let my_contract_instance = deployer.with_private_initializer(my_private_initializer_call_interface);


    env.advance_block_by(1);

    println("Private group contract deployed");

    (&mut env, private_group_contract.to_address(), admin, alice, bob, shared_secret)
}