#[test_only]
module collection::gop_tests {
    // Test attribute is placed before the `fun` keyword. Can be both above or
    // right before the `fun` keyword: `#[test] fun my_test() { ... }`
    // The name of the test would be `book::testing::simple_test`.
    #[test_only]
    use collection::gop;
    use sui::url;
    use std::string;
    use sui::tx_context;

    #[test_only] use sui::test_utils;
    #[test_only] use sui::test_scenario;
    #[test_only] use sui::display;

    #[test]
    // test `name` function
    fun nft_name_test() {
        let name = b"Artfi";
        let description = b"Artfi_NFT";
        let nft_url = b"Artfi_NFT";
        let test_net_nft = gop::new_artfi_nft(
            string::utf8(name),
            string::utf8(description), 
            url::new_unsafe_from_bytes(nft_url), 
            &mut tx_context::dummy()
        );

        assert!(gop::name(&test_net_nft) == &string::utf8(b"Artfi"), 1);

        let dummy_address = @0xCAFE;
        sui::transfer::public_transfer(test_net_nft, dummy_address);        
    }

    // test `description` function
    #[test]
    fun nft_description_test() {
        let name = b"Artfi";
        let description = b"Artfi_NFT";
        let nft_url = b"Artfi_NFT";
        let test_net_nft = gop::new_artfi_nft(
            string::utf8(name),
            string::utf8(description), 
            url::new_unsafe_from_bytes(nft_url), 
            &mut tx_context::dummy()
        );
        assert!(gop::description(&test_net_nft) == &string::utf8(b"Artfi_NFT"), 1);

        let dummy_address = @0xCAFE;
        sui::transfer::public_transfer(test_net_nft, dummy_address);
        
    }

    #[test]
    // test `url` function
    fun nft_url_test() {
        let name = b"Artfi";
        let description = b"Artfi_NFT";
        let nft_url = b" ";
        let test_net_nft = gop::new_artfi_nft(
            string::utf8(name),
            string::utf8(description), 
            url::new_unsafe_from_bytes(nft_url),
            &mut tx_context::dummy()
        );
        assert!(gop::url(&test_net_nft) ==  &url::new_unsafe_from_bytes(nft_url), 1);

        test_utils::destroy<gop::GopNFT>(test_net_nft);
    }

    #[test]
    fun test_module_init() {

        let initial_owner = @0xCAFE;
        let final_owner = @0xFACE;

        let scenario = test_scenario::begin(initial_owner);
        {   
            test_scenario::sender(&scenario);

            gop::test_init(test_scenario::ctx(&mut scenario));

        };

        test_scenario::next_tx(&mut scenario,initial_owner);
        {
            let admin_cap = test_scenario::take_from_sender<gop::AdminCap>(&scenario);

            gop::transfer_admin_cap(admin_cap, final_owner, test_scenario::ctx(&mut scenario));

        };

        test_scenario::end(scenario);
    }

    #[test]
    fun test_transfer_admin_cap() {

        let initial_owner = @0xCAFE;
        let final_owner = @0xFACE;

        let scenario = test_scenario::begin(initial_owner);
        {   
            test_scenario::sender(&scenario);

            gop::test_init(test_scenario::ctx(&mut scenario));

        };

        test_scenario::next_tx(&mut scenario,initial_owner);
        {
            let admin_cap = test_scenario::take_from_sender<gop::AdminCap>(&scenario);

            gop::transfer_admin_cap(admin_cap, final_owner, test_scenario::ctx(&mut scenario));

        };

        test_scenario::end(scenario);
    }

    #[test]
    fun test_mint_nft() {

        let url = b" ";
        let initial_owner = @0xCAFE;
        let final_owner = @0xFACE;

        let scenario = test_scenario::begin(initial_owner);
        {   
            test_scenario::sender(&scenario);

            gop::test_init(test_scenario::ctx(&mut scenario));

        };

        test_scenario::next_tx(&mut scenario, final_owner);
        {

            let display_object = test_scenario::take_shared<display::Display<gop::GopNFT>>(&scenario);
            gop::mint_nft(
                &display_object,
                url, 
                test_scenario::ctx(&mut scenario)
            );

            test_scenario::return_shared<display::Display<gop::GopNFT>>(display_object);
        };

        test_scenario::next_tx(&mut scenario,final_owner);
        {
            let nftToken = test_scenario::take_shared<gop::GopNFT>(&scenario);

            assert!(gop::name(&nftToken) == &string::utf8(b"Artfi"), 1);
            assert!(gop::description(&nftToken) == &string::utf8(b"Artfi_NFT"), 1);
            assert!(gop::url(&nftToken) == &url::new_unsafe_from_bytes(url), 1);
            assert!(gop::owner(&nftToken) == &final_owner, 1);

            test_utils::destroy<gop::GopNFT>(nftToken);
            
        };

        test_scenario::end(scenario);
    }

    #[test]
    fun test_mint_batch_nft() {

        let url = vector[b" "];
        let initial_owner = @0xCAFE;
        let final_owner = @0xFACE;

        let scenario = test_scenario::begin(initial_owner);
        {   
            test_scenario::sender(&scenario);

            gop::test_init(test_scenario::ctx(&mut scenario));

        };

        test_scenario::next_tx(&mut scenario, final_owner);
        {

            let display_object = test_scenario::take_shared<display::Display<gop::GopNFT>>(&scenario);

            gop::mint_nft_batch(
                &display_object,
                &url, 
                test_scenario::ctx(&mut scenario)
            );

            test_scenario::return_shared<display::Display<gop::GopNFT>>(display_object);
        };

        test_scenario::next_tx(&mut scenario,final_owner);
        {
            let nftToken = test_scenario::take_shared<gop::GopNFT>(&scenario);

            assert!(gop::name(&nftToken) == &string::utf8(b"Artfi"), 1);
            assert!(gop::description(&nftToken) == &string::utf8(b"Artfi_NFT"), 1);
            assert!(gop::url(&nftToken) == &url::new_unsafe_from_bytes(b" "), 1);
            assert!(gop::owner(&nftToken) == &final_owner, 1);

            test_utils::destroy<gop::GopNFT>(nftToken);            
        };

        test_scenario::end(scenario);
    }

