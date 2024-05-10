#[allow(lint(self_transfer))]
module nft::nft {

    // === Imports ===

    use sui::url::{Self, Url};
    use std::string;
    use sui::object::{Self, ID, UID};
    use sui::event;
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};
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
        fractionId: u64,
        /// Name for the token
        name: string::String,
        /// Description of the token
        description: string::String,
        /// URL for the token
        url: Url,
        /// royalty info
        royalty: Royalty
    }

    struct Royalty has store, drop, copy {
        artfi: u64,
        artist: u64,
        stakingContract: u64
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
        object_id: ID,
        // The creator of the NFT
        creator: address,
        // The name of the NFT
        name: string::String,
    }

    // ===== Public view functions =====

    /// Get the NFT's `name`
    public fun name(nft: &ArtFiNFT): &string::String {
        &nft.name
    }

    /// Get the NFT's `description`
    public fun description(nft: &ArtFiNFT): &string::String {
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
    public fun stakingContract_royalty(nft: &ArtFiNFT): u64 {
        nft.royalty.stakingContract
    }

    // ===== Entrypoints =====

    /// Module initializer is called only once on module publish.
    fun init(ctx: &mut TxContext) {
        transfer::transfer(AdminCap {
            id: object::new(ctx)
        }, tx_context::sender(ctx));

        transfer::transfer(MinterCap {
            id: object::new(ctx)
        }, tx_context::sender(ctx));
    }

    // === Public-Mutative Functions ===

    /// Transfer `nft` to `recipient`
    public fun transfer_nft(
        nft: ArtFiNFT, recipient: address, _: &mut TxContext
    ) {
        transfer::public_transfer(nft, recipient)
    }

    /// Update the `description` of `nft` to `new_description`
    public fun update_description(
        _: &MinterCap,
        nft: &mut ArtFiNFT,
        new_description: vector<u8>,
        _: &mut TxContext
    ) {
        nft.description = string::utf8(new_description)
    }

    /// Update the metadata of `nft`
    public fun update_metadata(
        _: &MinterCap,
        nft: &mut ArtFiNFT,
        new_description: vector<u8>,
        new_name: vector<u8>,
        new_url: vector<u8>,
        _: &mut TxContext
    ) {
        nft.description = string::utf8(new_description);
        nft.name = string::utf8(new_name);
        nft.url = url::new_unsafe_from_bytes(new_url);
    }

    // === Admin Functions ===

    /// Create a new nft
    public fun mint_nft(
        _: &MinterCap,
        name: vector<u8>,
        description: vector<u8>,
        url: vector<u8>,
        user: address,
        fractionId: u64,
        ctx: &mut TxContext
    ) { 
        mint_func(
            name, description, url, user, fractionId, ctx
        );
    }
    
    /// Create a multiple nft
    public fun mint_nft_batch(
        _: &MinterCap,
        name: &vector<vector<u8>>,
        description: &vector<vector<u8>>,
        url: &vector<vector<u8>>,
        user: address,
        fractionId: &vector<u64>,
        ctx: &mut TxContext
    ) {
        let lenghtOfVector = vector::length(name);
        assert!(lenghtOfVector == vector::length(description), ELengthNotEqual);
        assert!(lenghtOfVector == vector::length(url), ELengthNotEqual);
        assert!(lenghtOfVector == vector::length(fractionId), ELengthNotEqual);

        let index = 0;
        while (index < lenghtOfVector) {

            mint_func(
                *vector::borrow(name, index),
                *vector::borrow(description, index),
                *vector::borrow(url, index),
                user, 
                *vector::borrow(fractionId, index),
                ctx
            );

            index = index + 1;
        };
    }

    /// Permanently delete `nft`
    public fun burn(nft: ArtFiNFT, _: &mut TxContext) {
        let ArtFiNFT { id, fractionId: _, name: _, description: _, url: _, royalty: _ } = nft;
        object::delete(id)
    }

    /// transfer AdminCap to newOwner
    public fun transfer_admin_cap(adminCap: AdminCap, newOwner: address) {
        transfer::transfer(adminCap, newOwner);
    }

    /// transfer new instance of MinterCap to minterOwner
    public fun transfer_minter_cap(_: &AdminCap, minterOwner: address, ctx: &mut TxContext) {
        transfer::transfer(MinterCap {
            id: object::new(ctx)
        }, minterOwner);
    }

    // === Private Functions ===
    
    fun mint_func(
        name: vector<u8>,
        description: vector<u8>,
        url: vector<u8>,
        user: address,
        fractionId: u64,
        ctx: &mut TxContext
    ) {
        let nft = ArtFiNFT {
            id: object::new(ctx),
            fractionId,
            name: string::utf8(name),
            description: string::utf8(description),
            url: url::new_unsafe_from_bytes(url),
            royalty: Royalty{
                artfi: ARTFI, artist: ARTIST, stakingContract: STAKING_CONTRACT 
            }
        };

        event::emit(NFTMinted {
            object_id: object::id(&nft),
            creator: tx_context::sender(ctx),
            name: nft.name,
        });

        transfer::public_transfer(nft, user);
    }  

    // === Test Functions ===

    #[test_only]
    public fun new_artfi_nft(
        name: vector<u8>,
        description: vector<u8>,
        url: vector<u8>,
        fractionId: u64,
        ctx: &mut TxContext
    ): ArtFiNFT {
        ArtFiNFT {
            id: object::new(ctx),
            fractionId,
            name: string::utf8(name),
            description: string::utf8(description),
            url: url::new_unsafe_from_bytes(url),
            royalty: Royalty{
                artfi: ARTFI, artist: ARTIST, stakingContract: STAKING_CONTRACT 
            }
        }
    }

    #[test_only]
    public fun new_royalty(): Royalty {
        Royalty {
            artfi: ARTFI, artist: ARTIST, stakingContract: STAKING_CONTRACT  
        }
    }
    
    #[test_only]
    public fun test_init(
        ctx: &mut TxContext
    ) {
        init(ctx);
    }
}