#[allow(lint(share_owned, self_transfer))]
module collection::gop {

    // === Imports ===

    use std::string::{Self, String};

    use sui::balance::{Self, Balance};
    use sui::coin;
    use sui::display;
    use sui::event;
    use sui::package;
    use sui::vec_map;
    use sui::url::{Self, Url};

    use collection::base_nft;

    // ===== Error code ===== 

    const ELimitExceed: u64 = 1;
    const EAmountIncorrect: u64 = 2;
    const ENotOwner: u64 = 3;

    // === Structs ===

    public struct GOPNFT has key, store {
        id: UID,
        /// Name for the token
        name: String,
        /// URL for the token
        url: Url
    }

    public struct NFTInfo has key, store {
        id: UID,
        name: String,
        user_detials: vec_map::VecMap<ID, Attributes>,
        count: vec_map::VecMap<address,u64>,
    }

    public struct Attributes has store, copy, drop {
        claimed: bool,
        airdrop: bool,
        ieo: bool
    }

    public struct BuyInfo<phantom CointType> has key {
        id: UID,
        price: u64,
        owner: address,
        balance: Balance<CointType>
    }

    public struct AdminCap has key {
        id: UID
    }

    // ===== Events =====

    public struct BuyInfoCreated has copy, drop {
        id: ID,
        owner: address,
        price: u64,
    }

    public struct BuyGop has copy, drop {
        user: address,
        fees_paid:  u64,
        number_of_token_mint: u64
    }

    public struct WithdrawFees has copy, drop {
        buy_info_id: ID,
        owner: address,
        value: u64,
    }

