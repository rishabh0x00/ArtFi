#[test_only]
module collection::trophy_tests {
    // Test attribute is placed before the `fun` keyword. Can be both above or
    // right before the `fun` keyword: `#[test] fun my_test() { ... }`
    // The name of the test would be `book::testing::simple_test`.
    #[test_only]
    use collection::trophy;
    use collection::base_nft;
    use collection::nft;
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
        let nft_info = trophy::new_nft_info(string::utf8(name));
        let test_net_nft = trophy::new_trophy_nft(
            string::utf8(name),
            url::new_unsafe_from_bytes(nft_url), 
            &mut nft_info,
            1,
            &mut tx_context::dummy()
        );

        assert!(trophy::name(&test_net_nft) == &string::utf8(b"Artfi"), 1);

        let dummy_address = @0xCAFE;
        sui::transfer::public_transfer(test_net_nft, dummy_address);
        test_utils::destroy<trophy::NFTInfo>(nft_info);
        
    }

    // test `description` function
    #[test]
    fun nft_description_test() {
        let initial_owner = @0xCAFE;

        let scenario = test_scenario::begin(initial_owner);
        {   
            test_scenario::sender(&scenario);

            trophy::test_init(test_scenario::ctx(&mut scenario));

        };

        test_scenario::next_tx(&mut scenario,initial_owner);
        {
            let display_object = test_scenario::take_from_sender<display::Display<trophy::TrophyNFT>>(&scenario);

            assert!(trophy::description(&display_object) == string::utf8(b"Artfi NFT"), 1);

            test_scenario::return_to_sender<display::Display<trophy::TrophyNFT>>(&scenario, display_object);
        };

        test_scenario::end(scenario);
    }

    #[test]
    // test `url` function
    fun nft_url_test() {
        let name = b"Artfi";
        let nft_url = b" ";
        let nft_info = trophy::new_nft_info(string::utf8(name));
        let test_net_nft = trophy::new_trophy_nft(
            string::utf8(name),
            url::new_unsafe_from_bytes(nft_url), 
            &mut nft_info,
            1,
            &mut tx_context::dummy()
        );
        assert!(trophy::url(&test_net_nft) ==  &url::new_unsafe_from_bytes(nft_url), 1);

        test_utils::destroy<trophy::TrophyNFT>(test_net_nft);
        test_utils::destroy<trophy::NFTInfo>(nft_info);
    }

    #[test]
    // test `attributes`
    fun nft_attributes_test() {
        let name = b"Artfi";
        let nft_url = b" ";
        let nft_info = trophy::new_nft_info(string::utf8(name));
        let test_net_nft = trophy::new_trophy_nft(
            string::utf8(name),
            url::new_unsafe_from_bytes(nft_url), 
            &mut nft_info,
            1,
            &mut tx_context::dummy()
        );
        let attributes_instance = trophy::new_attributes(1, string::utf8(b"")); 
        assert!(trophy::attributes(&test_net_nft, &nft_info) == attributes_instance, 1);

        test_utils::destroy<trophy::TrophyNFT>(test_net_nft);
        test_utils::destroy<trophy::Attributes>(attributes_instance);
        test_utils::destroy<trophy::NFTInfo>(nft_info);
    }

    #[test]
    // test `claimed` 
    fun nft_fraction_id_attributes_test() {
        let name = b"Artfi";
        let nft_url = b" ";
        let nft_info = trophy::new_nft_info(string::utf8(name));
        let test_net_nft = trophy::new_trophy_nft(
            string::utf8(name),
            url::new_unsafe_from_bytes(nft_url), 
            &mut nft_info,
            1,
            &mut tx_context::dummy()
        );
        assert!(trophy::fraction_id(&test_net_nft, &nft_info) ==  1, 1);

        test_utils::destroy<trophy::TrophyNFT>(test_net_nft);
        test_utils::destroy<trophy::NFTInfo>(nft_info);
    }

    #[test]
    // test `airdrop` 
    fun nft_shipment_status_attributes_test() {
        let name = b"Artfi";
        let nft_url = b" ";
        let nft_info = trophy::new_nft_info(string::utf8(name));
        let test_net_nft = trophy::new_trophy_nft(
            string::utf8(name),
            url::new_unsafe_from_bytes(nft_url), 
            &mut nft_info,
            1,
            &mut tx_context::dummy()
        );
        assert!(trophy::shipment_status(&test_net_nft, &nft_info) ==  string::utf8(b""), 1);

        test_utils::destroy<trophy::TrophyNFT>(test_net_nft);
        test_utils::destroy<trophy::NFTInfo>(nft_info);
    }

    #[test]
    fun test_module_init() {

        let initial_owner = @0xCAFE;
        let final_owner = @0xFACE;

        let scenario = test_scenario::begin(initial_owner);
        {   
            test_scenario::sender(&scenario);

            trophy::test_init(test_scenario::ctx(&mut scenario));

        };

        test_scenario::next_tx(&mut scenario,initial_owner);
        {
            let admin_cap = test_scenario::take_from_sender<trophy::AdminCap>(&scenario);

            trophy::transfer_admin_cap(admin_cap, final_owner, test_scenario::ctx(&mut scenario));
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

            trophy::test_init(test_scenario::ctx(&mut scenario));

        };

        test_scenario::next_tx(&mut scenario,initial_owner);
        {
            let admin_cap = test_scenario::take_from_sender<trophy::AdminCap>(&scenario);

            trophy::transfer_admin_cap(admin_cap, final_owner, test_scenario::ctx(&mut scenario));

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

            trophy::test_init(test_scenario::ctx(&mut scenario));

        };

        test_scenario::next_tx(&mut scenario,initial_owner);
        {
            let publisher = test_scenario::take_from_sender<package::Publisher>(&scenario);

            base_nft::transfer_publisher_object(publisher, final_owner, test_scenario::ctx(&mut scenario));
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

            trophy::test_init(test_scenario::ctx(&mut scenario));

        };

        test_scenario::next_tx(&mut scenario, final_owner);
        {
            let nft_info = test_scenario::take_shared<trophy::NFTInfo>(&scenario);
            let royalty = nft::new_royalty(3, 3, 4);
            let nft_info_artfi = nft::new_nft_info(string::utf8(b"name"), royalty);
            let test_net_nft = nft::new_artfi_nft(
                string::utf8(b"name"),
                url::new_unsafe_from_bytes(b"url"), 
                1,
                &mut nft_info_artfi,
                &mut tx_context::dummy()
            );
            trophy::mint_nft(
                &mut nft_info,
                &test_net_nft,
                url,
                test_scenario::ctx(&mut scenario)
            );

            test_utils::destroy<nft::ArtfiNFT>(test_net_nft);
            test_utils::destroy<nft::NFTInfo>(nft_info_artfi);
            test_scenario::return_shared(nft_info);
        };

        test_scenario::next_tx(&mut scenario,final_owner);
        {
            let nftToken = test_scenario::take_from_sender<trophy::TrophyNFT>(&scenario);

            assert!(trophy::name(&nftToken) == &string::utf8(b"Artfi"), 1);
            assert!(trophy::url(&nftToken) == &url::new_unsafe_from_bytes(url), 2);
            let attributes_instance = trophy::new_attributes(1, string::utf8(b""));

            let nft_info = test_scenario::take_shared<trophy::NFTInfo>(&scenario);
            assert!(trophy::attributes(&nftToken, &nft_info) == attributes_instance, 3);
            assert!(trophy::fraction_id(&nftToken, &nft_info) == 1, 4);
            assert!(trophy::shipment_status(&nftToken, &nft_info) == string::utf8(b""), 4);

            test_utils::destroy<trophy::TrophyNFT>(nftToken);
            test_utils::destroy<trophy::Attributes>(attributes_instance);
            test_scenario::return_shared<trophy::NFTInfo>(nft_info);
            
        };

        test_scenario::end(scenario);
    }

    #[test]
    fun test_transfer_nft() {
        let url = b" ";
        let initial_owner = @0xCAFE;
        let final_owner = @0xFACE;

        let scenario = test_scenario::begin(initial_owner);
        {   
            test_scenario::sender(&scenario);

            trophy::test_init(test_scenario::ctx(&mut scenario));

        };

        test_scenario::next_tx(&mut scenario, initial_owner);
        {

            let nft_info = test_scenario::take_shared<trophy::NFTInfo>(&scenario);
            let royalty = nft::new_royalty(3, 3, 4);
            let nft_info_artfi = nft::new_nft_info(string::utf8(b"name"), royalty);
            let test_net_nft = nft::new_artfi_nft(
                string::utf8(b"name"),
                url::new_unsafe_from_bytes(b"url"), 
                1,
                &mut nft_info_artfi,
                &mut tx_context::dummy()
            );

            trophy::mint_nft(
                &mut nft_info,
                &test_net_nft,
                url,
                test_scenario::ctx(&mut scenario)
            );

            test_utils::destroy<nft::ArtfiNFT>(test_net_nft);
            test_utils::destroy<nft::NFTInfo>(nft_info_artfi);

            test_scenario::return_shared(nft_info);
        };

        test_scenario::next_tx(&mut scenario, initial_owner);
        {

            let nft_object = test_scenario::take_from_sender<trophy::TrophyNFT>(&scenario);

            trophy::transfer_nft(
                nft_object,
                final_owner, 
                test_scenario::ctx(&mut scenario)
            );
        };

        test_scenario::next_tx(&mut scenario,final_owner);
        {
            let nftToken = test_scenario::take_from_sender<trophy::TrophyNFT>(&scenario);

            assert!(trophy::name(&nftToken) == &string::utf8(b"Artfi"), 1);
            assert!(trophy::url(&nftToken) == &url::new_unsafe_from_bytes(b" "), 1);

            let attributes_instance = trophy::new_attributes(1, string::utf8(b""));

            let nft_info = test_scenario::take_shared<trophy::NFTInfo>(&scenario);
            assert!(trophy::attributes(&nftToken, &nft_info) == attributes_instance, 1);
            test_utils::destroy<trophy::TrophyNFT>(nftToken);
            test_utils::destroy<trophy::Attributes>(attributes_instance);
            test_scenario::return_shared<trophy::NFTInfo>(nft_info);
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

            trophy::test_init(test_scenario::ctx(&mut scenario));

        };

        test_scenario::next_tx(&mut scenario, initial_owner);
        {

            let nft_info = test_scenario::take_shared<trophy::NFTInfo>(&scenario);
            let royalty = nft::new_royalty(3, 3, 4);
            let nft_info_artfi = nft::new_nft_info(string::utf8(b"name"), royalty);
            let test_net_nft = nft::new_artfi_nft(
                string::utf8(b"name"),
                url::new_unsafe_from_bytes(b"url"), 
                1,
                &mut nft_info_artfi,
                &mut tx_context::dummy()
            );
            trophy::mint_nft(
                &mut nft_info,
                &test_net_nft,
                url,
                test_scenario::ctx(&mut scenario)
            );

            test_utils::destroy<nft::ArtfiNFT>(test_net_nft);
            test_utils::destroy<nft::NFTInfo>(nft_info_artfi);

            test_scenario::return_shared(nft_info);
        };

        test_scenario::next_tx(&mut scenario, initial_owner);
        {

            let nft_object = test_scenario::take_from_sender<trophy::TrophyNFT>(&scenario);
            let nft_info = test_scenario::take_shared<trophy::NFTInfo>(&scenario);

            trophy::burn(
                nft_object,
                &mut nft_info,
                test_scenario::ctx(&mut scenario)
            );
            test_scenario::return_shared<trophy::NFTInfo>(nft_info);
        };

        test_scenario::next_tx(&mut scenario,final_owner);
        {
            let nft_object = test_scenario::take_from_sender<trophy::TrophyNFT>(&scenario);
            test_scenario::return_to_sender<trophy::TrophyNFT>(&scenario, nft_object);
        };

        test_scenario::end(scenario);
    }

    #[test]
    fun test_update_nft_attributes() {
        let url = b" ";
        let initial_owner = @0xCAFE;
        let final_owner = @0xFACE;

        let scenario = test_scenario::begin(initial_owner);
        {   
            test_scenario::sender(&scenario);

            trophy::test_init(test_scenario::ctx(&mut scenario));

        };

        test_scenario::next_tx(&mut scenario, final_owner);
        {

            let nft_info = test_scenario::take_shared<trophy::NFTInfo>(&scenario);
            let royalty = nft::new_royalty(3, 3, 4);
            let nft_info_artfi = nft::new_nft_info(string::utf8(b"name"), royalty);
            let test_net_nft = nft::new_artfi_nft(
                string::utf8(b"name"),
                url::new_unsafe_from_bytes(b"url"), 
                1,
                &mut nft_info_artfi,
                &mut tx_context::dummy()
            );
            trophy::mint_nft(
                &mut nft_info,
                &test_net_nft,
                url,
                test_scenario::ctx(&mut scenario)
            );

            test_utils::destroy<nft::ArtfiNFT>(test_net_nft);
            test_utils::destroy<nft::NFTInfo>(nft_info_artfi);
            test_scenario::return_shared(nft_info);
        };

        let nft_id;
        test_scenario::next_tx(&mut scenario, final_owner);
        {   
            let nft_object = test_scenario::take_from_sender<trophy::TrophyNFT>(&scenario);
            nft_id = object::id(&nft_object);

            test_scenario::return_to_sender<trophy::TrophyNFT>(&scenario, nft_object);
        };

        test_scenario::next_tx(&mut scenario, initial_owner);
        {
            let admin_cap = test_scenario::take_from_sender<trophy::AdminCap>(&scenario);
            let nft_info = test_scenario::take_shared<trophy::NFTInfo>(&scenario);

            trophy::update_attribute(&admin_cap, &mut nft_info, nft_id, string::utf8(b"checking"));

            test_utils::destroy<trophy::AdminCap>(admin_cap); 
            test_scenario::return_shared<trophy::NFTInfo>(nft_info);         
        };

        test_scenario::next_tx(&mut scenario, final_owner);
        {
            let nft_info = test_scenario::take_shared<trophy::NFTInfo>(&scenario);
            let nft_object = test_scenario::take_from_sender<trophy::TrophyNFT>(&scenario);

            assert!(nft_id == object::id(&nft_object), 1);
            assert!(trophy::fraction_id(&nft_object, &nft_info) == 1, 2);
            assert!(trophy::shipment_status(&nft_object, &nft_info) == string::utf8(b"checking"), 3);
            assert!(trophy::fraction_to_nft_id(1, &nft_info) == nft_id, 4);

            test_scenario::return_shared<trophy::NFTInfo>(nft_info);  
            test_scenario::return_to_sender<trophy::TrophyNFT>(&scenario, nft_object);         
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

            trophy::test_init(test_scenario::ctx(&mut scenario));

        };

        test_scenario::next_tx(&mut scenario, final_owner);
        {
            let admin_cap = test_scenario::take_from_sender<trophy::AdminCap>(&scenario);

            trophy::transfer_admin_cap(admin_cap, final_owner, test_scenario::ctx(&mut scenario));

        };
        
        test_scenario::end(scenario);
    }

    #[test]
    #[expected_failure(abort_code = test_scenario::EEmptyInventory)]
    fun test_will_error_on_transfer_nft_by_other_address() {
        let url = b" ";
        let initial_owner = @0xCAFE;
        let final_owner = @0xFACE;

        let scenario = test_scenario::begin(initial_owner);
        {   
            test_scenario::sender(&scenario);

            trophy::test_init(test_scenario::ctx(&mut scenario));

        };

        test_scenario::next_tx(&mut scenario, final_owner);
        {
            let nft_info = test_scenario::take_shared<trophy::NFTInfo>(&scenario);
            let royalty = nft::new_royalty(3, 3, 4);
            let nft_info_artfi = nft::new_nft_info(string::utf8(b"name"), royalty);
            let test_net_nft = nft::new_artfi_nft(
                string::utf8(b"name"),
                url::new_unsafe_from_bytes(b"url"), 
                1,
                &mut nft_info_artfi,
                &mut tx_context::dummy()
            );
            trophy::mint_nft(
                &mut nft_info,
                &test_net_nft,
                url,
                test_scenario::ctx(&mut scenario)
            );

            test_utils::destroy<nft::ArtfiNFT>(test_net_nft);
            test_utils::destroy<nft::NFTInfo>(nft_info_artfi);

            test_scenario::return_shared(nft_info);
        };

        test_scenario::next_tx(&mut scenario, initial_owner);
        {
            let nftToken = test_scenario::take_from_sender<trophy::TrophyNFT>(&scenario);
            trophy::transfer_nft(nftToken, final_owner, test_scenario::ctx(&mut scenario));
        };

        test_scenario::end(scenario);
    }

    #[test]
    #[expected_failure(abort_code = test_scenario::EEmptyInventory)] 
    fun test_will_error_on_update_of_nft_attributes_by_other_user() {

        let url = b" ";
        let initial_owner = @0xCAFE;
        let final_owner = @0xFACE;

        let scenario = test_scenario::begin(initial_owner);
        {   
            test_scenario::sender(&scenario);

            trophy::test_init(test_scenario::ctx(&mut scenario));

        };

        let nft_object;
        test_scenario::next_tx(&mut scenario, initial_owner);
        {

            let nft_info = test_scenario::take_shared<trophy::NFTInfo>(&scenario);
            let royalty = nft::new_royalty(3, 3, 4);
            let nft_info_artfi = nft::new_nft_info(string::utf8(b"name"), royalty);
            let test_net_nft = nft::new_artfi_nft(
                string::utf8(b"name"),
                url::new_unsafe_from_bytes(b"url"), 
                1,
                &mut nft_info_artfi,
                &mut tx_context::dummy()
            );
            trophy::mint_nft(
                &mut nft_info,
                &test_net_nft,
                url,
                test_scenario::ctx(&mut scenario)
            );

            test_utils::destroy<nft::ArtfiNFT>(test_net_nft);
            test_utils::destroy<nft::NFTInfo>(nft_info_artfi);
            nft_object = test_scenario::take_from_sender<trophy::TrophyNFT>(&scenario);

            test_scenario::return_shared<trophy::NFTInfo>(nft_info);
            
        };

        test_scenario::next_tx(&mut scenario, final_owner);
        {
            let nft_info = test_scenario::take_shared<trophy::NFTInfo>(&scenario);
            let admin_cap = test_scenario::take_from_sender<trophy::AdminCap>(&scenario);

            trophy::update_attribute(&admin_cap, &mut nft_info, object::id(&nft_object), string::utf8(b""));

            test_scenario::return_shared<trophy::NFTInfo>(nft_info);
            test_utils::destroy<trophy::AdminCap>(admin_cap);
        };

        test_scenario::end(scenario);
        test_utils::destroy<trophy::TrophyNFT>(nft_object);
    }

    #[test]
    #[expected_failure(abort_code = trophy::EAlreadyExist)] 
    fun test_will_error_on_multiple_mint_from_same_fraction_id() {
        let url = b" ";
        let initial_owner = @0xCAFE;
        let final_owner = @0xFACE;

        let scenario = test_scenario::begin(initial_owner);
        {   
            test_scenario::sender(&scenario);

            trophy::test_init(test_scenario::ctx(&mut scenario));

        };

        test_scenario::next_tx(&mut scenario, final_owner);
        {
            let nft_info = test_scenario::take_shared<trophy::NFTInfo>(&scenario);
            let royalty = nft::new_royalty(3, 3, 4);
            let nft_info_artfi = nft::new_nft_info(string::utf8(b"name"), royalty);
            let test_net_nft = nft::new_artfi_nft(
                string::utf8(b"name"),
                url::new_unsafe_from_bytes(b"url"), 
                1,
                &mut nft_info_artfi,
                &mut tx_context::dummy()
            );
            trophy::mint_nft(
                &mut nft_info,
                &test_net_nft,
                url,
                test_scenario::ctx(&mut scenario)
            );

            test_utils::destroy<nft::ArtfiNFT>(test_net_nft);
            test_utils::destroy<nft::NFTInfo>(nft_info_artfi);
            test_scenario::return_shared(nft_info);
        };

        test_scenario::next_tx(&mut scenario, final_owner);
        {
            let nft_info = test_scenario::take_shared<trophy::NFTInfo>(&scenario);
            let royalty = nft::new_royalty(3, 3, 4);
            let nft_info_artfi = nft::new_nft_info(string::utf8(b"name"), royalty);
            let test_net_nft = nft::new_artfi_nft(
                string::utf8(b"name"),
                url::new_unsafe_from_bytes(b"url"), 
                1,
                &mut nft_info_artfi,
                &mut tx_context::dummy()
            );
            trophy::mint_nft(
                &mut nft_info,
                &test_net_nft,
                url,
                test_scenario::ctx(&mut scenario)
            );

            test_utils::destroy<nft::ArtfiNFT>(test_net_nft);
            test_utils::destroy<nft::NFTInfo>(nft_info_artfi);
            test_scenario::return_shared(nft_info);
        };

        test_scenario::end(scenario);
    }
}
