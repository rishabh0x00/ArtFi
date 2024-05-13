#[allow(lint(self_transfer))]
module collection::nft {

    // === Imports ===

    use sui::event;
    // use sui::object::{Self, ID, UID};
    use sui::object::{Self, UID};
    use std::string::String;
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};
    use sui::url::{Self, Url};
    use std::vector;


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

    struct Admin has key {
        id: UID
    }

    struct Minter has key {
        id: UID
    }

    // ===== Events =====

    struct NFTMinted has copy, drop {
        // The Object ID of the NFT
        // token_id: ID,
        // The creator of the NFT
        creator: address,
        // The name of the NFT
        name: String,
    }

    struct NFTBatchMinted has copy, drop {
        // The creator of the NFT
        creator: address,
        // The name of the NFT
        name: String,
        // number of tokens
        no_of_tokens: u64
    }

    struct NFTMetadataUpdated has copy, drop {
        // The fraction ID of the NFT
        fraction_id: u64,
        /// Name for the token
        name: String,
        /// Description of the token
        description: String,
        /// URL for the token
        url: Url,
    }

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
    fun init(ctx: &mut TxContext) {
        transfer::transfer(Admin {
            id: object::new(ctx)
        }, tx_context::sender(ctx));

        transfer::transfer(Minter {
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
    public fun update_metadata(
        _: &Minter,
        nft: &mut ArtFiNFT,
        new_description: String,
        new_name: String,
        new_url: Url,
        _: &mut TxContext
    ) {
        nft.description = new_description;
        nft.name = new_name;
        nft.url = new_url;

        event::emit(NFTMetadataUpdated {
            fraction_id: nft.fraction_id,
            name: new_name,
            description: new_description,
            url: new_url
        })
    }

    // === Admin Functions ===

    /// Create a new nft
    public entry fun mint_nft(
        _: &Minter,
        name: String,
        description: String,
        url: vector<u8>,
        user: address,
        fraction_id: u64,
        ctx: &mut TxContext
    ) { 
        // let id: ID = 
        mint_func(
            name,
            description,
            url,
            user,
            fraction_id,
            Royalty{
                artfi: ARTFI, artist: ARTIST, staking_contract: STAKING_CONTRACT
            },
            ctx
        );

        event::emit(NFTMinted {
            creator: tx_context::sender(ctx),
            name: name,
        });
    }
    
    /// Create a multiple nft
    public fun mint_nft_batch(
        _: &Minter,
        name: String,
        description: String,
        uris: &vector<vector<u8>>,
        user: address,
        fraction_ids: &vector<u64>,
        ctx: &mut TxContext
    ) {
        let lengthOfVector = vector::length(uris);
        assert!(lengthOfVector == vector::length(fraction_ids), ELengthNotEqual);

        let index = 0;
        while (index < lengthOfVector) {
            mint_func(
                name,
                description,
                *vector::borrow(uris, index),
                user, 
                *vector::borrow(fraction_ids, index),
                Royalty{
                    artfi: ARTFI, artist: ARTIST, staking_contract: STAKING_CONTRACT 
                },
                ctx
            );

            index = index + 1;
        };

        event::emit(NFTBatchMinted {
            creator: tx_context::sender(ctx),
            name: name,
            no_of_tokens: lengthOfVector
        });
    }

    /// Permanently delete `nft`
    public entry fun burn(nft: ArtFiNFT, _: &mut TxContext) {
        let ArtFiNFT { id, fraction_id: _, name: _, description: _, url: _, royalty: _ } = nft;
        object::delete(id)
    }

    /// transfer AdminCap to newOwner
    public entry fun transfer_admin_cap(adminCap: Admin, newOwner: address) {
        transfer::transfer(adminCap, newOwner);
    }

    /// transfer new instance of MinterCap to minterOwner
    public entry fun transfer_minter_cap(_: &Admin, minterOwner: address, ctx: &mut TxContext) {
        transfer::transfer(Minter {
            id: object::new(ctx)
        }, minterOwner);
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
    ) {
        let nft = ArtFiNFT {
            id: object::new(ctx),
            fraction_id,
            name: name,
            description: description,
            url: url::new_unsafe_from_bytes(url),
            royalty: royalty
        };

        transfer::public_transfer(nft, user);

        // object::id(&nft);
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
        init(ctx);
    }
}