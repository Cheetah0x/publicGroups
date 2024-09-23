contract GroupFactory {
    use dep::aztec::{prelude::{AztecAddress, PublicMutable, Map}};
    use dep::std::hash::pedersen_hash;
    use crate::PublicGroups; 

    #[aztec(storage)]
    struct Storage {
        admin: PublicMutable<AztecAddress>,
        deployer_group_counts: Map<AztecAddress, PublicMutable<u64>>,         
        deployer_group_contracts: Map<Field, PublicMutable<AztecAddress>>,     
    }

    #[aztec(public)]
    #[aztec(initializer)]
    fn constructor(admin: AztecAddress) {
        assert(!admin.is_zero(), "Invalid admin address");
        storage.admin.write(admin);
    }

    #[aztec(public)]
    fn create_group(group_admin: AztecAddress) -> AztecAddress {
        let deployer = context.msg_sender();
        assert(!group_admin.is_zero(), "Invalid group admin address");

        // Deploy a new instance of the PublicGroups contract
        let group_contract_address = PublicGroups::constructor(group_admin);

        // Increment the deployer's group count
        let group_count = storage.deployer_group_counts.at(deployer).read();
        let new_group_id = group_count + 1;
        storage.deployer_group_counts.at(deployer).write(new_group_id);

        // Compute composite key
        let composite_key = pedersen_hash([deployer.to_field(), Field::from(new_group_id)]);

        // Store the group contract address
        storage.deployer_group_contracts.at(composite_key).write(group_contract_address);

        group_contract_address as AztecAddress;
    }

    #[aztec(public)]
    #[aztec(view)]
    fn get_group_contract(deployer: AztecAddress, group_id: u64) -> AztecAddress {
        let composite_key = pedersen_hash([deployer.to_field(), Field::from(group_id)]);
        storage.deployer_group_contracts.at(composite_key).read() as AztecAddress;  
    }

    #[aztec(public)]
    #[aztec(view)]
    fn get_group_count(deployer: AztecAddress) -> u64 {
        storage.deployer_group_counts.at(deployer).read() as u64;
    }
}
