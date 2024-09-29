use crate::test::utils;
use dep::aztec::oracle::unsafe_rand::unsafe_rand;
use dep::authwit::cheatcodes as authwit_cheatcodes;
use crate::PublicGroups;
use dep::std;

#[test]
unconstrained fn check_admin() {
    let (mut env, group_contract_address, admin, alice) = utils::setup(true);

    env.impersonate(group_contract_address);
    let two = 2;
    assert(two == 2, "two is not two");



    //check the admin is being made correctly
    let check_admin_interface = PublicGroups::at(group_contract_address).admin();
    let result = env.call_public(check_admin_interface);
    assert(admin.to_field() == result, "admin is not the admin");
}