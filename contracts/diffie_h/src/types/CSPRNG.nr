use dep::std;
use dep::std::hash::{sha256, blake2s, pedersen_hash, pedersen_commitment, keccak256};
use dep::std::hash::poseidon::bn254::{hash_1, hash_2};
use dep::std::hash::mimc::{mimc, mimc_bn254};
use dep::std::hash::hash_to_field;

struct CSPRNG {
    seed: [u8; 32],
}

fn convert_from_field(field: Field) -> [u8; 32] {
    let mut bytes = [0 as u8; 32];
    let num = field as u64;
    for i in 0..32 {
        bytes[i] = ((num >> (8 * (31 - i))) & 0xff) as u8;
    }
    bytes
}
impl CSPRNG {
    fn new(seed: [u8; 32]) -> CSPRNG {
        CSPRNG { seed }
    }

    fn generate(&mut self, hash_method: u8) -> Field {
        if hash_method == 0 {
            // Using SHA-256
            self.seed = std::hash::sha256(self.seed);
        } else if hash_method == 1 {
            // Using Blake2s
            self.seed = std::hash::blake2s(self.seed);
        } else if hash_method == 2 {
            // Using Keccak256 (specify message_size as appropriate)
            let message_size = 32; // Example size
            self.seed = std::hash::keccak256(self.seed, message_size);
        }

        CSPRNG::convert_to_field(self.seed)
    }

    fn convert_to_field(hash_output: [u8; 32]) -> Field {
        let mut result: Field = 0;
        let mut v: Field = 1;

        for i in 0..32 {
            let index = 31 - i;  // Start from the end of the array
            result += hash_output[index] as Field * v;
            v *= 256;
        }

        result
    }
    fn reseed(&mut self, new_seed: [u8; 32]) {
        self.seed = new_seed;
    }
}