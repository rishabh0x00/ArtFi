#[allow(lint(share_owned, self_transfer))]
module collection::nft {

    // === Imports ===

    use sui::display;
    use sui::event;
    use sui::object::{Self, ID, UID};
    use sui::package;
    use std::string::{Self, String};
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};
    use sui::url::{Self, Url};
    use std::vector;
    use sui::vec_map;

    use collection::base_nft;

    // ===== Error code ===== 

    const ELengthNotEqual: u64 = 1;

    // === Structs ===

    struct ArtfiNFT has key, store {
        id: UID,
        fraction_id: u64,
        /// Name for the token
        name: String,
        /// URL for the token
        url: Url
    }

    struct Royalty has store, copy, drop {
        artfi: u64,
        artist: u64,
        staking_contract: u64
    }

    struct NFTInfo has key, store {
        id: UID,
        name: String,
        royalty_nft: vec_map::VecMap<ID, Royalty>,
        default_royalty: Royalty
    }

    struct AdminCap has key {
        id: UID
    }

    struct MinterCap has key {
        id: UID
    }

    // ===== Events =====

    struct RoyaltyUpdated has copy, drop {
        artfi: u64,
        artist: u64,
        staking_contract: u64,
    }

    /// One-Time-Witness for the module.
    struct NFT has drop {}

    // ===== Public view functions =====

    /// Get the NFT's `name`
    public fun name(nft: &ArtfiNFT): &String {
        &nft.name
    }

    /// Get the NFT's `url`
    public fun url(nft: &ArtfiNFT): &Url {
        &nft.url
    }

    /// Get the NFT's `ID`
    public fun id(nft: &ArtfiNFT): ID {
        object::id(nft)
    }

    /// Get Royalty of the NFT
    public fun royalty(nft: &ArtfiNFT, nft_info: &NFTInfo): Royalty {
        *(vec_map::get(&nft_info.royalty_nft, &object::id(nft)))
    }

    /// Get artfi Royalty of the NFT
    public fun artfi_royalty(nft: &ArtfiNFT, nft_info: &NFTInfo): u64 {
        vec_map::get(&nft_info.royalty_nft, &object::id(nft)).artfi
    }

    /// Get artist Royalty of the NFT
    public fun artist_royalty(nft: &ArtfiNFT, nft_info: &NFTInfo): u64 {
        vec_map::get(&nft_info.royalty_nft, &object::id(nft)).artist
    }

    /// Get staking contract Royalty of the NFT
    public fun staking_contract_royalty(nft: &ArtfiNFT, nft_info: &NFTInfo): u64 {
        vec_map::get(&nft_info.royalty_nft, &object::id(nft)).staking_contract
    }

    // ===== Entrypoints =====

    /// Module initializer is called only once on module publish.
    fun init(otw: NFT, ctx: &mut TxContext) {
        let keys = vector[
            string::utf8(b"name"),
            string::utf8(b"description"),
        ];

        let values = vector[
            // For `name` one can use the `ArtfiNFT.name` property
            string::utf8(b"Artfi"),
            // Description is static for all `ArtfiNFT` objects.
            string::utf8(b"Artfi NFT"),
        ];

        // Claim the `Publisher` for the package!
        let publisher = package::claim(otw, ctx);

        // Get a new `Display` object for the `ArtfiNFT` type.
        let display_object = display::new_with_fields<ArtfiNFT>(
            &publisher, keys, values, ctx
        );

        // Commit first version of `Display` to apply changes.
        display::update_version(&mut display_object);

        transfer::public_transfer(publisher, tx_context::sender(ctx));
        transfer::public_transfer(display_object, tx_context::sender(ctx));

        transfer::share_object(NFTInfo{
            id: object::new(ctx),
            name: string::utf8(b"Artfi"),
            royalty_nft: vec_map::empty<ID, Royalty>(),
            default_royalty: Royalty{
                artfi: 4,
                artist: 3,
                staking_contract: 3 
            }
        });

        transfer::transfer(AdminCap {
            id: object::new(ctx)
        }, tx_context::sender(ctx));

        transfer::transfer(MinterCap {
            id: object::new(ctx)
        }, tx_context::sender(ctx));
    }

    // === Public-Mutative Functions ===

    /// Permanently delete `nft`
    public entry fun burn(nft: ArtfiNFT, nft_info: &mut NFTInfo, _: &mut TxContext) {
        let _id = object::id(&nft);
        let (_burn_id, _burn_royalty) = vec_map::remove(&mut nft_info.royalty_nft, &_id);
        
        let ArtfiNFT { id, fraction_id: _, name: _, url: _ } = nft;
        object::delete(id);
    }

    // === AdminCap Functions ===

    /// Update the defualt royalty
    public entry fun update_royalty(
        _: &MinterCap,
        nft_info: &mut NFTInfo,
        new_artfi: u64,
        new_artist: u64,
        new_staking_contract: u64,
        _: &mut TxContext
    ) {
        nft_info.default_royalty.artfi = new_artfi;
        nft_info.default_royalty.artist = new_artist;
        nft_info.default_royalty.staking_contract = new_staking_contract;

        event::emit(RoyaltyUpdated {
            artfi: new_artfi,
            artist: new_artist,
            staking_contract: new_staking_contract
        })
    }

    /// Update the defualt royalty
    public entry fun update_nft_royalty(
        _: &MinterCap,
        nft_info: &mut NFTInfo,
        id: ID,
        new_artfi: u64,
        new_artist: u64,
        new_staking_contract: u64,
        _: &mut TxContext
    ) {
        base_nft::update_attribute(&mut nft_info.royalty_nft, id, Royalty{
            artfi: new_artfi,
            artist: new_artist,
            staking_contract: new_staking_contract
        });
    }

    /// Update the metadata of the NFT's
    public fun update_metadata(
        _: &AdminCap,
        display_object: &mut display::Display<ArtfiNFT>,
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

    /// Create a new nft
    public entry fun mint_nft(
        _: &MinterCap,
        nft_info: &mut NFTInfo,
        url: vector<u8>,
        user: address,
        fraction_id: u64,
        ctx: &mut TxContext
    ) { 
        let id: ID = mint_func(
            url,
            user,
            fraction_id,
            nft_info,
            ctx
        );

        base_nft::emit_mint_nft(id, tx_context::sender(ctx), nft_info.name);
    }
    
    /// Create a multiple nft
    public fun mint_nft_batch(
        _: &MinterCap,
        nft_info: &mut NFTInfo,
        uris: &vector<vector<u8>>,
        user: &vector<address>,
        fraction_ids: &vector<u64>,
        ctx: &mut TxContext
    ) {
        let lengthOfVector = vector::length(uris);
        assert!(lengthOfVector == vector::length(fraction_ids), ELengthNotEqual);
        assert!(lengthOfVector == vector::length(user), ELengthNotEqual);

        let ids: vector<ID> = vector[];
        let index = 0;

        while (index < lengthOfVector) {
            let id = mint_func(
                *vector::borrow(uris, index),
                *vector::borrow(user, index), 
                *vector::borrow(fraction_ids, index),
                nft_info,
                ctx
            );

            index = index + 1;
            vector::push_back(&mut ids, id);
        };

        base_nft::emit_batch_mint_nft(ids, lengthOfVector, tx_context::sender(ctx), nft_info.name);
    }

    /// transfer AdminCap to new_owner
    public entry fun transfer_admin_cap(admin_cap: AdminCap, new_owner: address, _: &mut TxContext) {
        transfer::transfer(admin_cap, new_owner);
    }

    /// transfer new instance of MinterCap to minter_owner
    public entry fun transfer_minter_cap(_: &AdminCap, minter_owner: address, ctx: &mut TxContext) {
        transfer::transfer(MinterCap {
            id: object::new(ctx)
        }, minter_owner);
    }

    // === Private Functions ===
    
    fun mint_func(
        url: vector<u8>,
        user: address,
        fraction_id: u64,
        nft_info: &mut NFTInfo,
        ctx: &mut TxContext
     ) : ID {
        let nft = ArtfiNFT {
            id: object::new(ctx),
            fraction_id,
            name: nft_info.name,
            url: url::new_unsafe_from_bytes(url)
        };

        let _id = object::id(&nft);
        vec_map::insert(&mut nft_info.royalty_nft, _id, Royalty{
            artfi: nft_info.default_royalty.artfi, 
            artist: nft_info.default_royalty.artist, 
            staking_contract: nft_info.default_royalty.staking_contract
        });

        transfer::public_transfer(nft, user);
        _id
    }  

    // === Test Functions ===

    #[test_only]
    public fun new_artfi_nft(
        name: String,
        url: Url,
        fraction_id: u64,
        nft_info: &mut NFTInfo,
        ctx: &mut TxContext
    ): ArtfiNFT {
        let nft = ArtfiNFT {
            id: object::new(ctx),
            fraction_id,
            name: name,
            url: url
        };

        let _id = object::id(&nft);
        vec_map::insert(&mut nft_info.royalty_nft, _id, Royalty{
            artfi: nft_info.default_royalty.artfi, 
            artist: nft_info.default_royalty.artist, 
            staking_contract: nft_info.default_royalty.staking_contract
        });

        nft
    }

    #[test_only]
    public fun new_royalty(artfi: u64, artist: u64, staking_contract: u64): Royalty {
        Royalty {
            artfi, artist, staking_contract
        }
    }

    #[test_only]
    public fun new_nft_info(name: String, royalty: Royalty): NFTInfo {
        NFTInfo {
            id: object::new(&mut tx_context::dummy()), name, royalty_nft: vec_map::empty<ID, Royalty>(), default_royalty: royalty
        }
    }

    #[test_only]
    public fun get_default_royalty_fields(
        royalty: &NFTInfo
    ): (u64, u64, u64) {
        (royalty.default_royalty.artfi, royalty.default_royalty.artist, royalty.default_royalty.staking_contract)
    }
    
    #[test_only]
    public fun test_init(
        ctx: &mut TxContext
    ) {
        init(NFT{},ctx);
    }

    #[test_only]
    public fun description(display: &display::Display<ArtfiNFT>): String {
        let fields = display::fields(display);
        *vec_map::get(fields, &string::utf8(b"description"))
    }
}
