#[allow(lint(share_owned, self_transfer))]
module collection::gop {

    // === Imports ===

    use std::string::{Self, String};
    use std::vector;

    use sui::display;
    use sui::dynamic_object_field as ofield;
    use sui::event;
    use sui::object::{Self, ID, UID};
    use sui::package;
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};
    use sui::url::{Self, Url};
    use sui::vec_map;

    // ===== Error code ===== 

    const ENotOwner: u64 = 2;

    // === Structs ===

    struct GopNFT has key, store {
        id: UID,
        /// Name for the GOP token
        name: String,
        /// Description of the GOP token
        description: String,
        /// URL for the token
        url: Url,
        /// owner of GOP token
        owner: address,
        claimed: bool,
        airdrop: bool,
        ieo: bool
    }

    struct AdminCap has key {
        id: UID
    }

    struct DynamicField<T: store + copy + drop> has key, store {
        id: UID,
        value: T
    }

    // ===== Events =====

    struct NFTMinted has copy, drop {
        // The Object ID of the GOP
        token_id: ID,
        // The creator of the GOP
        creator: address,
        // The name of the GOP
        name: String,
    }

    struct NFTBatchMinted has copy, drop {
        // The Object IDs of Batch Minted GOPs
        token_ids: vector<ID>,
        // The creator of the GOP
        creator: address,
        // The name of the GOP
        name: String,
        // number of tokens
        no_of_tokens: u64
    }

    struct NFTMetadataUpdated has copy, drop {
        /// Name for the token
        name: String,
        /// Description of the token
        description: String,
    }

    /// One-Time-Witness for the module.
    struct GOP has drop {}

    // ===== Public view functions =====

    /// Get the GOP's `name`
    public fun name(nft: &GopNFT): &String {
        &nft.name
    }

    /// Get the GOP's `description`
    public fun description(nft: &GopNFT): &String {
        &nft.description
    }

    /// Get the GOP's `url`
    public fun url(nft: &GopNFT): &Url {
        &nft.url
    }

    /// Get the GOP's `ID`
    public fun id(nft: &GopNFT): ID {
        object::id(nft)
    }

    /// Get the GOP's `owner`
    public fun owner(nft: &GopNFT): &address {
        &nft.owner 
    }

    // ===== Entrypoints =====

    /// Module initializer is called only once on module publish.
    fun init(otw: GOP, ctx: &mut TxContext) {
        let keys = vector[
            string::utf8(b"name"),
            string::utf8(b"description"),
        ];

        let values = vector[
            // For `name` one can use the `GopNFT.name` property
            string::utf8(b"Artfi"),
            // Description is static for all `GopNFT` objects.
            string::utf8(b"Artfi_NFT"),
        ];

        // Claim the `Publisher` for the package!
        let publisher = package::claim(otw, ctx);

        // Get a new `Display` object for the `GopNFT` type.
        let display_object = display::new_with_fields<GopNFT>(
            &publisher, keys, values, ctx
        );

        // Commit first version of `Display` to apply changes.
        display::update_version(&mut display_object);

        transfer::public_transfer(publisher, tx_context::sender(ctx));
        transfer::public_share_object(display_object);

        transfer::transfer(AdminCap {
            id: object::new(ctx)
        }, tx_context::sender(ctx));
    }

    // === Public-Mutative Functions ===

    /// Create a new GOP
    public entry fun mint_nft(
        display_object: &display::Display<GopNFT>,
        url: vector<u8>,
        ctx: &mut TxContext
    ) { 
        let display_fields = display::fields(display_object);
        let display_name = vec_map::get(display_fields, &string::utf8(b"name"));
        let display_description = vec_map::get(display_fields, &string::utf8(b"description"));

        let id: ID = mint_func(
            *display_name,
            *display_description,
            url,
            ctx
        );

        event::emit(NFTMinted {
            token_id: id,
            creator: tx_context::sender(ctx),
            name: *display_name,
        });
    }
    
    /// Create a multiple GOP
    public fun mint_nft_batch(
        display_object: &display::Display<GopNFT>,
        uris: &vector<vector<u8>>,
        ctx: &mut TxContext
    ) {
        let lengthOfVector = vector::length(uris);
        let ids: vector<ID> = vector[];
        let index = 0;

        let display_fields = display::fields(display_object);
        let display_name = vec_map::get(display_fields, &string::utf8(b"name"));
        let display_description = vec_map::get(display_fields, &string::utf8(b"description"));

        while (index < lengthOfVector) {
            let id = mint_func(
                *display_name,
                *display_description,
                *vector::borrow(uris, index),
                ctx
            );

            index = index + 1;
            vector::push_back(&mut ids, id);
        };

        event::emit(NFTBatchMinted {
            token_ids: ids,
            creator: tx_context::sender(ctx),
            name: *display_name,
            no_of_tokens: lengthOfVector
        });
    }

    /// Permanently delete `GOP`
    public entry fun burn(nft: GopNFT, ctx: &mut TxContext) {
        assert!(tx_context::sender(ctx) == nft.owner, ENotOwner);
        let GopNFT { id, name: _, description: _, url: _ , owner: _, airdrop: _, claimed: _, ieo: _} = nft;
        object::delete(id);
    }

    /// Transfer `GOP` to `recipient`
    public entry fun transfer_nft(
        nft: &mut GopNFT, recipient: address, ctx: &mut TxContext
    ) {
        assert!(nft.owner == tx_context::sender(ctx), ENotOwner);
        nft.owner = recipient;
    }

    // === AdminCap Functions ===

    /// Update the metadata of `GOP`
    public entry fun update_metadata(
        _: &AdminCap,
        display_object: &mut display::Display<GopNFT>,
        new_description: String,
        new_name: String,
        _: &mut TxContext
    ) {
        display::edit(display_object, string::utf8(b"name"), new_name);
        display::edit(display_object, string::utf8(b"description"), new_description);

        display::update_version(display_object);

        event::emit(NFTMetadataUpdated {
            name: new_name,
            description: new_description,
        })
    }

    /// add field in display object
    entry fun add_display_field(
        _: &AdminCap,
        display_object: &mut display::Display<GopNFT>,
        name: String,
        value: String,
        _: &mut TxContext
    ) {
        display::add(display_object, name, value);
        display::update_version(display_object);
    }

    /// remove field from display object
    entry fun remove_display_field(
        _: &AdminCap,
        display_object: &mut display::Display<GopNFT>,
        name: String,
        _: &mut TxContext
    ) {
        display::remove(display_object, name);
        display::update_version(display_object);
    }

    /// remove field from display object
    entry fun update_display_field(
        _: &AdminCap,
        display_object: &mut display::Display<GopNFT>,
        key: String,
        value: String,
        _: &mut TxContext
    ) {
        display::edit(display_object, key, value);
        display::update_version(display_object);
    }

    /// add field in dynamic object
    public entry fun add_dynamic_attribute<T: store + copy + drop, Name: copy + store + drop>(
        _: &AdminCap,
        nft: &mut GopNFT,
        key: Name,
        value: T,
        ctx: &mut TxContext
    ) {
        ofield::add(&mut nft.id, key, DynamicField{
            id: object::new(ctx),
            value
        });
    }

    /// remove field from dynamic object
    public entry fun remove_dynamice_attribute<T: store + copy + drop, Name: copy + drop + store>(
        _: &AdminCap,
        nft: &mut GopNFT,
        key: Name,
        _: &mut TxContext
    ): T {
        
        let DynamicField<T> {
            id,
            value
        } = ofield::remove(&mut nft.id, key);

        object::delete(id);
        value
    }

    /// update field of dynamic object
    public entry fun update_dynamice_attribute<T: store + copy + drop, Name: copy + drop + store>(
        _: &AdminCap,
        nft: &mut GopNFT,
        key: Name,
        new_value: T,
        _: &mut TxContext
    ) {
        let dynamice_field: &mut DynamicField<T> = ofield::borrow_mut(&mut nft.id, key);
        dynamice_field.value = new_value;
    }

    public entry fun update_attribute(
        _: &AdminCap,
        nft: &mut GopNFT,
        claimed: bool,
        airdrop: bool,
        ieo: bool
    ) {
        nft.claimed = claimed;
        nft.airdrop = airdrop;
        nft.ieo = ieo;
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

    // === Private Functions ===
    
    fun mint_func(
        name: String,
        description: String,
        url: vector<u8>,
        ctx: &mut TxContext
     ) : ID {
        let nft = GopNFT {
            id: object::new(ctx),
            name: name,
            description: description,
            url: url::new_unsafe_from_bytes(url),
            owner: tx_context::sender(ctx),
            airdrop: false,
            claimed: false,
            ieo: false
        };

        let _id = object::id(&nft);
        transfer::share_object(nft);
        _id
    }  

    // === Test Functions ===

    #[test_only]
    public fun new_artfi_nft(
        name: String,
        description: String,
        url: Url,
        ctx: &mut TxContext
    ): GopNFT {
        GopNFT {
            id: object::new(ctx),
            name: name,
            description: description,
            url: url,
            owner: tx_context::sender(ctx),
            airdrop: false,
            claimed: false,
            ieo: false
        }
    }
    
    #[test_only]
    public fun test_init(
        ctx: &mut TxContext
    ) {
        init(GOP{},ctx);
    }
}