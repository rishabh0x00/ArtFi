#[allow(lint(share_owned, self_transfer))]
module collection::base_nft {

    use std::string::String;

    use sui::event;
    use sui::object::{Self, ID, UID};
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};
    use sui::vec_map;

    // === Structs ===

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

    struct AttributesUpdated<T, U> has copy, drop {
        key: T,
        value: U
    }

    // ===== Entrypoints =====

    /// Module initializer is called only once on module publish.
    fun init(ctx: &mut TxContext){
        transfer::transfer(AdminCap {
            id: object::new(ctx)
        }, tx_context::sender(ctx));
    }

    // === Public Functions ===

    public fun emit_mint_nft(id: ID, creator: address, name: String) {
        event::emit(NFTMinted {
            token_id: id,
            creator: creator,
            name: name,
        });
    }

    public fun emit_batch_mint_nft(ids: vector<ID>, no_of_tokens: u64,creator: address, name: String) {
        event::emit(NFTBatchMinted {
            token_ids: ids,
            creator: creator,
            name: name,
            no_of_tokens: no_of_tokens
        });
    }

    public fun emit_metadat_update(new_name: String, new_description: String) {
        event::emit(NFTMetadataUpdated{
            name: new_name,
            description: new_description,
        })
    }

    public fun emit_update_attributes<T: copy + drop, U: copy + drop>(id: T, value: U) {
        event::emit(AttributesUpdated{
            key: id,
            value: value
        })
    }

    /// Transfer `nft` to `recipient`
    public entry fun transfer_object<T: key + store>(
        nft: T, recipient: address, _: &mut TxContext
    ) {
        transfer::public_transfer(nft, recipient);
    }

    public fun update_attribute<T: copy + drop, U: copy + drop>(vector_map: &mut vec_map::VecMap<T, U>, id: T, value: U) {
        vec_map::remove(vector_map, &id);
        vec_map::insert(vector_map, id, value);

        event::emit(AttributesUpdated{
            key: id,
            value: value
        })
    }

    // === AdminCap Functions ===

    /// transfer AdminCap to new_owner
    public entry fun transfer_admin_cap(admin_cap: AdminCap, new_owner: address, _: &mut TxContext) {
        transfer::transfer(admin_cap, new_owner);
    }
}
