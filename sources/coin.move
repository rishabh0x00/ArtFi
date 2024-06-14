// #[allow(lint(share_owned))]
// module collection::mycoin {
//     use sui::coin::{Self, TreasuryCap};

//     /// The type identifier of coin. The coin will have a type
//     /// tag of kind: `Coin<package_object::mycoin::MYCOIN>`
//     /// Make sure that the name of the type matches the module's name.
//     public struct MYCOIN has drop {}

//     /// Module initializer is called once on module publish. A treasury
//     /// cap is sent to the publisher, who then controls minting and burning
//     fun init(witness: MYCOIN, ctx: &mut TxContext) {
//         let (treasury, metadata) = coin::create_currency(witness, 6, b"MYCOIN", b"", b"", option::none(), ctx);
//         transfer::public_freeze_object(metadata);
//         transfer::public_share_object(treasury);
//     }

//     public fun mint(treasury: &mut TreasuryCap<MYCOIN>, value: u64, recipient: address, ctx: &mut TxContext) {
//         coin::mint_and_transfer(treasury, value, recipient, ctx);
//     }
// }