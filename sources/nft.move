#[allow(lint(self_transfer))]
module nft::nft {
    use sui::url::{Self, Url};
    use std::string;
    use sui::object::{Self, ID, UID};
    use sui::event;
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};
    use std::vector;

    // ===== Error code ===== 
    const ELengthNotEqual: u64 = 11;

    struct TestNetNFT has key, store {
        id: UID,
        /// Name for the token
        name: string::String,
        /// Description of the token
        description: string::String,
        /// URL for the token
        url: Url,
        // TODO: allow custom attributes
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
    public fun name(nft: &TestNetNFT): &string::String {
        &nft.name
    }

    /// Get the NFT's `description`
    public fun description(nft: &TestNetNFT): &string::String {
        &nft.description
    }

    /// Get the NFT's `url`
    public fun url(nft: &TestNetNFT): &Url {
        &nft.url
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

    public fun transferAdminCap(adminCap: AdminCap, newOwner: address) {
        transfer::transfer(adminCap, newOwner);
    }

    public fun transferMinterCap(_: &AdminCap, minterOwner: address, ctx: &mut TxContext) {
        transfer::transfer(MinterCap {
            id: object::new(ctx)
        }, minterOwner);
    }

    /// Create a new nft
    public fun mintNFT(
        _: &MinterCap,
        name: vector<u8>,
        description: vector<u8>,
        url: vector<u8>,
        user: address,
        ctx: &mut TxContext
    ) { 
        mintFunc(
            name, description, url, user, ctx
        );
    }
    
    /// Create a multiple nft
    public fun mintNftBatch(
        _: &MinterCap,
        name: &vector<vector<u8>>,
        description: &vector<vector<u8>>,
        url: &vector<vector<u8>>,
        user: address,
        ctx: &mut TxContext
    ) {
        let lenghtOfVector = vector::length(name);
        assert!(lenghtOfVector == vector::length(description), ELengthNotEqual);
        assert!(lenghtOfVector == vector::length(url), ELengthNotEqual);

        let index = 0;
        while (index < lenghtOfVector) {

            mintFunc(
                *vector::borrow(name, index),
                *vector::borrow(description, index),
                *vector::borrow(url, index),
                user, 
                ctx
            );

            index = index + 1;
        };
    }

    /// Transfer `nft` to `recipient`
    public fun transferNFT(
        nft: TestNetNFT, recipient: address, _: &mut TxContext
    ) {
        transfer::public_transfer(nft, recipient)
    }

    /// Update the `description` of `nft` to `new_description`
    public fun update_description(
        nft: &mut TestNetNFT,
        new_description: vector<u8>,
        _: &mut TxContext
    ) {
        nft.description = string::utf8(new_description)
    }

    /// Permanently delete `nft`
    public fun burn(nft: TestNetNFT, _: &mut TxContext) {
        let TestNetNFT { id, name: _, description: _, url: _ } = nft;
        object::delete(id)
    }
    
    fun mintFunc(
        name: vector<u8>,
        description: vector<u8>,
        url: vector<u8>,
        user: address,
        ctx: &mut TxContext
    ) {
        let nft = TestNetNFT {
            id: object::new(ctx),
            name: string::utf8(name),
            description: string::utf8(description),
            url: url::new_unsafe_from_bytes(url)
        };

        event::emit(NFTMinted {
            object_id: object::id(&nft),
            creator: tx_context::sender(ctx),
            name: nft.name,
        });

        transfer::public_transfer(nft, user);
    }  

    #[test_only]
    public fun new_testNetNFT(
        name: vector<u8>,
        description: vector<u8>,
        url: vector<u8>,
        ctx: &mut TxContext
    ): TestNetNFT {
        TestNetNFT {
            id: object::new(ctx),
            name: string::utf8(name),
            description: string::utf8(description),
            url: url::new_unsafe_from_bytes(url)
        }
    }
     
}