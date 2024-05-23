#[allow(lint(share_owned, self_transfer))]
module collection::gop {

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
        /// Description of the token
        description: String,
        /// URL for the token
        url: Url
    }

    struct NFTInfo has key, store {
        id: UID,
        name: String,
        description: String,
        user_detials: vec_map::VecMap<ID, Attributes>,
    }

    struct Attributes has store, copy, drop {
        claimed: bool,
        airdrop: bool,
        ieo: bool
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
    struct GOP has drop {}

    // ===== Entrypoints =====

    /// Module initializer is called only once on module publish.
    fun init(otw: GOP, ctx: &mut TxContext) {
        let keys = vector[
            string::utf8(b"name"),
            string::utf8(b"description"),
        ];

        let values = vector[
            // For `name` one can use the `GOPNFT.name` property
            string::utf8(b"Artfi"),
            // Description is static for all `GOPNFT` objects.
            string::utf8(b"Artfi_NFT"),
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
            description: string::utf8(b"Artfi NFT"),
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

    /// Get the NFT's `description`
    public fun description(nft: &GOPNFT): &String {
        &nft.description
    }

    /// Get the NFT's `url`
    public fun url(nft: &GOPNFT): &Url {
        &nft.url
    }

    /// Get the NFT's `ID`
    public fun id(nft: &GOPNFT): ID {
        object::id(nft)
    }

    /// Get Royalty of NFT's
    public fun attributes(nft: &GOPNFT, nft_info: &NFTInfo): Attributes{
        *(vec_map::get(&nft_info.user_detials, &object::id(nft)))
    }

    /// Get artfi Royalty of NFT's
    public fun claimed(nft: &GOPNFT, nft_info: &NFTInfo): bool {
        vec_map::get(&nft_info.user_detials, &object::id(nft)).claimed
    }

    /// Get artist Royalty of NFT's
    public fun airdrop(nft: &GOPNFT, nft_info: &NFTInfo): bool {
        vec_map::get(&nft_info.user_detials, &object::id(nft)).airdrop
    }

    /// Get staking contract Royalty of NFT's
    public fun ieo(nft: &GOPNFT, nft_info: &NFTInfo): bool {
        vec_map::get(&nft_info.user_detials, &object::id(nft)).ieo
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
        assert!(buy_info.price == coin::value(&coin), EAmountIncorrect);

        coin::put(&mut buy_info.balance, coin);

        mint_nft(
            nft_info,
            mint_counter,
            tx_context::sender(ctx),
            url,
            ctx
        );
    }

    /// Permanently delete `NFT`
    public entry fun burn(nft: GOPNFT, nft_info: &mut NFTInfo, _: &mut TxContext) {
        let _id = object::id(&nft);
        let (_burn_id, _burn_attributes) = vec_map::remove(&mut nft_info.user_detials, &_id);
        
        let GOPNFT { id, name: _, description: _, url: _ } = nft;
        object::delete(id);
    }

    // === AdminCap Functions ===

    public fun init_buy_info<CointType>(_: &AdminCap, ctx: &mut TxContext) {
        transfer::share_object(BuyInfo<CointType>{
            id: object::new(ctx),
            price: 10,
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
        nft_info.description = new_description;

        display::update_version(display_object);

        base_nft::emit_metadat_update(new_name, new_description);
    }

    public entry fun update_attribute(
        _: &AdminCap,
        nft_info: &mut NFTInfo,
        id: ID,
        new_claimed: bool,
        new_airdrop: bool,
        new_ieo: bool
    ) {
        base_nft::update_attribute(&mut nft_info.user_detials, id, Attributes{
            claimed: new_claimed,
            airdrop: new_airdrop,
            ieo: new_ieo
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
            description: nft_info.description,
            url: url::new_unsafe_from_bytes(url)
        };

        let _id = object::id(&nft);

        vec_map::insert(&mut nft_info.user_detials, _id, Attributes{
            claimed: false,
            airdrop: false,
            ieo: false
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
        init(GOP{},ctx);
    }
}
