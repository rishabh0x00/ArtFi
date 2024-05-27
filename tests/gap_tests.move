#[test_only]
module collection::gap_tests {
    // Test attribute is placed before the `fun` keyword. Can be both above or
    // right before the `fun` keyword: `#[test] fun my_test() { ... }`
    // The name of the test would be `book::testing::simple_test`.
    #[test_only]
    use collection::gap;
    use collection::base_nft;
    use sui::url;
    use std::string;
    use sui::tx_context;
    use sui::object;
    use sui::package;

    #[test_only] use sui::test_utils;
    #[test_only] use sui::test_scenario;
    #[test_only] use sui::display;

    #[test]
    // test `name` function
    fun nft_name_test() {
        let name = b"Artfi";
        let nft_url = b"Artfi NFT";
        let nft_info = gap::new_nft_info(string::utf8(name));
        let test_net_nft = gap::new_gap_nft(
            string::utf8(name),
            url::new_unsafe_from_bytes(nft_url), 
            &mut nft_info,
            &mut tx_context::dummy()
        );

        assert!(gap::name(&test_net_nft) == &string::utf8(b"Artfi"), 1);

        let dummy_address = @0xCAFE;
        sui::transfer::public_transfer(test_net_nft, dummy_address);
        test_utils::destroy<gap::NFTInfo>(nft_info);
        
    }

    // test `description` function
    #[test]
    fun nft_description_test() {
        let initial_owner = @0xCAFE;

        let scenario = test_scenario::begin(initial_owner);
        {   
            test_scenario::sender(&scenario);

            gap::test_init(test_scenario::ctx(&mut scenario));

        };

        test_scenario::next_tx(&mut scenario,initial_owner);
        {
            let display_object = test_scenario::take_from_sender<display::Display<gap::GAPNFT>>(&scenario);

            assert!(gap::description(&display_object) == string::utf8(b"Artfi NFT"), 1);

            test_scenario::return_to_sender<display::Display<gap::GAPNFT>>(&scenario, display_object);
        };

        test_scenario::end(scenario);
    }

    #[test]
    // test `url` function
    fun nft_url_test() {
        let name = b"Artfi";
        let nft_url = b" ";
        let nft_info = gap::new_nft_info(string::utf8(name));
        let test_net_nft = gap::new_gap_nft(
            string::utf8(name),
            url::new_unsafe_from_bytes(nft_url), 
            &mut nft_info,
            &mut tx_context::dummy()
        );
        assert!(gap::url(&test_net_nft) ==  &url::new_unsafe_from_bytes(nft_url), 1);

        test_utils::destroy<gap::GAPNFT>(test_net_nft);
        test_utils::destroy<gap::NFTInfo>(nft_info);
    }

    #[test]
    // test `attributes`
    fun nft_attributes_test() {
        let name = b"Artfi";
        let nft_url = b" ";
        let nft_info = gap::new_nft_info(string::utf8(name));
        let test_net_nft = gap::new_gap_nft(
            string::utf8(name),
            url::new_unsafe_from_bytes(nft_url), 
            &mut nft_info,
            &mut tx_context::dummy()
        );
        let attributes_instance = gap::new_attributes(false); 
        assert!(gap::attributes(&test_net_nft, &nft_info) == attributes_instance, 1);

        test_utils::destroy<gap::GAPNFT>(test_net_nft);
        test_utils::destroy<gap::Attributes>(attributes_instance);
        test_utils::destroy<gap::NFTInfo>(nft_info);
    }

    #[test]
    // test `ieo`
    fun nft_ieo_attributes_test() {
        let name = b"Artfi";
        let nft_url = b" ";
        let nft_info = gap::new_nft_info(string::utf8(name));
        let test_net_nft = gap::new_gap_nft(
            string::utf8(name),
            url::new_unsafe_from_bytes(nft_url), 
            &mut nft_info,
            &mut tx_context::dummy()
        );
        assert!(gap::ieo(&test_net_nft, &nft_info) ==  false, 1);

        test_utils::destroy<gap::GAPNFT>(test_net_nft);
        test_utils::destroy<gap::NFTInfo>(nft_info);
    }

