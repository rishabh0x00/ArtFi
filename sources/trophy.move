#[allow(lint(share_owned, self_transfer))]
module collection::trophy {

    // === Imports ===

    use std::string::{Self, String};
    use std::vector;

    use sui::balance::{Self, Balance};
    use sui::coin;
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
    const EAmountIncorrect: u64 = 2;
    const ENotOwner: u64 = 3;

    // === Structs ===

    struct GOPNFT has key, store {
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
        fraction_id: u64,
        shipment_status: String
    }

    struct NftCounter has key, store {
        id: UID,
        count: vec_map::VecMap<address,u64>,
    }

    struct BuyInfo<phantom CointType> has key {
        id: UID,
        price: u64,
        owner: address,
        balance: Balance<CointType>
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
            // For `name` one can use the `GOPNFT.name` property
            string::utf8(b"Artfi"),
            // Description is static for all `GOPNFT` objects.
            string::utf8(b"Artfi NFT"),
        ];

        // Claim the `Publisher` for the package!
        let publisher = package::claim(otw, ctx);

        // Get a new `Display` object for the `GOPNFT` type.
        let display_object = display::new_with_fields<GOPNFT>(
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
    public fun name(nft: &GOPNFT): &String {
        &nft.name
    }

    /// Get the NFT's `url`
    public fun url(nft: &GOPNFT): &Url {
        &nft.url
    }

    /// Get the NFT's `ID`
    public fun id(nft: &GOPNFT): ID {
        object::id(nft)
    }

    /// Get Attributes of NFT's
    public fun attributes(nft: &GOPNFT, nft_info: &NFTInfo): Attributes{
        *(vec_map::get(&nft_info.user_detials, &object::id(nft)))
    }

    /// Get fraction id of NFT's
    public fun fraction_id(nft: &GOPNFT, nft_info: &NFTInfo): u64 {
        vec_map::get(&nft_info.user_detials, &object::id(nft)).fraction_id
    }

    /// Get shipment status of NFT's
    public fun shipment_status(nft: &GOPNFT, nft_info: &NFTInfo): String {
        vec_map::get(&nft_info.user_detials, &object::id(nft)).shipment_status
    }

    // === Public-Mutative Functions ===

    entry fun buy_gop<CoinType>(
        buy_info: &mut BuyInfo<CoinType>, 
        coin: coin::Coin<CoinType>,
        nft_info: &mut NFTInfo,
        mint_counter: &mut NftCounter,
        url: vector<u8>,
        ctx: &mut TxContext
    ) { 
        let coin_value = coin::value(&coin);
        let extra_coin: u64 = coin_value % buy_info.price;
        assert!(extra_coin == 0, EAmountIncorrect);

        let no_of_nft_mint = coin_value / buy_info.price;
        let index = 0;
        while (index < no_of_nft_mint) {
            mint_nft(
                nft_info,
                mint_counter,
                tx_context::sender(ctx),
                url,
                ctx
            );

            index = index + 1;
        };

        coin::put(&mut buy_info.balance, coin);

    }

    /// Permanently delete `NFT`
    public entry fun burn(nft: GOPNFT, nft_info: &mut NFTInfo, _: &mut TxContext) {
        let _id = object::id(&nft);
        let (_burn_id, _burn_attributes) = vec_map::remove(&mut nft_info.user_detials, &_id);
        
        let GOPNFT { id, name: _, url: _ } = nft;
        object::delete(id);
    }

    // === AdminCap Functions ===

    public fun init_buy_info<CointType>(_: &AdminCap, price: u64, ctx: &mut TxContext) {
        transfer::share_object(BuyInfo<CointType>{
            id: object::new(ctx),
            price: price,
            owner: tx_context::sender(ctx),
            balance: balance::zero<CointType>()
        });
    }
    
    /// Create a multiple GOP
    public fun mint_nft_batch(
        _: &AdminCap,
        nft_info: &mut NFTInfo,
        mint_counter: &mut NftCounter,
        uris: &vector<vector<u8>>,
        user: address,
        ctx: &mut TxContext
    ) {
        check_mint_limit(mint_counter, user);
        let lengthOfVector = vector::length(uris);
        let ids: vector<ID> = vector[];
        let index = 0;

        while (index < lengthOfVector) {
            let id: ID = mint_func(
                nft_info,
                *vector::borrow(uris, index),
                user,
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
        display_object: &mut display::Display<GOPNFT>,
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
        fraction_id: u64,
        shipment_status: String,
    ) {
        base_nft::update_attribute(&mut nft_info.user_detials, id, Attributes{
            fraction_id: fraction_id,
            shipment_status: shipment_status,
        });
    }

    /// update buy info owner
    public entry fun update_buy_info_owner<CoinType>(
        _: &AdminCap,
        buy_info: &mut BuyInfo<CoinType>,
        new_owner: address,
        _: &TxContext
    ) {
        buy_info.owner = new_owner;
    }

    /// update buy info price
    public entry fun update_buy_info_price<CoinType>(
        _: &AdminCap,
        buy_info: &mut BuyInfo<CoinType>,
        new_price: u64,
        _: &TxContext
    ) {
        buy_info.price = new_price;
    }

    /// update buy info price
    public entry fun take_fees<CoinType>(
        buy_info: &mut BuyInfo<CoinType>,
        ctx: &mut TxContext
    ) {
        assert!(tx_context::sender(ctx) == buy_info.owner, ENotOwner);

        let total_fees = balance::value(&buy_info.balance);
        let collected_coin = coin::take(&mut buy_info.balance, total_fees, ctx);
        transfer::public_transfer(collected_coin, buy_info.owner);
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
            assert!(*(vec_map::get(&mint_counter.count, &user)) <= 50,ELimitExceed);
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
        let nft = GOPNFT{
            id: object::new(ctx),
            name: nft_info.name,
            url: url::new_unsafe_from_bytes(url)
        };

        let _id = object::id(&nft);

        vec_map::insert(&mut nft_info.user_detials, _id, Attributes{
            fraction_id: 0,
            shipment_status: string::utf8(b"")
        });

        transfer::public_transfer(nft, user);
        _id
    }

    /// Create a new GOP
    fun mint_nft(
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

    // === Test Functions ===

    #[test_only]
    public fun test_init(
        ctx: &mut TxContext
    ) {
        init(TROPHY{},ctx);
    }
}
