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

    // ===== Error code ===== 

    const ELengthNotEqual: u64 = 1;

    // === Structs ===

    struct ArtFiNFT has key, store {
        id: UID,
        fraction_id: u64,
        /// Name for the token
        name: String,
        /// Description of the token
        description: String,
        /// URL for the token
        url: Url
    }

    struct Royalty has store, copy, drop {
        artfi: u64,
        artist: u64,
        staking_contract: u64
    }

    struct RoyaltyInfo has key, store {
        id: UID,
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

    struct NFTMinted has copy, drop {
        // The Object ID of the NFT
        token_id: ID,
        // The creator of the NFT
        creator: address,
        // The name of the NFT
        name: String,
    }

    struct NFTBatchMinted has copy, drop {
        // The Object IDs of Batch Minted NFTs
        token_ids: vector<ID>,
        // The creator of the NFT
        creator: address,
        // The name of the NFT
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

    struct RoyaltyUpdated has copy, drop {
        artfi: u64,
        artist: u64,
        staking_contract: u64,
    }

    struct NFTRoyaltyUpdated has copy, drop {
        nft_id: ID,
        artfi: u64,
        artist: u64,
        staking_contract: u64,
    }

    /// One-Time-Witness for the module.
    struct NFT has drop {}

    // ===== Public view functions =====

    /// Get the NFT's `name`
    public fun name(nft: &ArtFiNFT): &String {
        &nft.name
    }

    /// Get the NFT's `description`
    public fun description(nft: &ArtFiNFT): &String {
        &nft.description
    }

    /// Get the NFT's `url`
    public fun url(nft: &ArtFiNFT): &Url {
        &nft.url
    }

    /// Get the NFT's `ID`
    public fun id(nft: &ArtFiNFT): ID {
        object::id(nft)
    }

    /// Get Royalty of NFT's
    public fun royalty(nft: &ArtFiNFT, royalty_info: &RoyaltyInfo): Royalty {
        *(vec_map::get(&royalty_info.royalty_nft, &object::id(nft)))
    }

    /// Get artfi Royalty of NFT's
    public fun artfi_royalty(nft: &ArtFiNFT, royalty_info: &RoyaltyInfo): u64 {
        vec_map::get(&royalty_info.royalty_nft, &object::id(nft)).artfi
    }

    /// Get artist Royalty of NFT's
    public fun artist_royalty(nft: &ArtFiNFT, royalty_info: &RoyaltyInfo): u64 {
        vec_map::get(&royalty_info.royalty_nft, &object::id(nft)).artist
    }

    /// Get staking contract Royalty of NFT's
    public fun staking_contract_royalty(nft: &ArtFiNFT, royalty_info: &RoyaltyInfo): u64 {
        vec_map::get(&royalty_info.royalty_nft, &object::id(nft)).staking_contract
    }

    // ===== Entrypoints =====

    /// Module initializer is called only once on module publish.
    fun init(otw: NFT, ctx: &mut TxContext) {
        let keys = vector[
            string::utf8(b"name"),
            string::utf8(b"description"),
        ];

        let values = vector[
            // For `name` one can use the `ArtFiNFT.name` property
            string::utf8(b"ARTFI"),
            // Description is static for all `ArtFiNFT` objects.
            string::utf8(b"ARTFI_NFT"),
        ];

        // Claim the `Publisher` for the package!
        let publisher = package::claim(otw, ctx);

        // Get a new `Display` object for the `ArtFiNFT` type.
        let display_object = display::new_with_fields<ArtFiNFT>(
            &publisher, keys, values, ctx
        );

        // Commit first version of `Display` to apply changes.
        display::update_version(&mut display_object);

        transfer::public_transfer(publisher, tx_context::sender(ctx));
        transfer::public_share_object(display_object);

        transfer::share_object(RoyaltyInfo{
            id: object::new(ctx),
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

    /// Transfer `nft` to `recipient`
    public entry fun transfer_nft(
        nft: ArtFiNFT, recipient: address, _: &mut TxContext
    ) {
        transfer::public_transfer(nft, recipient)
    }

    /// Update the metadata of `nft`
    public entry fun update_metadata(
        _: &MinterCap,
        display_object: &mut display::Display<ArtFiNFT>,
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

    /// Update the defualt royalty
    public entry fun update_royalty(
        _: &MinterCap,
        royalty_info: &mut RoyaltyInfo,
        new_artfi: u64,
        new_artist: u64,
        new_staking_contract: u64,
        _: &mut TxContext
    ) {
        royalty_info.default_royalty.artfi = new_artfi;
        royalty_info.default_royalty.artist = new_artist;
        royalty_info.default_royalty.staking_contract = new_staking_contract;

        event::emit(RoyaltyUpdated {
            artfi: new_artfi,
            artist: new_artist,
            staking_contract: new_staking_contract
        })
    }

    /// Update the defualt royalty
    public entry fun update_nft_royalty(
        _: &MinterCap,
        royalty_info: &mut RoyaltyInfo,
        id: ID,
        new_artfi: u64,
        new_artist: u64,
        new_staking_contract: u64,
        _: &mut TxContext
    ) {
        vec_map::remove(&mut royalty_info.royalty_nft, &id);
        vec_map::insert(&mut royalty_info.royalty_nft, id, Royalty{
            artfi: new_artfi, 
            artist: new_artist, 
            staking_contract: new_staking_contract
        });

        event::emit(NFTRoyaltyUpdated {
            nft_id: id,
            artfi: new_artfi,
            artist: new_artist,
            staking_contract: new_staking_contract
        })
    }

    // === AdminCap Functions ===

    /// Create a new nft
    public entry fun mint_nft(
        _: &MinterCap,
        display_object: &display::Display<ArtFiNFT>,
        url: vector<u8>,
        user: address,
        fraction_id: u64,
        royalty_info: &mut RoyaltyInfo,
        ctx: &mut TxContext
    ) { 
        let display_fields = display::fields(display_object);
        let display_name = vec_map::get(display_fields, &string::utf8(b"name"));
        let display_description = vec_map::get(display_fields, &string::utf8(b"description"));

        let id: ID = mint_func(
            *display_name,
            *display_description,
            url,
            user,
            fraction_id,
            royalty_info,
            ctx
        );

        event::emit(NFTMinted {
            token_id: id,
            creator: tx_context::sender(ctx),
            name: *display_name,
        });
    }
    
    /// Create a multiple nft
    public fun mint_nft_batch(
        _: &MinterCap,
        display_object: &display::Display<ArtFiNFT>,
        royalty_info: &mut RoyaltyInfo,
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

        let display_fields = display::fields(display_object);
        let display_name = vec_map::get(display_fields, &string::utf8(b"name"));
        let display_description = vec_map::get(display_fields, &string::utf8(b"description"));

        while (index < lengthOfVector) {
            let id = mint_func(
                *display_name,
                *display_description,
                *vector::borrow(uris, index),
                *vector::borrow(user, index), 
                *vector::borrow(fraction_ids, index),
                royalty_info,
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

    /// Permanently delete `nft`
    public entry fun burn(nft: ArtFiNFT, royalty_info: &mut RoyaltyInfo, _: &mut TxContext) {
        let _id = object::id(&nft);
        let (_burn_id, _burn_royalty) = vec_map::remove(&mut royalty_info.royalty_nft, &_id);
        
        let ArtFiNFT { id, fraction_id: _, name: _, description: _, url: _ } = nft;
        object::delete(id);
    }

    /// transfer AdminCap to newOwner
    public entry fun transfer_admin_cap(adminCap: AdminCap, newOwner: address) {
        transfer::transfer(adminCap, newOwner);
    }

    /// transfer new instance of MinterCap to minterOwner
    public entry fun transfer_minter_cap(_: &AdminCap, minterOwner: address, ctx: &mut TxContext) {
        transfer::transfer(MinterCap {
            id: object::new(ctx)
        }, minterOwner);
    }

    /// transfer publisher object to minterOwner
    public entry fun transfer_publisher_object(_: &AdminCap, publisher_object: package::Publisher ,newOwner: address, _: &mut TxContext) {
        transfer::public_transfer(publisher_object, newOwner);
    }

    /// transfer Upgrade to newOwner
    public entry fun transfer_upgrade_cap(_: &AdminCap, upgradeCap: package::UpgradeCap ,newOwner: address, _: &mut TxContext) {
        transfer::public_transfer(upgradeCap, newOwner);
    }

    // === Private Functions ===
    
    fun mint_func(
        name: String,
        description: String,
        url: vector<u8>,
        user: address,
        fraction_id: u64,
        royalty_info: &mut RoyaltyInfo,
        ctx: &mut TxContext
     ) : ID {
        let nft = ArtFiNFT {
            id: object::new(ctx),
            fraction_id,
            name: name,
            description: description,
            url: url::new_unsafe_from_bytes(url)
        };

        let _id = object::id(&nft);
        vec_map::insert(&mut royalty_info.royalty_nft, _id, Royalty{
            artfi: royalty_info.default_royalty.artfi, 
            artist: royalty_info.default_royalty.artist, 
            staking_contract: royalty_info.default_royalty.staking_contract
        });

        transfer::public_transfer(nft, user);
        _id
    }  

    // === Test Functions ===

    #[test_only]
    public fun new_artfi_nft(
        name: String,
        description: String,
        url: Url,
        fraction_id: u64,
        royalty_info: &mut RoyaltyInfo,
        ctx: &mut TxContext
    ): ArtFiNFT {
        let nft = ArtFiNFT {
            id: object::new(ctx),
            fraction_id,
            name: name,
            description: description,
            url: url
        };

        let _id = object::id(&nft);
        vec_map::insert(&mut royalty_info.royalty_nft, _id, Royalty{
            artfi: royalty_info.default_royalty.artfi, 
            artist: royalty_info.default_royalty.artist, 
            staking_contract: royalty_info.default_royalty.staking_contract
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
    public fun new_royalty_info(royalty: Royalty): RoyaltyInfo {
        RoyaltyInfo {
            id: object::new(&mut tx_context::dummy()), royalty_nft: vec_map::empty<ID, Royalty>(), default_royalty: royalty
        }
    }

    #[test_only]
    public fun get_default_royalty_fields(
        royalty: &RoyaltyInfo
    ): (u64, u64, u64) {
        (royalty.default_royalty.artfi, royalty.default_royalty.artist, royalty.default_royalty.staking_contract)
    }
    
    #[test_only]
    public fun test_init(
        ctx: &mut TxContext
    ) {
        init(NFT{},ctx);
    }
}