    #[test]
    fun test_transfer_nft() {

        let url = b" ";
        let initial_owner = @0xCAFE;
        let final_owner = @0xFACE;
        let user = @0xEAFF;

        let scenario = test_scenario::begin(initial_owner);
        {   
            test_scenario::sender(&scenario);

            gop::test_init(test_scenario::ctx(&mut scenario));

        };

        test_scenario::next_tx(&mut scenario, final_owner);
        {

            let display_object = test_scenario::take_shared<display::Display<gop::GopNFT>>(&scenario);

            gop::mint_nft(
                &display_object,
                url, 
                test_scenario::ctx(&mut scenario)
            );

            test_scenario::return_shared<display::Display<gop::GopNFT>>(display_object);
        };

        test_scenario::next_tx(&mut scenario,final_owner);
        {
            let nftToken = test_scenario::take_shared<gop::GopNFT>(&scenario);

            gop::transfer_nft(&mut nftToken, user, test_scenario::ctx(&mut scenario));

            test_scenario::return_shared(nftToken);
        };

        test_scenario::next_tx(&mut scenario, user);
        {
            let nftToken = test_scenario::take_shared<gop::GopNFT>(&scenario);

            assert!(gop::name(&nftToken) == &string::utf8(b"Artfi"), 1);
            assert!(gop::description(&nftToken) == &string::utf8(b"Artfi_NFT"), 1);
            assert!(gop::url(&nftToken) == &url::new_unsafe_from_bytes(url), 1);
            assert!(gop::owner(&nftToken) == &user, 1);

            test_scenario::return_shared<gop::GopNFT>(nftToken);
        };

        test_scenario::end(scenario);
    }

    #[test]
    #[expected_failure(abort_code = test_scenario::EEmptyInventory)] 
    fun test_burn_nft() {
        let url = b" ";
        let initial_owner = @0xCAFE;
        let final_owner = @0xFACE;

        let scenario = test_scenario::begin(initial_owner);
        {   
            test_scenario::sender(&scenario);

            gop::test_init(test_scenario::ctx(&mut scenario));

        };

        test_scenario::next_tx(&mut scenario, initial_owner);
        {

            let display_object = test_scenario::take_from_sender<display::Display<gop::GopNFT>>(&scenario);

            gop::mint_nft(
                &display_object,
                url, 
                test_scenario::ctx(&mut scenario)
            );

            test_scenario::return_shared(display_object);
            
        };

        test_scenario::next_tx(&mut scenario,final_owner);
        let nftToken;
        {
            nftToken = test_scenario::take_from_sender<gop::GopNFT>(&scenario);
        };

        test_scenario::next_tx(&mut scenario, initial_owner);
        {   
            let admin_cap = test_scenario::take_from_sender<gop::AdminCap>(&scenario);
            gop::burn(nftToken, test_scenario::ctx(&mut scenario));

            test_utils::destroy<gop::AdminCap>(admin_cap); 
        };

        test_scenario::next_tx(&mut scenario, final_owner);
        {
            let nftToken = test_scenario::take_from_sender<gop::GopNFT>(&scenario);

            test_utils::destroy<gop::GopNFT>(nftToken);            
        };

        test_scenario::end(scenario);
    }

    #[test]
    #[expected_failure(abort_code = test_scenario::EEmptyInventory)] 
    fun test_will_error_on_transfer_admin_cap_by_other_address() {

        let initial_owner = @0xCAFE;
        let final_owner = @0xFACE;

        let scenario = test_scenario::begin(initial_owner);
        {   
            test_scenario::sender(&scenario);

            gop::test_init(test_scenario::ctx(&mut scenario));

        };

        test_scenario::next_tx(&mut scenario, final_owner);
        {
            let admin_cap = test_scenario::take_from_sender<gop::AdminCap>(&scenario);

            gop::transfer_admin_cap(admin_cap, final_owner, test_scenario::ctx(&mut scenario));

        };
        
        test_scenario::end(scenario);
    }

    #[test]
    #[expected_failure(abort_code = test_scenario::EEmptyInventory)]
    fun test_will_error_on_transfer_nft_by_other_address() {

        let url = b" ";
        let initial_owner = @0xCAFE;
        let user = @0xEAFF;

        let scenario = test_scenario::begin(initial_owner);
        {   
            test_scenario::sender(&scenario);

            gop::test_init(test_scenario::ctx(&mut scenario));

        };

        test_scenario::next_tx(&mut scenario, initial_owner);
        {

            let display_object = test_scenario::take_from_sender<display::Display<gop::GopNFT>>(&scenario);

            gop::mint_nft(
                &display_object,
                url, 
                test_scenario::ctx(&mut scenario)
            );

            test_utils::destroy<display::Display<gop::GopNFT>>(display_object);
        };

        test_scenario::next_tx(&mut scenario, initial_owner);
        {
            let nftToken = test_scenario::take_from_sender<gop::GopNFT>(&scenario);

            gop::transfer_nft(&mut nftToken, user, test_scenario::ctx(&mut scenario));
            
            test_utils::destroy<gop::GopNFT>(nftToken);
        };

        test_scenario::end(scenario);
    }
        
}