    #[test]
    fun test_module_init() {

        let initial_owner = @0xCAFE;
        let final_owner = @0xFACE;

        let scenario = test_scenario::begin(initial_owner);
        {   
            test_scenario::sender(&scenario);

            gap::test_init(test_scenario::ctx(&mut scenario));

        };

        test_scenario::next_tx(&mut scenario,initial_owner);
        {
            let admin_cap = test_scenario::take_from_sender<gap::AdminCap>(&scenario);

            gap::transfer_admin_cap(admin_cap, final_owner, test_scenario::ctx(&mut scenario));
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

            gap::test_init(test_scenario::ctx(&mut scenario));

        };

        test_scenario::next_tx(&mut scenario,initial_owner);
        {
            let admin_cap = test_scenario::take_from_sender<gap::AdminCap>(&scenario);

            gap::transfer_admin_cap(admin_cap, final_owner, test_scenario::ctx(&mut scenario));

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

            gap::test_init(test_scenario::ctx(&mut scenario));

        };

        test_scenario::next_tx(&mut scenario,initial_owner);
        {
            let publisher = test_scenario::take_from_sender<package::Publisher>(&scenario);

            base_nft::transfer_object(publisher, final_owner, test_scenario::ctx(&mut scenario));
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

            gap::test_init(test_scenario::ctx(&mut scenario));

        };

        test_scenario::next_tx(&mut scenario, initial_owner);
        {

            let admin_cap = test_scenario::take_from_sender<gap::AdminCap>(&scenario);
            let nft_info = test_scenario::take_shared<gap::NFTInfo>(&scenario);

            gap::mint_nft_batch(
                &admin_cap,
                &mut nft_info,
                &url,
                &vector[final_owner],
                test_scenario::ctx(&mut scenario)
            );

            test_utils::destroy<gap::AdminCap>(admin_cap);
            test_scenario::return_shared<gap::NFTInfo>(nft_info);
        };

        test_scenario::next_tx(&mut scenario,final_owner);
        {
            let nftToken = test_scenario::take_from_sender<gap::GAPNFT>(&scenario);

            assert!(gap::name(&nftToken) == &string::utf8(b"Artfi"), 1);
            assert!(gap::url(&nftToken) == &url::new_unsafe_from_bytes(b" "), 1);

            let attributes_instance = gap::new_attributes(false);

            let nft_info = test_scenario::take_shared<gap::NFTInfo>(&scenario);
            assert!(gap::attributes(&nftToken, &nft_info) == attributes_instance, 1);
            test_utils::destroy<gap::GAPNFT>(nftToken);
            test_utils::destroy<gap::Attributes>(attributes_instance);
            test_scenario::return_shared<gap::NFTInfo>(nft_info);
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

            gap::test_init(test_scenario::ctx(&mut scenario));

        };

        test_scenario::next_tx(&mut scenario, initial_owner);
        {

            let admin_cap = test_scenario::take_from_sender<gap::AdminCap>(&scenario);
            let nft_info = test_scenario::take_shared<gap::NFTInfo>(&scenario);

            gap::mint_nft_batch(
                &admin_cap, 
                &mut nft_info,
                &url, 
                &vector[initial_owner], 
                test_scenario::ctx(&mut scenario)
            );

            test_utils::destroy<gap::AdminCap>(admin_cap);
            test_scenario::return_shared<gap::NFTInfo>(nft_info);
        };

        test_scenario::next_tx(&mut scenario, initial_owner);
        {

            let nft_object = test_scenario::take_from_sender<gap::GAPNFT>(&scenario);

            base_nft::transfer_object<gap::GAPNFT>(
                nft_object,
                final_owner, 
                test_scenario::ctx(&mut scenario)
            );
        };

        test_scenario::next_tx(&mut scenario,final_owner);
        {
            let nftToken = test_scenario::take_from_sender<gap::GAPNFT>(&scenario);

            assert!(gap::name(&nftToken) == &string::utf8(b"Artfi"), 1);
            assert!(gap::url(&nftToken) == &url::new_unsafe_from_bytes(b" "), 1);

            let attributes_instance = gap::new_attributes(false);

            let nft_info = test_scenario::take_shared<gap::NFTInfo>(&scenario);
            assert!(gap::attributes(&nftToken, &nft_info) == attributes_instance, 1);
            test_utils::destroy<gap::GAPNFT>(nftToken);
            test_utils::destroy<gap::Attributes>(attributes_instance);
            test_scenario::return_shared<gap::NFTInfo>(nft_info);
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

            gap::test_init(test_scenario::ctx(&mut scenario));

        };

        test_scenario::next_tx(&mut scenario, initial_owner);
        {

            let admin_cap = test_scenario::take_from_sender<gap::AdminCap>(&scenario);
            let nft_info = test_scenario::take_shared<gap::NFTInfo>(&scenario);

            gap::mint_nft_batch(
                &admin_cap, 
                &mut nft_info,
                &url, 
                &vector[final_owner], 
                test_scenario::ctx(&mut scenario)
            );

            test_scenario::return_to_sender<gap::AdminCap>(&scenario, admin_cap);
            test_scenario::return_shared<gap::NFTInfo>(nft_info);
        };

        let nft_id;
        test_scenario::next_tx(&mut scenario, final_owner);
        {   
            let nft_object = test_scenario::take_from_sender<gap::GAPNFT>(&scenario);
            nft_id = object::id(&nft_object);

            test_scenario::return_to_sender<gap::GAPNFT>(&scenario, nft_object);
        };

        test_scenario::next_tx(&mut scenario, initial_owner);
        {
            let admin_cap = test_scenario::take_from_sender<gap::AdminCap>(&scenario);
            let nft_info = test_scenario::take_shared<gap::NFTInfo>(&scenario);

            gap::update_attribute(&admin_cap, &mut nft_info, nft_id, true);

            test_utils::destroy<gap::AdminCap>(admin_cap); 
            test_scenario::return_shared<gap::NFTInfo>(nft_info);         
        };

        test_scenario::next_tx(&mut scenario, final_owner);
        {
            let nft_info = test_scenario::take_shared<gap::NFTInfo>(&scenario);
            let nft_object = test_scenario::take_from_sender<gap::GAPNFT>(&scenario);

            assert!(nft_id == object::id(&nft_object), 1);
            assert!(gap::ieo(&nft_object, &nft_info) == true, 4);

            test_scenario::return_shared<gap::NFTInfo>(nft_info);  
            test_scenario::return_to_sender<gap::GAPNFT>(&scenario, nft_object);         
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

            gap::test_init(test_scenario::ctx(&mut scenario));

        };

        test_scenario::next_tx(&mut scenario, initial_owner);
        {

            let admin_cap = test_scenario::take_from_sender<gap::AdminCap>(&scenario);
            let nft_info = test_scenario::take_shared<gap::NFTInfo>(&scenario);

            gap::mint_nft_batch(
                &admin_cap, 
                &mut nft_info,
                &url, 
                &vector[final_owner], 
                test_scenario::ctx(&mut scenario)
            );

            test_utils::destroy<gap::AdminCap>(admin_cap);
            test_scenario::return_shared<gap::NFTInfo>(nft_info);
        };

        test_scenario::next_tx(&mut scenario, initial_owner);
        {

            let nft_object = test_scenario::take_from_sender<gap::GAPNFT>(&scenario);
            let nft_info = test_scenario::take_shared<gap::NFTInfo>(&scenario);

            gap::burn(
                nft_object,
                &mut nft_info,
                test_scenario::ctx(&mut scenario)
            );
            test_scenario::return_shared<gap::NFTInfo>(nft_info);
        };

        test_scenario::next_tx(&mut scenario,final_owner);
        {
            let nft_object = test_scenario::take_from_sender<gap::GAPNFT>(&scenario);
            test_scenario::return_to_sender<gap::GAPNFT>(&scenario, nft_object);
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

            gap::test_init(test_scenario::ctx(&mut scenario));

        };

        test_scenario::next_tx(&mut scenario, final_owner);
        {
            let admin_cap = test_scenario::take_from_sender<gap::AdminCap>(&scenario);

            gap::transfer_admin_cap(admin_cap, final_owner, test_scenario::ctx(&mut scenario));

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

            gap::test_init(test_scenario::ctx(&mut scenario));

        };

        test_scenario::next_tx(&mut scenario, initial_owner);
        {

            let admin_cap = test_scenario::take_from_sender<gap::AdminCap>(&scenario);
            let nft_info = test_scenario::take_shared<gap::NFTInfo>(&scenario);

            gap::mint_nft_batch(
                &admin_cap, 
                &mut nft_info,
                &url, 
                &vector[final_owner], 
                test_scenario::ctx(&mut scenario)
            );

            test_utils::destroy<gap::AdminCap>(admin_cap);
            test_scenario::return_shared<gap::NFTInfo>(nft_info);
        };

        test_scenario::next_tx(&mut scenario, initial_owner);
        {
            let nftToken = test_scenario::take_from_sender<gap::GAPNFT>(&scenario);
            base_nft::transfer_object<gap::GAPNFT>(nftToken, final_owner, test_scenario::ctx(&mut scenario));
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

            gap::test_init(test_scenario::ctx(&mut scenario));

        };

        let nft_object;
        test_scenario::next_tx(&mut scenario, initial_owner);
        {

            let admin_cap = test_scenario::take_from_sender<gap::AdminCap>(&scenario);
            let nft_info = test_scenario::take_shared<gap::NFTInfo>(&scenario);

            gap::mint_nft_batch(
                &admin_cap, 
                &mut nft_info,
                &url, 
                &vector[final_owner], 
                test_scenario::ctx(&mut scenario)
            );

            nft_object = test_scenario::take_from_sender<gap::GAPNFT>(&scenario);

            test_utils::destroy<gap::AdminCap>(admin_cap);
            test_scenario::return_shared<gap::NFTInfo>(nft_info);
            
        };

        test_scenario::next_tx(&mut scenario, final_owner);
        {
            let nft_info = test_scenario::take_shared<gap::NFTInfo>(&scenario);
            let admin_cap = test_scenario::take_from_sender<gap::AdminCap>(&scenario);

            gap::update_attribute(&admin_cap, &mut nft_info, object::id(&nft_object), true);

            test_scenario::return_shared<gap::NFTInfo>(nft_info);
            test_utils::destroy<gap::AdminCap>(admin_cap);
        };

        test_scenario::end(scenario);
        test_utils::destroy<gap::GAPNFT>(nft_object);
    }  
}
