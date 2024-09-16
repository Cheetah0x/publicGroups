// mod test;

//this will be a little test to make public groups in noir


contract PublicGroups {

    use dep::aztec::{prelude::{Map, PublicMutable, AztecAddress}};
    use dep::std::hash::pedersen_hash;


    #[aztec(storage)]
    struct Storage {
        admin: PublicMutable<AztecAddress>,
        group_members: Map<AztecAddress, PublicMutable<bool>>,
        group_balances: Map<Field, PublicMutable<Field>>,
        member_count: PublicMutable<u64>,
    }

    #[aztec(public)]
    #[aztec(initializer)]
    fn constructor(admin: AztecAddress) {
        assert(!admin.is_zero(), "invalid admin");
        storage.admin.write(admin);
        storage.group_members.at(admin).write(true);
        storage.member_count.write(1);
    }

    //helper functions to read variables when testing

    //read the admin
    #[aztec(public)]
    #[aztec(view)]
    fn admin() -> Field {
        storage.admin.read().to_field()
    }

    //read the group members
    #[aztec(public)]
    #[aztec(view)]
    fn in_group(group_member: AztecAddress) -> bool {
        storage.group_members.at(group_member).read()
    }


    //read the member count
    #[aztec(public)]
    #[aztec(view)]
    fn member_count() -> u64 {
        storage.member_count.read()
    }

    //read the balance between two addresses
    #[aztec(public)]
    #[aztec(view)]
    fn balance(creditor: AztecAddress, debtor: AztecAddress) -> Field {
        let key = pedersen_hash([creditor.to_field(), debtor.to_field()]);
        storage.group_balances.at(key).read()
    }

    //functional methods

     #[aztec(public)]
    fn add_to_group(member: AztecAddress, approve: bool) {
        assert(storage.admin.read().eq(context.msg_sender()), "caller is not admin");
        storage.group_members.at(member).write(approve);
        if (approve) {
            storage.member_count.write(storage.member_count.read() + 1);
        }
    }

     #[aztec(public)]
    fn remove_from_group(member: AztecAddress, approve: bool) {
        assert(storage.admin.read().eq(context.msg_sender()), "caller is not admin");
        storage.group_members.at(member).write(approve);
        if (approve) {
            storage.member_count.write(storage.member_count.read() - 1);
        }
    }

    //this set balances but only between two people
    #[aztec(public)]
    fn set_balance(creditor: AztecAddress, debtor: AztecAddress, amount: Field) {
        assert(creditor == context.msg_sender(), "cannot adjust someone elses balances");
        assert(storage.group_members.at(creditor).read() == true, "Creditor is not in group");
        assert(storage.group_members.at(debtor).read() == true, "Debtor is not in group");

        //cant store the addresses in a tuple in storage so hash them together,
        //easy to know who owes who as hash a,b is different from hash b,a
        let key = pedersen_hash([creditor.to_field(), debtor.to_field()]);
        let balance = storage.group_balances.at(pedersen_hash([creditor.to_field(), debtor.to_field()])).read();
        let amount_to_write = amount + balance;
        storage.group_balances.at(key).write(amount_to_write);

        //adjust the balances
        //balance between creditor and debtor
        let creditor_debtor_hash = pedersen_hash([creditor.to_field(), debtor.to_field()]);
        let balance_creditor_debtor = storage.group_balances.at(creditor_debtor_hash).read() as u64;

        //balance between debtor and creditor
        let debtor_creditor_hash = pedersen_hash([debtor.to_field(), creditor.to_field()]);
        let balance_debtor_creditor = storage.group_balances.at(debtor_creditor_hash).read() as u64;

        //if the balance is greater than 0, then the creditor owes the debtor that amount
        if (balance_creditor_debtor > balance_debtor_creditor) {
            let difference = balance_creditor_debtor - balance_debtor_creditor;
            storage.group_balances.at(creditor_debtor_hash).write(difference.to_field());
            storage.group_balances.at(debtor_creditor_hash).write(0.to_field());
        }

        //if the balance is less than 0, then the debtor owes the creditor that amount
        if (balance_debtor_creditor > balance_creditor_debtor) {
            let difference = balance_debtor_creditor - balance_creditor_debtor;
            storage.group_balances.at(debtor_creditor_hash).write(difference.to_field());
            storage.group_balances.at(creditor_debtor_hash).write(0.to_field());
        }

        if (balance_creditor_debtor == balance_debtor_creditor) {
            storage.group_balances.at(creditor_debtor_hash).write(0.to_field());
            storage.group_balances.at(debtor_creditor_hash).write(0.to_field());
            //this is not setting them to 0
        }
        //if the balance is 0, then the creditor and debtor are even
        //the values should never go below 0 as as you are subtracting a larger number from a smaller one.
    }

    #[aztec(public)]
    fn make_payment(creditor: AztecAddress, debtor: AztecAddress, amount: u64) {
        assert(storage.group_members.at(creditor).read() == true, "Creditor is not in group");
        assert(storage.group_members.at(debtor).read() == true, "Debtor is not in group");
        //make sure the payment is less than  or equal to the balance
        let key = pedersen_hash([creditor.to_field(), debtor.to_field()]);
        let balance = storage.group_balances.at(key).read() as u64;
        assert(balance >= amount, "Insufficient balance, or paying more than is owed");

        //subtract the amount from the creditor
        let amount_to_write = balance - amount;
        storage.group_balances.at(key).write(amount_to_write.to_field());
    }

    
}
