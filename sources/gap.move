#[allow(lint(share_owned, self_transfer))]
module collection::gap {

    // === Imports ===

    use std::string::{Self, String};
    use std::vector;

    use sui::display;
    use sui::object::{Self, ID, UID};
    use sui::package;
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};
    use sui::vec_map;
    use sui::url::{Self, Url};

    use collection::base_nft;

    // ===== Error code ===== 

    const ELengthNotEqual: u64 = 2;

    // === Structs ===

    struct GAPNFT has key, store {
        id: UID,
        /// Name for the token
        name: String,
        /// URL for the token
        url: Url
    }

    struct NFTInfo has key, store {
        id: UID,
        name: String,
        user_detials: vec_map::VecMap<ID, Attributes>,
        user_token_id: vec_map::VecMap<address,ID>,
    }

    struct Attributes has store, copy, drop {
        ieo: bool
    }

    struct AdminCap has key {
        id: UID
    }

    /// One-Time-Witness for the module.
    struct GAP has drop {}

    // ===== Entrypoints =====

    /// Module initializer is called only once on module publish.
    fun init(otw: GAP, ctx: &mut TxContext) {
        let keys = vector[
            string::utf8(b"name"),
            string::utf8(b"description"),
        ];

        let values = vector[
            // For `name` one can use the `GAPNFT.name` property
            string::utf8(b"Artfi"),
            // Description is static for all `GAPNFT` objects.
            string::utf8(b"Artfi NFT"),
        ];

        // Claim the `Publisher` for the package!
        let publisher = package::claim(otw, ctx);

        // Get a new `Display` object for the `GAPNFT` type.
        let display_object = display::new_with_fields<GAPNFT>(
            &publisher, keys, values, ctx
        );

        // Commit first version of `Display` to apply changes.
        display::update_version(&mut display_object);

        transfer::public_transfer(publisher, tx_context::sender(ctx));
        transfer::public_transfer(display_object, tx_context::sender(ctx));

        transfer::share_object(NFTInfo {
            id: object::new(ctx),
            name: string::utf8(b"Artfi"),
            user_detials: vec_map::empty<ID, Attributes>(),  
            user_token_id: vec_map::empty<address, ID>()
        });

        transfer::transfer(AdminCap {
            id: object::new(ctx)
        }, tx_context::sender(ctx));
    }

    // ===== Public view functions =====

    /// Get the NFT's `name`
    public fun name(nft: &GAPNFT): &String {
        &nft.name
    }

    /// Get the NFT's `url`
    public fun url(nft: &GAPNFT): &Url {
        &nft.url
    }

    /// Get ID of the NFT
    public fun id(nft: &GAPNFT): ID {
        object::id(nft)
    }

    /// Get Attributes of the NFT
    public fun attributes(nft: &GAPNFT, nft_info: &NFTInfo): Attributes{
        *(vec_map::get(&nft_info.user_detials, &object::id(nft)))
    }

    /// Get ieo attributes of the NFT
    public fun ieo(nft: &GAPNFT, nft_info: &NFTInfo): bool {
        vec_map::get(&nft_info.user_detials, &object::id(nft)).ieo
    }

    /// Get minted token id at user address
    public fun count(nft_info: &NFTInfo, user: address): ID {
        *vec_map::get(&nft_info.user_token_id, &user)
    }

    // === Public-Mutative Functions ===

    /// Permanently delete `nft`
    /// Only nft owner can call this function
    /// Emits a NFTBurned for object type GAPNFT
    public entry fun burn(nft: GAPNFT, nft_info: &mut NFTInfo, _: &mut TxContext) {
        let _id = object::id(&nft);
        let (_burn_id, _burn_attributes) = vec_map::remove(&mut nft_info.user_detials, &_id);
        
        let GAPNFT { id, name: _, url: _ } = nft;
        object::delete(id);

        base_nft::emit_burn_nft<GAPNFT>(_id);
    }

    /// Transfer `nft` to `recipient`
    /// Only nft owner can call this function
    /// Emits a TransferredObject for object type GAPNFT
    public entry fun transfer_nft(
        nft: GAPNFT, recipient: address, _: &mut TxContext
    ) {
        let _id = object::id(&nft);
        transfer::public_transfer(nft, recipient);

        base_nft::emit_transfer_object<GAPNFT>(_id, recipient);
    }

    // === AdminCap Functions ===
    
    /// Create a multiple GAP and tranfer to user
    /// Can only be called by the owner, which has admin cap object
    /// Emits a NFTBatchMinted event
    public fun mint_nft_batch(
        _: &AdminCap,
        nft_info: &mut NFTInfo,
        uris: &vector<vector<u8>>,
        user: &vector<address>,
        ctx: &mut TxContext
    ) {
        let lengthOfVector = vector::length(uris);
        assert!(lengthOfVector == vector::length(user), ELengthNotEqual);
        let ids: vector<ID> = vector[];
        let index = 0;

        while (index < lengthOfVector) {
            let user_address = *vector::borrow(user, index);
            if (!check_token_exist_on_address(nft_info, user_address)) {
                let id: ID = mint_func(
                    nft_info,
                    *vector::borrow(uris, index),
                    user_address,
                    ctx
                );

                vector::push_back(&mut ids, id);
            };

            index = index + 1;
        };

        base_nft::emit_batch_mint_nft(ids, lengthOfVector, tx_context::sender(ctx), nft_info.name);
    }

    /// Update the metadata of the NFT's
    /// Can only be called by the owner, which has admin cap object
    /// Emits an NFTMetadataUpdated event
    public fun update_metadata(
        _: &AdminCap,
        display_object: &mut display::Display<GAPNFT>,
        nft_info: &mut NFTInfo,
        new_description: String,
        new_name: String
    ) {
        display::edit(display_object, string::utf8(b"name"), new_name);
        display::edit(display_object, string::utf8(b"description"), new_description);

        nft_info.name = new_name;

        display::update_version(display_object);

        base_nft::emit_metadat_update(new_name, new_description);
    }

    /// Update the nft attributes
    /// Can only be called by the owner, which has admin cap object
    /// Emits an AttributesUpdated event
    public entry fun update_attribute(
        _: &AdminCap,
        nft_info: &mut NFTInfo,
        id: ID,
        new_ieo: bool
    ) {
        base_nft::update_attribute(&mut nft_info.user_detials, id, Attributes{
            ieo: new_ieo
        });
    }

    /// Transfer admin cap to new_owner
    /// Can only be called by user, who ownes admin cap
    /// Emits a TransferredObject event for object type AdminCap
    public entry fun transfer_admin_cap(admin_cap: AdminCap, new_owner: address, _: &mut TxContext) {
        let _id = object::id(&admin_cap);
        transfer::transfer(admin_cap, new_owner);

        base_nft::emit_transfer_object<AdminCap>(_id, new_owner);
    }

    // === Private Functions ===

    fun check_token_exist_on_address(
        nft_info: &NFTInfo,
        user: address
    ): bool {
        vec_map::contains(&nft_info.user_token_id, &user)
    } 
    
    fun mint_func(
        nft_info: &mut NFTInfo,
        url: vector<u8>,
        user: address,
        ctx: &mut TxContext
     ) : ID {
        let nft = GAPNFT{
            id: object::new(ctx),
            name: nft_info.name,
            url: url::new_unsafe_from_bytes(url)
        };

        let _id = object::id(&nft);

        vec_map::insert(&mut nft_info.user_detials, _id, Attributes{
            ieo: false
        });

        vec_map::insert(&mut nft_info.user_token_id, user, _id);

        transfer::public_transfer(nft, user);
        _id
    }

    // === Test Functions ===

    #[test_only]
    public fun new_gap_nft(
        name: String,
        url: Url,
        nft_info: &mut NFTInfo,
        ctx: &mut TxContext
    ): GAPNFT {
        let nft = GAPNFT {
            id: object::new(ctx),
            name: name,
            url: url
        };

        let _id = object::id(&nft);
        vec_map::insert(&mut nft_info.user_detials, _id, Attributes{
            ieo: false
        });

        nft
    }

    #[test_only]
    public fun new_attributes(ieo: bool): Attributes {
        Attributes {
            ieo
        }
    }

    #[test_only]
    public fun new_nft_info(name: String): NFTInfo {
        NFTInfo {
            id: object::new(&mut tx_context::dummy()), name, user_detials: vec_map::empty<ID, Attributes>(), user_token_id: vec_map::empty<address, ID>()
        }
    }

    #[test_only]
    public fun description(display: &display::Display<GAPNFT>): String {
        let fields = display::fields(display);
        *vec_map::get(fields, &string::utf8(b"description"))
    }

    #[test_only]
    public fun test_init(
        ctx: &mut TxContext
    ) {
        init(GAP{},ctx);
    }
}
