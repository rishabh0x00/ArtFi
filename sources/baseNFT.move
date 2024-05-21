#[allow(lint(share_owned, self_transfer))]
module collection::baseNFT {

    use std::string::{Self, String};
    use std::vector;

    use sui::display;
    use sui::event;
    use sui::object::{Self, ID, UID};
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};
    use sui::url::{Self, Url};
    use sui::vec_map;

    // ===== Error code ===== 

    const ELimitExceed: u64 = 1;

    // === Structs ===
    #[allow(unused_type_parameter)]
    struct NFT<T: key> has key, store {
        id: UID,
        /// Name for the token
        name: String,
        /// Description of the token
        description: String,
        /// URL for the token
        url: Url
    }

    struct NftCounter has key, store {
        id: UID,
        count: vec_map::VecMap<address,u64>,
    }

    struct AdminCap has key {
        id: UID
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

    // ===== Entrypoints =====

    /// Module initializer is called only once on module publish.
    fun init(ctx: &mut TxContext){

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
    public fun name<T: key + store>(nft: &NFT<T>): &String {
        &nft.name
    }

    /// Get the NFT's `description`
    public fun description<T: key + store>(nft: &NFT<T>): &String {
        &nft.description
    }

    /// Get the NFT's `url`
    public fun url<T: key + store>(nft: &NFT<T>): &Url {
        &nft.url
    }

    /// Create a new NFT
    public fun mint_nft<T: key + store>(
        display_object: &display::Display<T>,
        mint_counter: &mut NftCounter,
        url: vector<u8>,
        ctx: &mut TxContext
    ): ID { 
        check_mint_limit(mint_counter, ctx);

        let display_fields = display::fields(display_object);
        let display_name = vec_map::get(display_fields, &string::utf8(b"name"));
        let display_description = vec_map::get(display_fields, &string::utf8(b"description"));

        let id: ID = mint_func<T>(
            *display_name,
            *display_description,
            url,
            tx_context::sender(ctx),
            ctx
        );

        event::emit(NFTMinted {
            token_id: id,
            creator: tx_context::sender(ctx),
            name: *display_name,
        });

        id
    }

    public fun mint_nft_batch<T: key + store>(
        _: &AdminCap,
        display_object: &display::Display<T>,
        mint_counter: &mut NftCounter,
        uris: &vector<vector<u8>>,
        user: address,
        ctx: &mut TxContext
    ) : vector<ID> {
        check_mint_limit(mint_counter, ctx);

        let lengthOfVector = vector::length(uris);
        let ids: vector<ID> = vector[];
        let index = 0;

        let display_fields = display::fields(display_object);
        let display_name = vec_map::get(display_fields, &string::utf8(b"name"));
        let display_description = vec_map::get(display_fields, &string::utf8(b"description"));

        while (index < lengthOfVector) {
            let id: ID = mint_func<T>(
                *display_name,
                *display_description,
                *vector::borrow(uris, index),
                user,
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

        ids
    }

    /// Permanently delete `NFT`
    public entry fun burn<T: key + store>(nft: NFT<T>, _: &mut TxContext) {
        let NFT { id, name: _, description: _, url: _ } = nft;
        object::delete(id);
    }

    /// Transfer `nft` to `recipient`
    public entry fun transfer_nft<T: key + store>(
        nft: NFT<T>, recipient: address, _: &mut TxContext
    ) {
        transfer::public_transfer<NFT<T>>(nft, recipient)
    }

    // === AdminCap Functions ===

    /// Update the metadata of `NFT`
    public entry fun update_metadata<T: key>(
        _: &AdminCap,
        display_object: &mut display::Display<T>,
        new_description: String,
        new_name: String
    ) {
        display::edit(display_object, string::utf8(b"name"), new_name);
        display::edit(display_object, string::utf8(b"description"), new_description);

        display::update_version(display_object);

        event::emit(NFTMetadataUpdated {
            name: new_name,
            description: new_description,
        })
    }

    /// transfer AdminCap to new_owner
    public entry fun transfer_admin_cap(admin_cap: AdminCap, new_owner: address, _: &mut TxContext) {
        transfer::transfer(admin_cap, new_owner);
    }

    // === Private Functions ===
    
    fun mint_func<T: key + store>(
        name: String,
        description: String,
        url: vector<u8>,
        user: address,
        ctx: &mut TxContext
     ) : ID {
        let nft = NFT<T> {
            id: object::new(ctx),
            name: name,
            description: description,
            url: url::new_unsafe_from_bytes(url)
        };

        let _id = object::id(&nft);
        transfer::public_transfer(nft, user);
        _id
    } 

    fun check_mint_limit(
        mint_counter: &mut NftCounter,
        ctx: &TxContext
    ) {
        if (vec_map::contains(&mint_counter.count, &tx_context::sender(ctx))) {
            assert!(*(vec_map::get(&mint_counter.count, &tx_context::sender(ctx))) <= 50,ELimitExceed);
        } else {
            vec_map::insert(&mut mint_counter.count, tx_context::sender(ctx), 1);
        };
    } 
}