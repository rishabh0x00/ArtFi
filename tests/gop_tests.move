#[test_only]
module collection::gop_tests {
    // Test attribute is placed before the `fun` keyword. Can be both above or
    // right before the `fun` keyword: `#[test] fun my_test() { ... }`
    // The name of the test would be `book::testing::simple_test`.
    #[test_only]
    use collection::gop;
    use collection::base_nft;
    use sui::url;
    use std::string;
    use sui::tx_context;
    use sui::object;
    use sui::package;

    #[test_only] use sui::test_utils;
    #[test_only] use sui::test_scenario;
    #[test_only] use sui::display;
    #[test_only] use sui::coin;
    #[test_only] use sui::balance;

    #[test]
    // test `name` function
    fun nft_name_test() {
        let name = b"Artfi";
        let nft_url = b"Artfi NFT";
        let nft_info = gop::new_nft_info(string::utf8(name));
        let test_net_nft = gop::new_gop_nft(
            string::utf8(name),
            url::new_unsafe_from_bytes(nft_url), 
            &mut nft_info,
            &mut tx_context::dummy()
        );

        assert!(gop::name(&test_net_nft) == &string::utf8(b"Artfi"), 1);

        let dummy_address = @0xCAFE;
        sui::transfer::public_transfer(test_net_nft, dummy_address);
        test_utils::destroy<gop::NFTInfo>(nft_info);
        
    }

    // test `description` function
    #[test]
    fun nft_description_test() {
        let initial_owner = @0xCAFE;

        let scenario = test_scenario::begin(initial_owner);
        {   
            test_scenario::sender(&scenario);

            gop::test_init(test_scenario::ctx(&mut scenario));

        };

        test_scenario::next_tx(&mut scenario,initial_owner);
        {
            let display_object = test_scenario::take_from_sender<display::Display<gop::GOPNFT>>(&scenario);

            assert!(gop::description(&display_object) == string::utf8(b"Artfi NFT"), 1);

            test_scenario::return_to_sender<display::Display<gop::GOPNFT>>(&scenario, display_object);
        };

        test_scenario::end(scenario);
    }

    #[test]
    // test `url` function
    fun nft_url_test() {
        let name = b"Artfi";
        let nft_url = b" ";
        let nft_info = gop::new_nft_info(string::utf8(name));
        let test_net_nft = gop::new_gop_nft(
            string::utf8(name),
            url::new_unsafe_from_bytes(nft_url), 
            &mut nft_info,
            &mut tx_context::dummy()
        );
        assert!(gop::url(&test_net_nft) ==  &url::new_unsafe_from_bytes(nft_url), 1);

        test_utils::destroy<gop::GOPNFT>(test_net_nft);
        test_utils::destroy<gop::NFTInfo>(nft_info);
    }

    #[test]
    // test `attributes`
    fun nft_attributes_test() {
        let name = b"Artfi";
        let nft_url = b" ";
        let nft_info = gop::new_nft_info(string::utf8(name));
        let test_net_nft = gop::new_gop_nft(
            string::utf8(name),
            url::new_unsafe_from_bytes(nft_url), 
            &mut nft_info,
            &mut tx_context::dummy()
        );
        let attributes_instance = gop::new_attributes(false, false, false); 
        assert!(gop::attributes(&test_net_nft, &nft_info) == attributes_instance, 1);

        test_utils::destroy<gop::GOPNFT>(test_net_nft);
        test_utils::destroy<gop::Attributes>(attributes_instance);
        test_utils::destroy<gop::NFTInfo>(nft_info);
    }

    #[test]
    // test `claimed` 
    fun nft_claimed_attributes_test() {
        let name = b"Artfi";
        let nft_url = b" ";
        let nft_info = gop::new_nft_info(string::utf8(name));
        let test_net_nft = gop::new_gop_nft(
            string::utf8(name),
            url::new_unsafe_from_bytes(nft_url),
            &mut nft_info,
            &mut tx_context::dummy()
        );
        assert!(gop::claimed(&test_net_nft, &nft_info) ==  false, 1);

        test_utils::destroy<gop::GOPNFT>(test_net_nft);
        test_utils::destroy<gop::NFTInfo>(nft_info);
    }

