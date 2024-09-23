mod types;

contract PrivateGroups {

    use dep::aztec::{prelude::{Map, PublicMutable, AztecAddress, PrivateImmutable, PrivateMutable}};
    // use dep::address_note::address_note::AddressNote;
    use dep::aztec::{
        encrypted_logs::encrypted_note_emission::encode_and_encrypt_note_with_keys,
        keys::getters::get_current_public_keys
    };
    use crate::types::StringNote::StringNote;
    use crate::types::NewAddressNote::NewAddressNote;





    global ZERO_ADDRESS: AztecAddress = AztecAddress::from_field(0x0000000000000000000000000000000000000000000000000000000000000000);



    //TODO:: think about what structure  would be used for the group members
    //maybe there should be a shared secret for each of the group members through a note. 
    //hashed with the npk_m of the user

    #[aztec(storage)]
   struct Storage {
        admin: PrivateImmutable<NewAddressNote>,
        group_members: Map<AztecAddress, PrivateImmutable<NewAddressNote>>,
        // shared_secret: PrivateImmutable<StringNote>,
        shared_secret: Map<AztecAddress, PrivateImmutable<StringNote>>,
   }

    //use the message sender keys to encrypt the admin address note
    //just use this for now
    //TODO:: rethink what i encrypt this witih
    //.   - shared key generation and adding the addresses into the group, this will be a hash of the members maybe
    // - group members will have to be a list of addresses, this is crap. Will have to iterate through
    //.  - the zero addresses in the input, this has to change. This will be input into the function
    //    -have upper bound of group members as 10
    // instead of boolean, can use a value note that is either 0 or 1, also this doesnt really matter if they are in the group

    #[aztec(private)]
   #[aztec(initializer)]
   fn constructor(admin: AztecAddress, group_members: [AztecAddress; 2], shared_secret: Field) {
        //setting the admin address note
        let admin_keys = get_current_public_keys(&mut context, admin);
        let msg_sender_keys = get_current_public_keys(&mut context, context.msg_sender());
        let mut admin_address_note = NewAddressNote::new(admin, shared_secret, admin_keys.npk_m.hash());
        storage.admin.initialize(&mut admin_address_note).emit(encode_and_encrypt_note_with_keys(&mut context, admin_keys.ovpk_m, admin_keys.ivpk_m, admin));

        //need to make the shared secret for the group
        //this isnt something i fully understand so will play around with it, 
        // options - hash of the group members,
        //         - or a secret that is passed into the contstructor
        // going with the shared secret for now
        //using the npk_m hash to store secret for now due to simplicity and lack of understanding, may have to change this
        //not sure about the randomness bit, if i even need it, just put this as 0 

        //this is the old shared secret, super simple
        // let mut shared_secret_note = StringNote::new(shared_secret, admin_keys.npk_m.hash());
        // storage.shared_secret.initialize(&mut shared_secret_note).emit(encode_and_encrypt_note_with_keys(&mut context, admin_keys.ovpk_m, admin_keys.ivpk_m, admin));

        //new type of shared secret
        //if each member was to have their own secret, would u emit event that they can see, need to look more into this, this should get loaded into the users PXE
        //going to try this with the shared secret now
        for i in 0..2 {
            let member = group_members[i as u32];
            if (member != ZERO_ADDRESS) {
                let member_keys = get_current_public_keys(&mut context, member);
                let shared_secret_note = StringNote::new(shared_secret,  member_keys.npk_m.hash());
                storage.shared_secret.at(member).initialize(&mut shared_secret_note).emit(
                    encode_and_encrypt_note_with_keys(
                        &mut context, 
                        msg_sender_keys.ovpk_m, 
                        member_keys.ivpk_m, 
                        member
                    )
                );
            }
        }

        //  adding the group members to the map
        //the admin will add the group members to the contract
        for i in 0..2 {
            let member = group_members[i as u32];
            if (member != ZERO_ADDRESS) {
                let member_keys = get_current_public_keys(&mut context, member);
                let mut memberNote = NewAddressNote::new(member, shared_secret, member_keys.npk_m.hash());
                storage.group_members.at(member).initialize(&mut memberNote).emit(
                    encode_and_encrypt_note_with_keys(
                        &mut context,
                        admin_keys.ovpk_m,
                        member_keys.ivpk_m,
                        member
                    )
                );
            }
        }
    }
   



    //need to constrain this so that only group members can read this 
    #[aztec(private)]
    fn get_admin() -> AztecAddress {
        let admin_note = storage.admin.get_note();
        admin_note.address
    }
    // // // TODO:: BROKEN
    #[aztec(private)]
    fn get_group_member(member: AztecAddress) -> AztecAddress {
        // this is a check to make sure that the user is a group member
        // do not worry about the assertion for now
        //interesting, this code only works for immutable notes, need to change for mutable


        // let msg_sender_note = storage.group_members.at(context.msg_sender()).get_note();
        // assert(context.msg_sender() == msg_sender_note.address, "Not a group member");

        let member_note = storage.group_members.at(member).get_note();
        member_note.address 
    }

    //this is the old shared secret
    // #[aztec(private)]
    // fn get_shared_secret() -> Field {
    //     //this is a check to make sure that the user is a group member
    //     //need to figure out these assertions
    //     // let msg_sender_note = storage.group_members.at(context.msg_sender()).get_note();
    //     // assert(context.msg_sender() == msg_sender_note.address, "Not a group member");
    //     let shared_secret_note = storage.shared_secret.get_note();
    //     shared_secret_note.string
    // }

    //new type of shared secret
    #[aztec(private)]
    fn get_shared_secret(member: AztecAddress) -> Field {
        let shared_secret_note = storage.shared_secret.at(member).get_note();
        shared_secret_note.string
    }

     // unconstrained function to get group_members
    unconstrained fn is_group_member(member: AztecAddress) -> pub bool {
        storage.group_members.at(member).is_initialized()
    }

}
