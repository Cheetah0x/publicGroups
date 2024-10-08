
/* Autogenerated file, do not edit! */

/* eslint-disable */
import {
  AztecAddress,
  type AztecAddressLike,
  CompleteAddress,
  Contract,
  type ContractArtifact,
  ContractBase,
  ContractFunctionInteraction,
  type ContractInstanceWithAddress,
  type ContractMethod,
  type ContractStorageLayout,
  type ContractNotes,
  DeployMethod,
  EthAddress,
  type EthAddressLike,
  EventSelector,
  type FieldLike,
  Fr,
  type FunctionSelectorLike,
  L1EventPayload,
  loadContractArtifact,
  type NoirCompiledContract,
  NoteSelector,
  Point,
  type PublicKey,
  type Wallet,
  type WrappedFieldLike,
} from '@aztec/aztec.js';
import PrivateGroupsContractArtifactJson from '../../target/privategroups-PrivateGroups.json' assert { type: 'json' };
export const PrivateGroupsContractArtifact = loadContractArtifact(PrivateGroupsContractArtifactJson as NoirCompiledContract);



/**
 * Type-safe interface for contract PrivateGroups;
 */
export class PrivateGroupsContract extends ContractBase {
  
  private constructor(
    instance: ContractInstanceWithAddress,
    wallet: Wallet,
  ) {
    super(instance, PrivateGroupsContractArtifact, wallet);
  }
  

  
  /**
   * Creates a contract instance.
   * @param address - The deployed contract's address.
   * @param wallet - The wallet to use when interacting with the contract.
   * @returns A promise that resolves to a new Contract instance.
   */
  public static async at(
    address: AztecAddress,
    wallet: Wallet,
  ) {
    return Contract.at(address, PrivateGroupsContract.artifact, wallet) as Promise<PrivateGroupsContract>;
  }

  
  /**
   * Creates a tx to deploy a new instance of this contract.
   */
  public static deploy(wallet: Wallet, admin: AztecAddressLike, group_members: AztecAddressLike[], shared_secret: FieldLike) {
    return new DeployMethod<PrivateGroupsContract>(Fr.ZERO, wallet, PrivateGroupsContractArtifact, PrivateGroupsContract.at, Array.from(arguments).slice(1));
  }

  /**
   * Creates a tx to deploy a new instance of this contract using the specified public keys hash to derive the address.
   */
  public static deployWithPublicKeysHash(publicKeysHash: Fr, wallet: Wallet, admin: AztecAddressLike, group_members: AztecAddressLike[], shared_secret: FieldLike) {
    return new DeployMethod<PrivateGroupsContract>(publicKeysHash, wallet, PrivateGroupsContractArtifact, PrivateGroupsContract.at, Array.from(arguments).slice(2));
  }

  /**
   * Creates a tx to deploy a new instance of this contract using the specified constructor method.
   */
  public static deployWithOpts<M extends keyof PrivateGroupsContract['methods']>(
    opts: { publicKeysHash?: Fr; method?: M; wallet: Wallet },
    ...args: Parameters<PrivateGroupsContract['methods'][M]>
  ) {
    return new DeployMethod<PrivateGroupsContract>(
      opts.publicKeysHash ?? Fr.ZERO,
      opts.wallet,
      PrivateGroupsContractArtifact,
      PrivateGroupsContract.at,
      Array.from(arguments).slice(1),
      opts.method ?? 'constructor',
    );
  }
  

  
  /**
   * Returns this contract's artifact.
   */
  public static get artifact(): ContractArtifact {
    return PrivateGroupsContractArtifact;
  }
  

  public static get storage(): ContractStorageLayout<'admin' | 'group_members' | 'shared_secret'> {
      return {
        admin: {
      slot: new Fr(1n),
    },
group_members: {
      slot: new Fr(2n),
    },
shared_secret: {
      slot: new Fr(3n),
    }
      } as ContractStorageLayout<'admin' | 'group_members' | 'shared_secret'>;
    }
    

  public static get notes(): ContractNotes<'StringNote' | 'AddressNote' | 'ValueNote'> {
    return {
      StringNote: {
          id: new NoteSelector(699142570),
        },
AddressNote: {
          id: new NoteSelector(2232136525),
        },
ValueNote: {
          id: new NoteSelector(1038582377),
        }
    } as ContractNotes<'StringNote' | 'AddressNote' | 'ValueNote'>;
  }
  

  /** Type-safe wrappers for the public methods exposed by the contract. */
  public declare methods: {
    
    /** compute_note_hash_and_optionally_a_nullifier(contract_address: struct, nonce: field, storage_slot: field, note_type_id: field, compute_nullifier: boolean, serialized_note: array) */
    compute_note_hash_and_optionally_a_nullifier: ((contract_address: AztecAddressLike, nonce: FieldLike, storage_slot: FieldLike, note_type_id: FieldLike, compute_nullifier: boolean, serialized_note: FieldLike[]) => ContractFunctionInteraction) & Pick<ContractMethod, 'selector'>;

    /** constructor(admin: struct, group_members: array, shared_secret: field) */
    constructor: ((admin: AztecAddressLike, group_members: AztecAddressLike[], shared_secret: FieldLike) => ContractFunctionInteraction) & Pick<ContractMethod, 'selector'>;

    /** get_admin() */
    get_admin: (() => ContractFunctionInteraction) & Pick<ContractMethod, 'selector'>;

    /** get_shared_secret() */
    get_shared_secret: (() => ContractFunctionInteraction) & Pick<ContractMethod, 'selector'>;
  };

  
}
