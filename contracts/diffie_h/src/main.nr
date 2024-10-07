mod types;

use dep::aztec::macros::aztec;

#[aztec]
contract DiffieH {
    use dep::aztec::{
        prelude::{Map, PublicMutable, AztecAddress, PrivateImmutable, PrivateSet, PrivateMutable},
        encrypted_logs::encrypted_note_emission::encode_and_encrypt_note_with_keys,
        keys::getters::get_public_keys,
        macros::{storage::storage, events::event, functions::{public, initializer, private, internal}}
    };
    use dep::aztec::note::note_viewer_options::NoteViewerOptions;
    use crate::types::StringNote::StringNote;
    use crate::types::NewAddressNote::NewAddressNote;
    use aztec::note::note_getter::NoteGetterOptions;
    use dep::address_note::address_note::AddressNote;
    use crate::types::CSPRNG::CSPRNG;


    use dep::value_note::{balance_utils, utils::{increment, decrement}, value_note::ValueNote};
    use std::hash::pedersen_hash;
    use dep::std::println;

    global ZERO_ADDRESS: AztecAddress = AztecAddress::from_field(0x0000000000000000000000000000000000000000000000000000000000000000);

    #[storage]
    struct Storage<Context> {
        admin: PrivateImmutable<AddressNote, Context>,
        group_members: Map<AztecAddress, PrivateSet<NewAddressNote, Context>, Context>,
        shared_secrets: Map<AztecAddress, PrivateImmutable<ValueNote, Context>, Context>,
    }

    #[private]
    #[initializer]
    fn constructor(admin: AztecAddress, group_members: [AztecAddress; 2]) {
        // Setting the admin address note
        let admin_keys = get_public_keys(admin);
        let msg_sender_keys = get_public_keys(context.msg_sender());
        let mut admin_address_note = AddressNote::new(admin, admin_keys.npk_m.hash());
        storage.admin.initialize(&mut admin_address_note).emit(encode_and_encrypt_note_with_keys(&mut context, admin_keys.ovpk_m, admin_keys.ivpk_m, admin));

        //generator for the group
        let generator = make_generator(1);
        let prime_modulus = 23;
        //private key for each member of the group
        


    }

    //make the public generator. for dh does this have to be prime
    #[internal]
    fn make_generator(seed: u8) -> pub Field {
        let initial_seed = [seed ; 32];
        let mut rng = CSPRNG::new(initial_seed);
        let generator = rng.generate(0);
        generator
    }
}