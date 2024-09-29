mod types;

use dep::aztec::macros::aztec;

#[aztec]
contract PrivateGroups {

    use dep::aztec::{prelude::{Map, PublicMutable, AztecAddress, PrivateImmutable, PrivateSet, PrivateMutable}};
    // use dep::address_note::address_note::AddressNote;
    use dep::aztec::{
        encrypted_logs::encrypted_note_emission::encode_and_encrypt_note_with_keys,
        keys::getters::get_public_keys,
        macros::{storage::storage, events::event, functions::{public, initializer, private, internal}}
    };
    use dep::aztec::note::note_viewer_options::NoteViewerOptions;
    use crate::types::StringNote::StringNote;
    use crate::types::NewAddressNote::NewAddressNote;
    use aztec::note::note_getter::NoteGetterOptions;
    use value_note::{balance_utils, utils::{increment, decrement}, value_note::ValueNote};
    use std::hash::pedersen_hash;

    global ZERO_ADDRESS: AztecAddress = AztecAddress::from_field(0x0000000000000000000000000000000000000000000000000000000000000000);

    #[storage]
   struct Storage<Context> {
        admin: PrivateImmutable<NewAddressNote, Context>,
        group_members: Map<AztecAddress, PrivateSet<NewAddressNote, Context>, Context>,
        // shared_secret: PrivateImmutable<StringNote>,
        shared_secret: Map<AztecAddress, PrivateImmutable<StringNote, Context>, Context>,
        group_balances_credit: Map<Field, PrivateSet<ValueNote,Context>, Context>,
        group_balances_debt: Map<Field, PrivateSet<ValueNote, Context>, Context>,
   }

    #[private]
    #[initializer]
    fn constructor(admin: AztecAddress, group_members: [AztecAddress; 2], shared_secret: Field) {
        //setting the admin address note
        let admin_keys = get_public_keys(admin);
        let msg_sender_keys = get_public_keys(context.msg_sender());
        let mut admin_address_note = NewAddressNote::new(admin, shared_secret, admin_keys.npk_m.hash());
        storage.admin.initialize(&mut admin_address_note).emit(encode_and_encrypt_note_with_keys(&mut context, admin_keys.ovpk_m, admin_keys.ivpk_m, admin));

        for i in 0..2 {
            let member = group_members[i as u32];
            if (member != ZERO_ADDRESS) {
                let member_keys = get_public_keys(member);

                //not sure why i have to declare it as mutable when it is immutable
                let mut shared_secret_note = StringNote::new(shared_secret, member_keys.npk_m.hash());
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

        //this is for adding members to the private set, so they can see the other members, going to be expensive
        for i in 0..2 {
            let member = group_members[i as u32];
            if (member != ZERO_ADDRESS) {
                let member_keys = get_public_keys(member);
                for i in 0..2 {
                    let member_add = group_members[i as u32];
                    let mut memberNote = NewAddressNote::new(member_add, shared_secret, member_keys.npk_m.hash());
                    storage.group_members.at(member).insert(&mut memberNote).emit(
                        encode_and_encrypt_note_with_keys(&mut context, admin_keys.ovpk_m, member_keys.ivpk_m, member)
                    );
                }
            }
        }
    }

    //need to constrain this so that only group members can read this 
    #[private]
    fn get_admin() -> pub AztecAddress {
        let admin_note = storage.admin.get_note();
        admin_note.address
    }
    // // // TODO:: BROKEN
    #[private]
    fn get_group_members(member: AztecAddress) -> [AztecAddress; 2] {
        // this is a check to make sure that the user is a group member
        // do not worry about the assertion for now
        //interesting, this code only works for immutable notes, need to change for mutable

        // let msg_sender_note = storage.group_members.at(context.msg_sender()).get_note();
        // assert(context.msg_sender() == msg_sender_note.address, "Not a group member");
        //hardcodeing the length of the array for now
        let mut options = NoteGetterOptions::new();
        let member_note = storage.group_members.at(member).get_notes(options);
        let mut member_array : [AztecAddress; 2] = [ZERO_ADDRESS; 2];
        //if you call this and u are not part of the group, it will return the zero address
        for i in 0..2 {
            let note = member_note.get_unchecked(i);
            let address: AztecAddress = note.address;
            member_array[i] = address;
        }
        member_array
    }

    //new type of shared secret
    #[private]
    fn get_shared_secret(member: AztecAddress) -> Field {
        let shared_secret_note = storage.shared_secret.at(member).get_note();
        shared_secret_note.string
    }

    #[private]
    fn set_balance(creditor: AztecAddress, debtor: AztecAddress, amount: Field) {
        //do not do any assertions for now
        //the balances will be value notes
        //this is working correctly
        // owner is the creditor
        // debtor is the outgoing viewer

        //notes for the creditor
        let key = pedersen_hash([creditor.to_field(), debtor.to_field()]);
        let loc = storage.group_balances_credit.at(key);
        increment(loc, amount, creditor, debtor);

        //notes for the debtor
        let loc = storage.group_balances_debt.at(key);
        increment(loc, amount, debtor, creditor);
    }

    //new make payment function
    //if u have outgoing then u owe that person money
    //incoming means u are owed that money
    #[private]
    fn new_set_balance(creditor: AztecAddress, debtor: AztecAddress, amount: Field) {
        assert(creditor != debtor, "Cannot send money to yourself");

        let amount_int = amount as u64;
        assert(amount_int > 0, "Amount must be greater than 0");

        assert(creditor == context.msg_sender(), "Only the creditor can set the balance");

        let creditor_keys = get_public_keys(creditor);
        let debtor_keys = get_public_keys(debtor);

        //decrement the creditor's balance
        let key = pedersen_hash([creditor.to_field(), debtor.to_field()]);
        let loc = storage.group_balances_credit.at(key);
        let mut credit_note = ValueNote::new(amount, creditor_keys.npk_m.hash());
        // let mut debt_note = ValueNote::new(amount, debtor_keys.npk_m.hash());

        //put notes in storage and send them to the creditor and debtor
        loc.insert(&mut credit_note).emit(
            encode_and_encrypt_note_with_keys(
                &mut context,
                creditor_keys.ovpk_m,
                debtor_keys.ivpk_m,
                creditor
            )
        );
        // loc.insert(&mut debt_note).emit(
        //     encode_and_encrypt_note_with_keys(&mut context, creditor_keys.ovpk_m, debtor_keys.ivpk_m, debtor)
        // );
    }

    //hopefully this works,
    // i am using alice wallet so not sure if it will or i can only use the admin wallet to make these changes rn
    //or if i have to make separate notes for each alice and bob
    //so at the minute i dont think this is doing anything.
    //guess this is where the shared secret will come in
    //this does not work at the minute, the debtor cannot interact with the balance
    #[private]
    fn make_payment(creditor: AztecAddress, debtor: AztecAddress, amount: Field) {
        //decrement the creditor's balance
        // let key = pedersen_hash([creditor.to_field(), debtor.to_field()]);
        // // let loc = storage.group_balances_credit.at(key);
        // // decrement(loc, amount, creditor, debtor);

        // //decrement the debtor's balance
        // let loc = storage.group_balances_debt.at(key);
        // decrement(loc, amount, debtor, creditor);

        //going to redo this, the idea is that u get the outgoing notes at that key, this is the money u owe
        let key = pedersen_hash([creditor.to_field(), debtor.to_field()]);
        let loc = storage.group_balances_credit.at(key);

        //this finds the notes that u owe
        let msg_sender_keys = get_public_keys(context.msg_sender());
        let mut options = NoteGetterOptions::new();
        let balance_notes_debt: BoundedVec<ValueNote, 16> = loc.get_notes(options);

        let mut total_balance = 0 as Field;
        for i in 0..balance_notes_debt.max_len() {
            if i < balance_notes_debt.len() {
                let note = balance_notes_debt.get_unchecked(i);
                total_balance += note.value;
            }
        }

        //if the total balance is greater than the amount then we can make the payment
        let total_balance_int = total_balance as u64;
        let amount_int = amount as u64;
        if total_balance_int >= amount_int {
            //going to decrement the notes
            decrement(loc, amount, debtor, creditor);
        }
        //at the minute this is not going to change anything, there needs to be a way that all the notes are nullified and this makes a new one that both parties can see
        //i think this makes sense, it makes the payment
    }

    #[private]
    fn read_balance_credit(creditor: AztecAddress, debtor: AztecAddress) -> Field {
        //for this function i need to also get the notes that the debtor has sent if they have sent any
        //if they have sent new notes, i need to nullify the old ones that i have sent to the debtor
        //make a new one with the new outstanding balance
        //tricky part is listening for new notes that the debtor has sent, updating the balance

        let key = pedersen_hash([creditor.to_field(), debtor.to_field()]);
        let options = NoteGetterOptions::new();
        let balance_notes_credit: BoundedVec<ValueNote, 16> = storage.group_balances_credit.at(key).get_notes(options);

        let mut total_balance = 0 as Field;
        for i in 0..balance_notes_credit.max_len() {
            if i < balance_notes_credit.len() {
                let note = balance_notes_credit.get_unchecked(i);
                total_balance += note.value;
            }
        }

        total_balance
    }

    #[private]
    fn read_balance_debt(creditor: AztecAddress, debtor: AztecAddress) -> Field {
        let key = pedersen_hash([creditor.to_field(), debtor.to_field()]);
        let options = NoteGetterOptions::new();
        let balance_notes_debt: BoundedVec<ValueNote, 16> = storage.group_balances_debt.at(key).get_notes(options);

        let mut total_balance = 0 as Field;
        for i in 0..balance_notes_debt.max_len() {
            if i < balance_notes_debt.len() {
                let note = balance_notes_debt.get_unchecked(i);
                total_balance += note.value;
            }
        }

        total_balance
    }
    //  #[contract_library_method]
    // fn subtract_balance(
    //     context: &mut PrivateContext,
    //     storage: Storage<&mut PrivateContext>,
    //     account: AztecAddress,
    //     amount: U128,
    //     max_notes: u32
    // ) -> U128 {
    //     let subtracted = storage.balances.at(account).try_sub(amount, max_notes);
    //     // Failing to subtract any amount means that the owner was unable to produce more notes that could be nullified.
    //     // We could in some cases fail early inside try_sub if we detected that fewer notes than the maximum were
    //     // returned and we were still unable to reach the target amount, but that'd make the code more complicated, and
    //     // optimizing for the failure scenario is not as important.
    //     assert(subtracted > U128::from_integer(0), "Balance too low");
    //     if subtracted >= amount {
    //         // We have achieved our goal of nullifying notes that add up to more than amount, so we return the change
    //         subtracted - amount
    //     } else {
    //         // try_sub failed to nullify enough notes to reach the target amount, so we compute the amount remaining
    //         // and try again.
    //         let remaining = amount - subtracted;
    //         compute_recurse_subtract_balance_call(*context, account, remaining).call(context)
    //     }
    // }
}
