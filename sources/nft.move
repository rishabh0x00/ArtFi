#[allow(lint(self_transfer))]
module collection::nft {

    // === Imports ===

    use sui::event;
    use sui::object::{Self, ID, UID};
    // use sui::object::{Self, UID};
    use std::string::{Self, String};
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};
    use sui::url::{Self, Url};
    use std::vector;
    use sui::vec_map;

    // The creator bundle: these two packages often go together.
    use sui::package;
    use sui::display;

    // ===== Error code ===== 

    const ELengthNotEqual: u64 = 1;

    // === Constants ===

    const ARTFI:u64 = 4;
    const ARTIST:u64 = 3;
    const STAKING_CONTRACT:u64 = 3;

    // === Structs ===

    struct ArtFiNFT has key, store {
        id: UID,
        fraction_id: u64,
        /// Name for the token
        name: String,
        /// Description of the token
        description: String,
        /// URL for the token
        url: Url,
        /// royalty info
        royalty: Royalty
    }

    struct Royalty has store, drop, copy {
        artfi: u64,
        artist: u64,
        staking_contract: u64
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

    /// Get Royalty of NFT's
    public fun royalty(nft: &ArtFiNFT): &Royalty {
        &nft.royalty
    }

    /// Get artfi Royalty of NFT's
    public fun artfi_royalty(nft: &ArtFiNFT): u64 {
        nft.royalty.artfi
    }

    /// Get artist Royalty of NFT's
    public fun artist_royalty(nft: &ArtFiNFT): u64 {
        nft.royalty.artist
    }

    /// Get staking contract Royalty of NFT's
    public fun staking_contract_royalty(nft: &ArtFiNFT): u64 {
        nft.royalty.staking_contract
    }

    // ===== Entrypoints =====

    /// Module initializer is called only once on module publish.
    fun init(otw: NFT, ctx: &mut TxContext) {
        let keys = vector[
            string::utf8(b"name"),
            string::utf8(b"description"),
        ];

        let values = vector[
            // For `name` one can use the `Hero.name` property
            string::utf8(b"{name}"),
            // Description is static for all `Hero` objects.
            string::utf8(b"{description}!"),
        ];

        // Claim the `Publisher` for the package!
        let publisher = package::claim(otw, ctx);

        // Get a new `Display` object for the `Hero` type.
        let display_object = display::new_with_fields<ArtFiNFT>(
            &publisher, keys, values, ctx
        );

        // Commit first version of `Display` to apply changes.
        display::update_version(&mut display_object);

        transfer::public_transfer(publisher, tx_context::sender(ctx));
        transfer::public_share_object(display_object);

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

    // === AdminCap Functions ===

    /// Create a new nft
    public entry fun mint_nft(
        _: &MinterCap,
        display_object: &display::Display<ArtFiNFT>,
        url: vector<u8>,
        user: address,
        fraction_id: u64,
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
            Royalty{
                artfi: ARTFI, artist: ARTIST, staking_contract: STAKING_CONTRACT
            },
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
        uris: &vector<vector<u8>>,
        user: &vector<address>,
        fraction_ids: &vector<u64>,
        ctx: &mut TxContext
    ) {
        let lengthOfVector = vector::length(uris);
        assert!(lengthOfVector == vector::length(fraction_ids), ELengthNotEqual);

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
                Royalty{
                    artfi: ARTFI, artist: ARTIST, staking_contract: STAKING_CONTRACT 
                },
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
    public entry fun burn(nft: ArtFiNFT, _: &mut TxContext) {
        let ArtFiNFT { id, fraction_id: _, name: _, description: _, url: _, royalty: _ } = nft;
        object::delete(id)
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

    // === Private Functions ===
    
    fun mint_func(
        name: String,
        description: String,
        url: vector<u8>,
        user: address,
        fraction_id: u64,
        royalty: Royalty,
        ctx: &mut TxContext
     ) : ID {
        let nft = ArtFiNFT {
            id: object::new(ctx),
            fraction_id,
            name: name,
            description: description,
            url: url::new_unsafe_from_bytes(url),
            royalty: royalty
        };

        let _id = object::id(&nft);
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
        ctx: &mut TxContext
    ): ArtFiNFT {
        ArtFiNFT {
            id: object::new(ctx),
            fraction_id,
            name: name,
            description: description,
            url: url,
            royalty: Royalty{
                artfi: ARTFI, artist: ARTIST, staking_contract: STAKING_CONTRACT 
            }
        }
    }

    #[test_only]
    public fun new_royalty(): Royalty {
        Royalty {
            artfi: ARTFI, artist: ARTIST, staking_contract: STAKING_CONTRACT  
        }
    }
    
    #[test_only]
    public fun test_init(
        ctx: &mut TxContext
    ) {
        init(NFT{},ctx);
    }
}