    #[test]
    // test `airdrop` 
    fun nft_airdrop_attributes_test() {
        let name = b"Artfi";
        let nft_url = b" ";
        let nft_info = gop::new_nft_info(string::utf8(name));
        let test_net_nft = gop::new_gop_nft(
            string::utf8(name),
            url::new_unsafe_from_bytes(nft_url), 
            &mut nft_info,
            &mut tx_context::dummy()
        );
        assert!(gop::airdrop(&test_net_nft, &nft_info) ==  false, 1);

        test_utils::destroy<gop::GOPNFT>(test_net_nft);
        test_utils::destroy<gop::NFTInfo>(nft_info);
    }

    #[test]
    // test `ieo`
    fun nft_ieo_attributes_test() {
        let name = b"Artfi";
        let nft_url = b" ";
        let nft_info = gop::new_nft_info(string::utf8(name));
        let test_net_nft = gop::new_gop_nft(
            string::utf8(name),
            url::new_unsafe_from_bytes(nft_url), 
            &mut nft_info,
            &mut tx_context::dummy()
        );
        assert!(gop::ieo(&test_net_nft, &nft_info) ==  false, 1);

        test_utils::destroy<gop::GOPNFT>(test_net_nft);
        test_utils::destroy<gop::NFTInfo>(nft_info);
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
    fun test_publisher() {

        let initial_owner = @0xCAFE;
        let final_owner = @0xFACE;

        let scenario = test_scenario::begin(initial_owner);
        {   
            test_scenario::sender(&scenario);

            gop::test_init(test_scenario::ctx(&mut scenario));

        };

        test_scenario::next_tx(&mut scenario,initial_owner);
        {
            let publisher = test_scenario::take_from_sender<package::Publisher>(&scenario);

            base_nft::transfer_object(publisher, final_owner, test_scenario::ctx(&mut scenario));
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

        test_scenario::next_tx(&mut scenario, initial_owner);
        {   
            let admin_cap = test_scenario::take_from_sender<gop::AdminCap>(&scenario);
            gop::init_buy_info<gop::GOPNFT>(&admin_cap, 10, test_scenario::ctx(&mut scenario));
            test_scenario::return_to_sender<gop::AdminCap>(&scenario, admin_cap);
        };

        test_scenario::next_tx(&mut scenario, final_owner);
        {
            let buy_info = test_scenario::take_shared<gop::BuyInfo<gop::GOPNFT>>(&scenario);
            let nft_info = test_scenario::take_shared<gop::NFTInfo>(&scenario);
            let coin: coin::Coin<gop::GOPNFT> = coin::mint_for_testing<gop::GOPNFT>(10, test_scenario::ctx(&mut scenario));
            gop::buy_gop<gop::GOPNFT>(
                &mut buy_info, 
                coin,
                &mut nft_info,
                url,
                test_scenario::ctx(&mut scenario)
            );

            test_scenario::return_shared(nft_info);
            test_scenario::return_shared(buy_info);
        };

        test_scenario::next_tx(&mut scenario,final_owner);
        {
            let nftToken = test_scenario::take_from_sender<gop::GOPNFT>(&scenario);
            let buy_info = test_scenario::take_shared<gop::BuyInfo<gop::GOPNFT>>(&scenario);

            assert!(gop::name(&nftToken) == &string::utf8(b"Artfi"), 1);
            assert!(gop::url(&nftToken) == &url::new_unsafe_from_bytes(url), 2);
            let attributes_instance = gop::new_attributes(false, false, false);

            let nft_info = test_scenario::take_shared<gop::NFTInfo>(&scenario);
            assert!(gop::attributes(&nftToken, &nft_info) == attributes_instance, 3);
            assert!(gop::balance_of_buy_info(&buy_info) == 10, 4);

            test_utils::destroy<gop::GOPNFT>(nftToken);
            test_utils::destroy<gop::Attributes>(attributes_instance);
            test_scenario::return_shared<gop::NFTInfo>(nft_info);
            test_scenario::return_shared(buy_info);
            
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

        test_scenario::next_tx(&mut scenario, initial_owner);
        {

            let admin_cap = test_scenario::take_from_sender<gop::AdminCap>(&scenario);
            let nft_info = test_scenario::take_shared<gop::NFTInfo>(&scenario);

            gop::mint_nft_batch(
                &admin_cap, 
                &mut nft_info,
                &url, 
                final_owner, 
                test_scenario::ctx(&mut scenario)
            );

            test_utils::destroy<gop::AdminCap>(admin_cap);
            test_scenario::return_shared<gop::NFTInfo>(nft_info);
        };

        test_scenario::next_tx(&mut scenario,final_owner);
        {
            let nftToken = test_scenario::take_from_sender<gop::GOPNFT>(&scenario);

            assert!(gop::name(&nftToken) == &string::utf8(b"Artfi"), 1);
            assert!(gop::url(&nftToken) == &url::new_unsafe_from_bytes(b" "), 1);

            let attributes_instance = gop::new_attributes(false, false, false);

            let nft_info = test_scenario::take_shared<gop::NFTInfo>(&scenario);
            assert!(gop::attributes(&nftToken, &nft_info) == attributes_instance, 1);
            test_utils::destroy<gop::GOPNFT>(nftToken);
            test_utils::destroy<gop::Attributes>(attributes_instance);
            test_scenario::return_shared<gop::NFTInfo>(nft_info);
        };

        test_scenario::end(scenario);
    }

    #[test]
    fun test_transfer_nft() {
        let url = vector[b" "];
        let initial_owner = @0xCAFE;
        let final_owner = @0xFACE;

        let scenario = test_scenario::begin(initial_owner);
        {   
            test_scenario::sender(&scenario);

            gop::test_init(test_scenario::ctx(&mut scenario));

        };

        test_scenario::next_tx(&mut scenario, initial_owner);
        {

            let admin_cap = test_scenario::take_from_sender<gop::AdminCap>(&scenario);
            let nft_info = test_scenario::take_shared<gop::NFTInfo>(&scenario);

            gop::mint_nft_batch(
                &admin_cap, 
                &mut nft_info,
                &url, 
                initial_owner, 
                test_scenario::ctx(&mut scenario)
            );

            test_utils::destroy<gop::AdminCap>(admin_cap);
            test_scenario::return_shared<gop::NFTInfo>(nft_info);
        };

        test_scenario::next_tx(&mut scenario, initial_owner);
        {

            let nft_object = test_scenario::take_from_sender<gop::GOPNFT>(&scenario);

            base_nft::transfer_object<gop::GOPNFT>(
                nft_object,
                final_owner, 
                test_scenario::ctx(&mut scenario)
            );
        };

        test_scenario::next_tx(&mut scenario,final_owner);
        {
            let nftToken = test_scenario::take_from_sender<gop::GOPNFT>(&scenario);

            assert!(gop::name(&nftToken) == &string::utf8(b"Artfi"), 1);
            assert!(gop::url(&nftToken) == &url::new_unsafe_from_bytes(b" "), 1);

            let attributes_instance = gop::new_attributes(false, false, false);

            let nft_info = test_scenario::take_shared<gop::NFTInfo>(&scenario);
            assert!(gop::attributes(&nftToken, &nft_info) == attributes_instance, 1);
            test_utils::destroy<gop::GOPNFT>(nftToken);
            test_utils::destroy<gop::Attributes>(attributes_instance);
            test_scenario::return_shared<gop::NFTInfo>(nft_info);
        };

        test_scenario::end(scenario);
    }

    #[test]
    #[expected_failure(abort_code = test_scenario::EEmptyInventory)] 
    fun test_burn_nft() {
        let url = vector[b" "];
        let initial_owner = @0xCAFE;
        let final_owner = @0xFACE;

        let scenario = test_scenario::begin(initial_owner);
        {   
            test_scenario::sender(&scenario);

            gop::test_init(test_scenario::ctx(&mut scenario));

        };

        test_scenario::next_tx(&mut scenario, initial_owner);
        {

            let admin_cap = test_scenario::take_from_sender<gop::AdminCap>(&scenario);
            let nft_info = test_scenario::take_shared<gop::NFTInfo>(&scenario);

            gop::mint_nft_batch(
                &admin_cap, 
                &mut nft_info,
                &url, 
                initial_owner, 
                test_scenario::ctx(&mut scenario)
            );

            test_utils::destroy<gop::AdminCap>(admin_cap);
            test_scenario::return_shared<gop::NFTInfo>(nft_info);
        };

        test_scenario::next_tx(&mut scenario, initial_owner);
        {

            let nft_object = test_scenario::take_from_sender<gop::GOPNFT>(&scenario);
            let nft_info = test_scenario::take_shared<gop::NFTInfo>(&scenario);

            gop::burn(
                nft_object,
                &mut nft_info,
                test_scenario::ctx(&mut scenario)
            );
            test_scenario::return_shared<gop::NFTInfo>(nft_info);
        };

        test_scenario::next_tx(&mut scenario,final_owner);
        {
            let nft_object = test_scenario::take_from_sender<gop::GOPNFT>(&scenario);
            test_scenario::return_to_sender<gop::GOPNFT>(&scenario, nft_object);
        };

        test_scenario::end(scenario);
    }

    #[test]
    fun test_update_nft_attributes() {
        let url = vector[b" "];
        let initial_owner = @0xCAFE;
        let final_owner = @0xFACE;

        let scenario = test_scenario::begin(initial_owner);
        {   
            test_scenario::sender(&scenario);

            gop::test_init(test_scenario::ctx(&mut scenario));

        };

        test_scenario::next_tx(&mut scenario, initial_owner);
        {

            let admin_cap = test_scenario::take_from_sender<gop::AdminCap>(&scenario);
            let nft_info = test_scenario::take_shared<gop::NFTInfo>(&scenario);

            gop::mint_nft_batch(
                &admin_cap, 
                &mut nft_info,
                &url, 
                final_owner, 
                test_scenario::ctx(&mut scenario)
            );

            test_scenario::return_to_sender<gop::AdminCap>(&scenario, admin_cap);
            test_scenario::return_shared<gop::NFTInfo>(nft_info);
        };

        let nft_id;
        test_scenario::next_tx(&mut scenario, final_owner);
        {   
            let nft_object = test_scenario::take_from_sender<gop::GOPNFT>(&scenario);
            nft_id = object::id(&nft_object);

            test_scenario::return_to_sender<gop::GOPNFT>(&scenario, nft_object);
        };

        test_scenario::next_tx(&mut scenario, initial_owner);
        {
            let admin_cap = test_scenario::take_from_sender<gop::AdminCap>(&scenario);
            let nft_info = test_scenario::take_shared<gop::NFTInfo>(&scenario);

            gop::update_attribute(&admin_cap, &mut nft_info, nft_id, true, false , true);

            test_utils::destroy<gop::AdminCap>(admin_cap); 
            test_scenario::return_shared<gop::NFTInfo>(nft_info);         
        };

        test_scenario::next_tx(&mut scenario, final_owner);
        {
            let nft_info = test_scenario::take_shared<gop::NFTInfo>(&scenario);
            let nft_object = test_scenario::take_from_sender<gop::GOPNFT>(&scenario);

            assert!(nft_id == object::id(&nft_object), 1);
            assert!(gop::claimed(&nft_object, &nft_info) == true, 2);
            assert!(gop::airdrop(&nft_object, &nft_info) == false, 3);
            assert!(gop::ieo(&nft_object, &nft_info) == true, 4);

            test_scenario::return_shared<gop::NFTInfo>(nft_info);  
            test_scenario::return_to_sender<gop::GOPNFT>(&scenario, nft_object);         
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
        let url = vector[b" "];
        let initial_owner = @0xCAFE;
        let final_owner = @0xFACE;

        let scenario = test_scenario::begin(initial_owner);
        {   
            test_scenario::sender(&scenario);

            gop::test_init(test_scenario::ctx(&mut scenario));

        };

        test_scenario::next_tx(&mut scenario, initial_owner);
        {

            let admin_cap = test_scenario::take_from_sender<gop::AdminCap>(&scenario);
            let nft_info = test_scenario::take_shared<gop::NFTInfo>(&scenario);

            gop::mint_nft_batch(
                &admin_cap, 
                &mut nft_info,
                &url, 
                final_owner, 
                test_scenario::ctx(&mut scenario)
            );

            test_utils::destroy<gop::AdminCap>(admin_cap);
            test_scenario::return_shared<gop::NFTInfo>(nft_info);
        };

        test_scenario::next_tx(&mut scenario, initial_owner);
        {
            let nftToken = test_scenario::take_from_sender<gop::GOPNFT>(&scenario);
            base_nft::transfer_object<gop::GOPNFT>(nftToken, final_owner, test_scenario::ctx(&mut scenario));
        };

        test_scenario::end(scenario);
    }

    #[test]
    #[expected_failure(abort_code = test_scenario::EEmptyInventory)] 
    fun test_will_error_on_update_of_nft_attributes_by_other_user() {

        let url = vector[b" "];
        let initial_owner = @0xCAFE;
        let final_owner = @0xFACE;

        let scenario = test_scenario::begin(initial_owner);
        {   
            test_scenario::sender(&scenario);

            gop::test_init(test_scenario::ctx(&mut scenario));

        };

        let nft_object;
        test_scenario::next_tx(&mut scenario, initial_owner);
        {

            let admin_cap = test_scenario::take_from_sender<gop::AdminCap>(&scenario);
            let nft_info = test_scenario::take_shared<gop::NFTInfo>(&scenario);

            gop::mint_nft_batch(
                &admin_cap, 
                &mut nft_info,
                &url, 
                final_owner, 
                test_scenario::ctx(&mut scenario)
            );

            nft_object = test_scenario::take_from_sender<gop::GOPNFT>(&scenario);

            test_utils::destroy<gop::AdminCap>(admin_cap);
            test_scenario::return_shared<gop::NFTInfo>(nft_info);
            
        };

        test_scenario::next_tx(&mut scenario, final_owner);
        {
            let nft_info = test_scenario::take_shared<gop::NFTInfo>(&scenario);
            let admin_cap = test_scenario::take_from_sender<gop::AdminCap>(&scenario);

            gop::update_attribute(&admin_cap, &mut nft_info, object::id(&nft_object), true, false, false);

            test_scenario::return_shared<gop::NFTInfo>(nft_info);
            test_utils::destroy<gop::AdminCap>(admin_cap);
        };

        test_scenario::end(scenario);
        test_utils::destroy<gop::GOPNFT>(nft_object);
    }

    #[test]
    #[expected_failure(abort_code = gop::EAmountIncorrect)] 
    fun test_will_error_on_wrong_multiple_of_price() {
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
            let admin_cap = test_scenario::take_from_sender<gop::AdminCap>(&scenario);
            gop::init_buy_info<gop::GOPNFT>(&admin_cap, 10, test_scenario::ctx(&mut scenario));
            test_scenario::return_to_sender<gop::AdminCap>(&scenario, admin_cap);
        };

        test_scenario::next_tx(&mut scenario, final_owner);
        {
            let buy_info = test_scenario::take_shared<gop::BuyInfo<gop::GOPNFT>>(&scenario);
            let nft_info = test_scenario::take_shared<gop::NFTInfo>(&scenario);
            let coin: coin::Coin<gop::GOPNFT> = coin::mint_for_testing<gop::GOPNFT>(11, test_scenario::ctx(&mut scenario));
            gop::buy_gop<gop::GOPNFT>(
                &mut buy_info, 
                coin,
                &mut nft_info,
                url,
                test_scenario::ctx(&mut scenario)
            );

            test_scenario::return_shared(nft_info);
            test_scenario::return_shared(buy_info);
        };

        test_scenario::end(scenario);
    }
        
}
