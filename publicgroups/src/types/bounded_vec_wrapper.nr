// use dep::aztec::prelude::AztecAddress;
// use dep::aztec::protocol_types::traits::{Serialize, Deserialize};
// use dep::std::collections::bounded_vec::BoundedVec;

// pub struct AddressVec {
//     vec: BoundedVec<AztecAddress, 10>,
// }

// impl AddressVec {
//     pub fn new() -> Self {
//         AddressVec {
//             vec: BoundedVec::new(),
//         }
//     }

//     pub fn push(&mut self, address: AztecAddress) {
//         self.vec.push(address);
//     }

//     pub fn get(&self, index: u32) -> AztecAddress {
//         self.vec.get(index)
//     }

//     pub fn len(&self) -> u32 {
//         self.vec.len()
//     }
// }

// impl Serialize for AddressVec {
//     fn serialize(&self) -> [Field; 11] {  // 1 for length + 10 for addresses
//         let mut result = [Field::zero(); 11];
//         result[0] = self.len() as Field;
//         for i in 0..self.len() {
//             let address = self.get(i);
//             result[i as usize + 1] = address.to_field();
//         }
//         result
//     }
// }

// impl Deserialize for AddressVec {
//     fn deserialize(fields: [Field; 11]) -> Self {
//         let len = fields[0] as u32;
//         let mut vec = AddressVec::new();
//         for i in 0..len {
//             let address = AztecAddress::from_field(fields[i as usize + 1]);
//             vec.push(address);
//         }
//         vec
//     }
// }
