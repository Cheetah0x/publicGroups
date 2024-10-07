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

    //try what they did with shared secrets with just shared encryption and decryption keys

    

}