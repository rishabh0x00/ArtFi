#[allow(lint(share_owned, self_transfer))]
module collection::trophy {

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

    const ELimitExceed: u64 = 1;

    // === Structs ===

    struct TrophyNFT has key, store {
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
    }

    struct Attributes has store, copy, drop {
        shipment_status: String
    }

    struct NftCounter has key, store {
        id: UID,
        count: vec_map::VecMap<address,u64>,
    }

    struct AdminCap has key {
        id: UID
    }

    /// One-Time-Witness for the module.
    struct TROPHY has drop {}

    // ===== Entrypoints =====

    /// Module initializer is called only once on module publish.
    fun init(otw: TROPHY, ctx: &mut TxContext) {
        let keys = vector[
            string::utf8(b"name"),
            string::utf8(b"description"),
        ];

        let values = vector[
            // For `name` one can use the `TrophyNFT.name` property
            string::utf8(b"Artfi"),
            // Description is static for all `TrophyNFT` objects.
            string::utf8(b"Artfi NFT"),
        ];

        // Claim the `Publisher` for the package!
        let publisher = package::claim(otw, ctx);

        // Get a new `Display` object for the `TrophyNFT` type.
        let display_object = display::new_with_fields<TrophyNFT>(
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
        });

        transfer::share_object(NftCounter{
            id: object::new(ctx),
            count: vec_map::empty<address, u64>()
        });

        transfer::transfer(AdminCap {
            id: object::new(ctx)
        }, tx_context::sender(ctx));
    }

    // ===== Public view functions =====

    /// Get the NFT's `name`
    public fun name(nft: &TrophyNFT): &String {
        &nft.name
    }

    /// Get the NFT's `url`
    public fun url(nft: &TrophyNFT): &Url {
        &nft.url
    }

    /// Get the NFT's `ID`
    public fun id(nft: &TrophyNFT): ID {
        object::id(nft)
    }

    /// Get Attributes of NFT's
    public fun attributes(nft: &TrophyNFT, nft_info: &NFTInfo): Attributes{
        *(vec_map::get(&nft_info.user_detials, &object::id(nft)))
    }

    /// Get shipment status of NFT's
    public fun shipment_status(nft: &TrophyNFT, nft_info: &NFTInfo): String {
        vec_map::get(&nft_info.user_detials, &object::id(nft)).shipment_status
    }

    // === Public-Mutative Functions ===

    /// Create a new Trophy
    public entry fun mint_nft(
        nft_info: &mut NFTInfo,
        mint_counter: &mut NftCounter,
        user: address,
        url: vector<u8>,
        ctx: &mut TxContext
    ) { 
        check_mint_limit(mint_counter, user);

        let id: ID = mint_func(
            nft_info,
            url,
            user,
            ctx
        );

        base_nft::emit_mint_nft(id, tx_context::sender(ctx), nft_info.name);
    }

    /// Permanently delete `NFT`
    public entry fun burn(nft: TrophyNFT, nft_info: &mut NFTInfo, _: &mut TxContext) {
        let _id = object::id(&nft);
        let (_burn_id, _burn_attributes) = vec_map::remove(&mut nft_info.user_detials, &_id);
        
        let TrophyNFT { id, name: _, url: _ } = nft;
        object::delete(id);
    }

    // === AdminCap Functions ===
    
    /// Create a multiple Trophy
    public fun mint_nft_batch(
        _: &AdminCap,
        nft_info: &mut NFTInfo,
        mint_counter: &mut NftCounter,
        uris: &vector<vector<u8>>,
        user: &vector<address>,
        ctx: &mut TxContext
    ) {
        let lengthOfVector = vector::length(uris);
        let ids: vector<ID> = vector[];
        let index = 0;

        while (index < lengthOfVector) {
            check_mint_limit(mint_counter, *vector::borrow(user, index));
            let id: ID = mint_func(
                nft_info,
                *vector::borrow(uris, index),
                *vector::borrow(user, index),
                ctx
            );

            index = index + 1;
            vector::push_back(&mut ids, id);
        };

        base_nft::emit_batch_mint_nft(ids, lengthOfVector, tx_context::sender(ctx), nft_info.name);
    }

    /// Update the metadata of `NFT`
    public fun update_metadata(
        _: &AdminCap,
        display_object: &mut display::Display<TrophyNFT>,
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

    public entry fun update_attribute(
        _: &AdminCap,
        nft_info: &mut NFTInfo,
        id: ID,
        shipment_status: String,
    ) {
        base_nft::update_attribute(&mut nft_info.user_detials, id, Attributes{
            shipment_status: shipment_status,
        });
    }

    /// transfer AdminCap to new_owner
    public entry fun transfer_admin_cap(admin_cap: AdminCap, new_owner: address, _: &mut TxContext) {
        transfer::transfer(admin_cap, new_owner);
    }

    // === Private Functions ===

    fun check_mint_limit(
        mint_counter: &mut NftCounter,
        user: address
    ) {
        if (vec_map::contains(&mint_counter.count, &user)) {
            assert!(*(vec_map::get(&mint_counter.count, &user)) <= 1,ELimitExceed);
            let counter = vec_map::get_mut(&mut mint_counter.count, &user);
            *counter = *counter + 1;
        } else {
            vec_map::insert(&mut mint_counter.count, user, 1);
        };
    } 
    
    fun mint_func(
        nft_info: &mut NFTInfo,
        url: vector<u8>,
        user: address,
        ctx: &mut TxContext
     ) : ID {
        let nft = TrophyNFT{
            id: object::new(ctx),
            name: nft_info.name,
            url: url::new_unsafe_from_bytes(url)
        };

        let _id = object::id(&nft);

        vec_map::insert(&mut nft_info.user_detials, _id, Attributes{
            shipment_status: string::utf8(b"")
        });

        transfer::public_transfer(nft, user);
        _id
    }

    // === Test Functions ===

    #[test_only]
    public fun new_trophy_nft(
        name: String,
        url: Url,
        nft_info: &mut NFTInfo,
        ctx: &mut TxContext
    ): TrophyNFT {
        let nft = TrophyNFT {
            id: object::new(ctx),
            name: name,
            url: url
        };

        let _id = object::id(&nft);
        vec_map::insert(&mut nft_info.user_detials, _id, Attributes{
            shipment_status: string::utf8(b""), 
        });

        nft
    }

    #[test_only]
    public fun new_attributes(shipment_status: String): Attributes {
        Attributes {
            shipment_status
        }
    }

    #[test_only]
    public fun new_nft_info(name: String): NFTInfo {
        NFTInfo {
            id: object::new(&mut tx_context::dummy()), name, user_detials: vec_map::empty<ID, Attributes>()
        }
    }

    #[test_only]
    public fun description(display: &display::Display<TrophyNFT>): String {
        let fields = display::fields(display);
        *vec_map::get(fields, &string::utf8(b"description"))
    }

    #[test_only]
    public fun test_init(
        ctx: &mut TxContext
    ) {
        init(TROPHY{},ctx);
    }
}
