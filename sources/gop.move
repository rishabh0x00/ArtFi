#[allow(lint(share_owned, self_transfer))]
module collection::gop {

    // === Imports ===

    use std::string::{Self, String};
    use std::vector;

    use sui::display;
    use sui::event;
    use sui::object::{Self, ID, UID};
    use sui::package;
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};
    use sui::vec_map;

    use collection::baseNFT;

    // === Structs ===

    struct GOPNFT has key, store {
        id: UID,
        user_detials: vec_map::VecMap<ID, Attributes>,
    }

    struct Attributes has store, copy, drop {
        claimed: bool,
        airdrop: bool,
        ieo: bool
    }

    struct AdminCap has key {
        id: UID
    }

    // ===== Events =====

    struct GOPAttributesUpdated has copy, drop {
        claimed: bool,
        airdrop: bool,
        ieo: bool
    }

    /// One-Time-Witness for the module.
    struct GOP has drop {}

    // ===== Entrypoints =====

    /// Module initializer is called only once on module publish.
    fun init(otw: GOP, ctx: &mut TxContext) {
        let keys = vector[
            string::utf8(b"name"),
            string::utf8(b"description"),
        ];

        let values = vector[
            // For `name` one can use the `GOPNFT.name` property
            string::utf8(b"Artfi"),
            // Description is static for all `GOPNFT` objects.
            string::utf8(b"Artfi_NFT"),
        ];

        // Claim the `Publisher` for the package!
        let publisher = package::claim(otw, ctx);

        // Get a new `Display` object for the `GOPNFT` type.
        let display_object = display::new_with_fields<GOPNFT>(
            &publisher, keys, values, ctx
        );

        // Commit first version of `Display` to apply changes.
        display::update_version(&mut display_object);

        transfer::public_transfer(publisher, tx_context::sender(ctx));
        transfer::public_share_object(display_object);

        transfer::share_object(GOPNFT {
            id: object::new(ctx),
            user_detials: vec_map::empty<ID, Attributes>(),
            
        });

        transfer::transfer(AdminCap {
            id: object::new(ctx)
        }, tx_context::sender(ctx));
    }

    // === Public-Mutative Functions ===

    /// Create a new GOP
    public entry fun mint_nft(
        display_object: &display::Display<GOPNFT>,
        gop_info: &mut GOPNFT,
        mint_counter: &mut baseNFT::NftCounter,
        url: vector<u8>,
        ctx: &mut TxContext
    ) { 
        let id: ID = baseNFT::mint_nft(display_object, mint_counter, url, ctx);

        vec_map::insert(&mut gop_info.user_detials, id, Attributes{
            claimed: false,
            airdrop: false,
            ieo: false
        });
    }
    
    /// Create a multiple GOP
    public fun mint_nft_batch(
        admin_cap: &baseNFT::AdminCap,
        display_object: &display::Display<GOPNFT>,
        gop_info: &mut GOPNFT,
        mint_counter: &mut baseNFT::NftCounter,
        uris: &vector<vector<u8>>,
        user: address,
        ctx: &mut TxContext
    ) {
        let ids = baseNFT::mint_nft_batch(admin_cap, display_object, mint_counter, uris, user, ctx);
        let lengthOfVector = vector::length(&ids);
        let index = 0;
        while (index < lengthOfVector) {
            vec_map::insert(&mut gop_info.user_detials, *vector::borrow(&ids, index), Attributes{
                claimed: false,
                airdrop: false,
                ieo: false
            });

            index = index + 1;
        }
    }

    // === AdminCap Functions ===

    public entry fun update_attribute(
        _: &AdminCap,
        gop_info: &mut GOPNFT,
        id: ID,
        new_claimed: bool,
        new_airdrop: bool,
        new_ieo: bool
    ) {
        vec_map::remove(&mut gop_info.user_detials, &id);
        vec_map::insert(&mut gop_info.user_detials, id, Attributes{
            claimed: new_claimed, 
            airdrop: new_airdrop, 
            ieo: new_ieo
        });

        event::emit(GOPAttributesUpdated {
            claimed: new_claimed,
            airdrop: new_airdrop,
            ieo: new_ieo
        })
    }

    /// transfer AdminCap to new_owner
    public entry fun transfer_admin_cap(admin_cap: AdminCap, new_owner: address, _: &mut TxContext) {
        transfer::transfer(admin_cap, new_owner);
    }

    /// transfer publisher object to new_owner
    public entry fun transfer_publisher_object(_: &AdminCap, publisher_object: package::Publisher ,new_owner: address, _: &mut TxContext) {
        transfer::public_transfer(publisher_object, new_owner);
    }

    /// transfer Upgrade to new_owner
    public entry fun transfer_upgrade_cap(_: &AdminCap, upgradeCap: package::UpgradeCap ,new_owner: address, _: &mut TxContext) {
        transfer::public_transfer(upgradeCap, new_owner);
    }

    // === Test Functions ===

    #[test_only]
    public fun test_init(
        ctx: &mut TxContext
    ) {
        init(GOP{},ctx);
    }
}