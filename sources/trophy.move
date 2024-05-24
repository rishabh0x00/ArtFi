#[allow(lint(share_owned, self_transfer))]
module collection::trophy {

    // === Imports ===

    use std::string::{Self, String};

    use sui::display;
    use sui::object::{Self, ID, UID};
    use sui::package;
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};
    use sui::vec_map;
    use sui::url::{Self, Url};

    use collection::base_nft;
    use collection::nft;

    // ===== Error code ===== 

    const EAlreadyExist: u64 = 1;

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
        id_detials: vec_map::VecMap<ID, Attributes>,
        fraction_exist: vec_map::VecMap<u64,ID>,
    }

    struct Attributes has store, copy, drop {
        fraction_id: u64,
        shipment_status: String
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
            id_detials: vec_map::empty<ID, Attributes>(), 
            fraction_exist: vec_map::empty<u64, ID>() 
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

    /// Get Attributes of the NFT
    public fun attributes(nft: &TrophyNFT, nft_info: &NFTInfo): Attributes{
        *(vec_map::get(&nft_info.id_detials, &object::id(nft)))
    }

    /// Get shipment status of the NFT
    public fun shipment_status(nft: &TrophyNFT, nft_info: &NFTInfo): String {
        vec_map::get(&nft_info.id_detials, &object::id(nft)).shipment_status
    }

    /// Get shipment status of the NFT
    public fun fraction_id(nft: &TrophyNFT, nft_info: &NFTInfo): u64 {
        vec_map::get(&nft_info.id_detials, &object::id(nft)).fraction_id
    }

    /// Get shipment status of the NFT
    public fun fraction_to_nft_id(fraction_id: u64, nft_info: &NFTInfo): ID {
        *vec_map::get(&nft_info.fraction_exist, &fraction_id)
    }

    // === Public-Mutative Functions ===

    /// Create a new Trophy
    public entry fun mint_nft(
        nft_info: &mut NFTInfo,
        nft_object: &nft::ArtfiNFT,
        url: vector<u8>,
        ctx: &mut TxContext
    ) { 
        let fraction_id = nft::fraction_id(nft_object);
        assert!(check_fraction_exist(nft_info,  fraction_id) == false, EAlreadyExist);

        let id: ID = mint_func(
            nft_info,
            url,
            fraction_id,
            ctx
        );

        base_nft::emit_mint_nft(id, tx_context::sender(ctx), nft_info.name);
    }

    /// Permanently delete `NFT`
    public entry fun burn(nft: TrophyNFT, nft_info: &mut NFTInfo, _: &mut TxContext) {
        let _id = object::id(&nft);
        let (_burn_id, _burn_attributes) = vec_map::remove(&mut nft_info.id_detials, &_id);
        
        let TrophyNFT { id, name: _, url: _ } = nft;
        object::delete(id);
    }

    // === AdminCap Functions ===

    /// Update the metadata of the NFT's
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
        new_shipment_status: String,
    ) { 
        let value = vec_map::get_mut(&mut nft_info.id_detials, &id);
        value.shipment_status = new_shipment_status;

        base_nft::emit_update_attributes(id, *value);
    }

    /// transfer AdminCap to new_owner
    public entry fun transfer_admin_cap(admin_cap: AdminCap, new_owner: address, _: &mut TxContext) {
        transfer::transfer(admin_cap, new_owner);
    }

    // === Private Functions ===

    fun check_fraction_exist(
        mint_counter: &NFTInfo,
        fraction_id: u64,
    ): bool {
        vec_map::contains(&mint_counter.fraction_exist, &fraction_id)
    } 
    
    fun mint_func(
        nft_info: &mut NFTInfo,
        url: vector<u8>,
        fraction_id: u64,
        ctx: &mut TxContext
     ) : ID {
        let nft = TrophyNFT{
            id: object::new(ctx),
            name: nft_info.name,
            url: url::new_unsafe_from_bytes(url)
        };

        let _id = object::id(&nft);

        vec_map::insert(&mut nft_info.id_detials, _id, Attributes{
            fraction_id,
            shipment_status: string::utf8(b"")
        });

        vec_map::insert(&mut nft_info.fraction_exist, fraction_id, _id);

        transfer::public_transfer(nft, tx_context::sender(ctx));
        _id
    }

    // === Test Functions ===

    #[test_only]
    public fun new_trophy_nft(
        name: String,
        url: Url,
        nft_info: &mut NFTInfo,
        fraction_id: u64,
        ctx: &mut TxContext
    ): TrophyNFT {
        let nft = TrophyNFT {
            id: object::new(ctx),
            name: name,
            url: url
        };

        let _id = object::id(&nft);
        vec_map::insert(&mut nft_info.id_detials, _id, Attributes{
            fraction_id,
            shipment_status: string::utf8(b""), 
        });

        nft
    }

    #[test_only]
    public fun new_attributes(fraction_id: u64, shipment_status: String): Attributes {
        Attributes {
            fraction_id,
            shipment_status
        }
    }

    #[test_only]
    public fun new_nft_info(name: String): NFTInfo {
        NFTInfo {
            id: object::new(&mut tx_context::dummy()), name, id_detials: vec_map::empty<ID, Attributes>(), fraction_exist: vec_map::empty<u64,ID>(),
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
