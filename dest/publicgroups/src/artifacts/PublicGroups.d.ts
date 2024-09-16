import { AztecAddress, type AztecAddressLike, type ContractArtifact, ContractBase, ContractFunctionInteraction, type ContractMethod, type ContractStorageLayout, type ContractNotes, DeployMethod, type FieldLike, Fr, type Wallet } from '@aztec/aztec.js';
export declare const PublicGroupsContractArtifact: any;
/**
 * Type-safe interface for contract PublicGroups;
 */
export declare class PublicGroupsContract extends ContractBase {
    private constructor();
    /**
     * Creates a contract instance.
     * @param address - The deployed contract's address.
     * @param wallet - The wallet to use when interacting with the contract.
     * @returns A promise that resolves to a new Contract instance.
     */
    static at(address: AztecAddress, wallet: Wallet): Promise<PublicGroupsContract>;
    /**
     * Creates a tx to deploy a new instance of this contract.
     */
    static deploy(wallet: Wallet, admin: AztecAddressLike): DeployMethod<PublicGroupsContract>;
    /**
     * Creates a tx to deploy a new instance of this contract using the specified public keys hash to derive the address.
     */
    static deployWithPublicKeysHash(publicKeysHash: Fr, wallet: Wallet, admin: AztecAddressLike): DeployMethod<PublicGroupsContract>;
    /**
     * Creates a tx to deploy a new instance of this contract using the specified constructor method.
     */
    static deployWithOpts<M extends keyof PublicGroupsContract['methods']>(opts: {
        publicKeysHash?: Fr;
        method?: M;
        wallet: Wallet;
    }, ...args: Parameters<PublicGroupsContract['methods'][M]>): DeployMethod<PublicGroupsContract>;
    /**
     * Returns this contract's artifact.
     */
    static get artifact(): ContractArtifact;
    static get storage(): ContractStorageLayout<'admin' | 'group_members' | 'group_balances'>;
    static get notes(): ContractNotes<'AddressNote' | 'ValueNote'>;
    /** Type-safe wrappers for the public methods exposed by the contract. */
    methods: {
        /** add_to_group(member: struct, approve: boolean) */
        add_to_group: ((member: AztecAddressLike, approve: boolean) => ContractFunctionInteraction) & Pick<ContractMethod, 'selector'>;
        /** admin() */
        admin: (() => ContractFunctionInteraction) & Pick<ContractMethod, 'selector'>;
        /** balance(creditor: struct, debtor: struct) */
        balance: ((creditor: AztecAddressLike, debtor: AztecAddressLike) => ContractFunctionInteraction) & Pick<ContractMethod, 'selector'>;
        /** compute_note_hash_and_optionally_a_nullifier(contract_address: struct, nonce: field, storage_slot: field, note_type_id: field, compute_nullifier: boolean, serialized_note: array) */
        compute_note_hash_and_optionally_a_nullifier: ((contract_address: AztecAddressLike, nonce: FieldLike, storage_slot: FieldLike, note_type_id: FieldLike, compute_nullifier: boolean, serialized_note: FieldLike[]) => ContractFunctionInteraction) & Pick<ContractMethod, 'selector'>;
        /** constructor(admin: struct) */
        constructor: ((admin: AztecAddressLike) => ContractFunctionInteraction) & Pick<ContractMethod, 'selector'>;
        /** in_group(group_member: struct) */
        in_group: ((group_member: AztecAddressLike) => ContractFunctionInteraction) & Pick<ContractMethod, 'selector'>;
        /** set_balance(creditor: struct, debtor: struct, amount: field) */
        set_balance: ((creditor: AztecAddressLike, debtor: AztecAddressLike, amount: FieldLike) => ContractFunctionInteraction) & Pick<ContractMethod, 'selector'>;
    };
}
//# sourceMappingURL=PublicGroups.d.ts.map