    /// One-Time-Witness for the module.
    public struct GOP has drop {}

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
            string::utf8(b"Artfi NFT"),
        ];

        // Claim the `Publisher` for the package!
        let publisher = package::claim(otw, ctx);

        // Get a new `Display` object for the `GOPNFT` type.
        let mut display_object = display::new_with_fields<GOPNFT>(
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

    /// Get ID of the NFT
    public fun id(nft: &GOPNFT): ID {
        object::id(nft)
    }

    /// Get Attributes of the NFT
    public fun attributes(nft: &GOPNFT, nft_info: &NFTInfo): Attributes{
        *(vec_map::get(&nft_info.user_detials, &object::id(nft)))
    }

    /// Get claimed Attributes of the NFT
    public fun claimed(nft: &GOPNFT, nft_info: &NFTInfo): bool {
        vec_map::get(&nft_info.user_detials, &object::id(nft)).claimed
    }

    /// Get airdrop Attributes of the NFT
    public fun airdrop(nft: &GOPNFT, nft_info: &NFTInfo): bool {
        vec_map::get(&nft_info.user_detials, &object::id(nft)).airdrop
    }

    /// Get ieo contract Attributes of the NFT
    public fun ieo(nft: &GOPNFT, nft_info: &NFTInfo): bool {
        vec_map::get(&nft_info.user_detials, &object::id(nft)).ieo
    }

    /// Get accumulated fees from user's
    public fun balance_of_buy_info<CoinType>(buy_info: &BuyInfo<CoinType>): u64 {
        balance::value(&buy_info.balance)
    }

    /// Get mint count of the user
    public fun nft_mint_count(mint_counter: &NFTInfo, user: address): u64 {
        *vec_map::get(&mint_counter.count, &user)
    }

    /// Get owner of fees
    public fun fees_owner<CoinType>(buy_info: &BuyInfo<CoinType>): address {
        buy_info.owner
    }

    /// Get price of gop
    public fun price<CoinType>(buy_info: &BuyInfo<CoinType>): u64 {
        buy_info.price
    }

    // === Public-Mutative Functions ===

    /// Mint new gop token with respect to number coins provided
    /// Revert on incorrect value of coin
    /// Emits TransferredObject for object type GOPNFT and BuyGop
    entry fun buy_gop<CoinType>(
        buy_info: &mut BuyInfo<CoinType>, 
        coin: coin::Coin<CoinType>,
        nft_info: &mut NFTInfo,
        url: vector<u8>,
        ctx: &mut TxContext
    ) { 
        let coin_value = coin::value(&coin);
        let extra_coin: u64 = coin_value % buy_info.price;
        assert!(extra_coin == 0, EAmountIncorrect);

        let no_of_nft_mint = coin_value / buy_info.price;
        check_mint_limit(nft_info, tx_context::sender(ctx), no_of_nft_mint);
        let mut index = 0;
        while (index < no_of_nft_mint) {
            mint_nft(
                nft_info,
                tx_context::sender(ctx),
                url,
                ctx
            );

            index = index + 1;
        };

        coin::put(&mut buy_info.balance, coin);

        event::emit(BuyGop{
            user:  tx_context::sender(ctx),
            fees_paid: coin_value,
            number_of_token_mint: no_of_nft_mint
        });
    }

    /// Permanently delete `NFT`
    /// Only nft owner can call this function
    /// Emits a NFTBurned for object type GOPNFT
    public entry fun burn(nft: GOPNFT, nft_info: &mut NFTInfo, _: &mut TxContext) {
        let _id = object::id(&nft);
        let (_burn_id, _burn_attributes) = vec_map::remove(&mut nft_info.user_detials, &_id);

        let GOPNFT { id, name: _, url: _ } = nft;
        object::delete(id);

        base_nft::emit_burn_nft<GOPNFT>(_id);
    }

    /// Transfer `nft` to `recipient`
    /// Only nft owner can call this function
    /// Emits a TransferredObject for object type GOPNFT
    public entry fun transfer_nft(
        nft: GOPNFT, recipient: address, _: &mut TxContext
    ) {
        let _id = object::id(&nft);

        transfer::public_transfer(nft, recipient);

        base_nft::emit_transfer_object<GOPNFT>(_id, recipient);
    }

    // === AdminCap Functions ===

    /// Create new BuyInfo object for CoinType and set price
    /// Can only be called by the admin, which has admin cap object
    /// Emits a BuyInfoCreated event
    public fun init_buy_info<CointType>(_: &AdminCap, price: u64, ctx: &mut TxContext) {
        let buy_info = BuyInfo<CointType>{
            id: object::new(ctx),
            price: price,
            owner: tx_context::sender(ctx),
            balance: balance::zero<CointType>()
        };

        let _id = object::id(&buy_info);

        transfer::share_object(buy_info);

        event::emit(BuyInfoCreated{
            id: _id,
            owner: tx_context::sender(ctx),
            price
        })
    }
    
    /// Create a multiple GOP and tranfer to user
    /// Can only be called by the owner, which has admin cap object
    /// Emits a NFTBatchMinted event
    public fun mint_nft_batch(
        _: &AdminCap,
        nft_info: &mut NFTInfo,
        uris: &vector<vector<u8>>,
        user: address,
        ctx: &mut TxContext
    ) {
        let lengthOfVector = vector::length(uris);
        check_mint_limit(nft_info, user, lengthOfVector);
        let mut ids: vector<ID> = vector[];
        let mut index = 0;

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

    /// Update the metadata of the NFT's
    /// Can only be called by the owner, which has admin cap object
    /// Emits an NFTMetadataUpdated event
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

    /// Update the nft attributes
    /// Can only be called by the owner, which has admin cap object
    /// Emits an AttributesUpdated event
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

    /// Update the buy info object owner
    /// Can only be called by the owner, which has admin cap object
    public entry fun update_buy_info_owner<CoinType>(
        _: &AdminCap,
        buy_info: &mut BuyInfo<CoinType>,
        new_owner: address,
        _: &TxContext
    ) {
        buy_info.owner = new_owner;
    }

    /// Update the buy info object price
    /// Can only be called by the owner, which has admin cap object
    public entry fun update_buy_info_price<CoinType>(
        _: &AdminCap,
        buy_info: &mut BuyInfo<CoinType>,
        new_price: u64,
        _: &TxContext
    ) {
        buy_info.price = new_price;
    }

    /// Withdraw accumulated fees from user
    /// Can only be called by the owner of buy info object
    public entry fun take_fees<CoinType>(
        buy_info: &mut BuyInfo<CoinType>,
        ctx: &mut TxContext
    ) {
        assert!(tx_context::sender(ctx) == buy_info.owner, ENotOwner);

        let total_fees = balance::value(&buy_info.balance);
        let collected_coin = coin::take(&mut buy_info.balance, total_fees, ctx);
        transfer::public_transfer(collected_coin, buy_info.owner);

        event::emit(WithdrawFees{
            buy_info_id: object::id(buy_info),
            owner: buy_info.owner,
            value: total_fees
        })
    }

    /// Transfer AdminCap to new_owner
    /// Can only be called by user, who ownes admin cap
    /// Emits a TransferredObject event for object type AdminCap
    public entry fun transfer_admin_cap(admin_cap: AdminCap, new_owner: address, _: &mut TxContext) {
        let _id = object::id(&admin_cap);
        transfer::transfer(admin_cap, new_owner);

        base_nft::emit_transfer_object<AdminCap>(_id, new_owner);
    }

    // === Private Functions ===

    fun check_mint_limit(
        mint_counter: &mut NFTInfo,
        user: address,
        number_of_token_mint: u64
    ) {
        if (vec_map::contains(&mint_counter.count, &user)) {
            assert!(*(vec_map::get(&mint_counter.count, &user)) + number_of_token_mint <= 50,ELimitExceed);
            let counter = vec_map::get_mut(&mut mint_counter.count, &user);
            *counter = *counter + number_of_token_mint;
        } else {
            vec_map::insert(&mut mint_counter.count, user, number_of_token_mint);
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
        user: address,
        url: vector<u8>,
        ctx: &mut TxContext
    ) { 
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
    public fun new_gop_nft(
        name: String,
        url: Url,
        nft_info: &mut NFTInfo,
        ctx: &mut TxContext
    ): GOPNFT {
        let nft = GOPNFT {
            id: object::new(ctx),
            name: name,
            url: url
        };

        let _id = object::id(&nft);
        vec_map::insert(&mut nft_info.user_detials, _id, Attributes{
            claimed: false, 
            airdrop: false, 
            ieo: false
        });

        nft
    }

    #[test_only]
    public fun new_attributes(claimed: bool, airdrop: bool, ieo: bool): Attributes {
        Attributes {
            claimed, airdrop, ieo
        }
    }

    #[test_only]
    public fun new_nft_info(name: String): NFTInfo {
        NFTInfo {
            id: object::new(&mut tx_context::dummy()), name, user_detials: vec_map::empty<ID, Attributes>(), count: vec_map::empty<address, u64>()
        }
    }


    #[test_only]
    public fun description(display: &display::Display<GOPNFT>): String {
        let fields = display::fields(display);
        *vec_map::get(fields, &string::utf8(b"description"))
    }

    #[test_only]
    public fun test_init(
        ctx: &mut TxContext
    ) {
        init(GOP{},ctx);
    }
}
