#[test_only]
module collection::nft_tests {
    // Test attribute is placed before the `fun` keyword. Can be both above or
    // right before the `fun` keyword: `#[test] fun my_test() { ... }`
    // The name of the test would be `book::testing::simple_test`.
    #[test_only]
    use collection::nft;
    use sui::url;
    use std::string;
    use sui::tx_context;
    use sui::object;

    #[test_only] use sui::test_utils;
    #[test_only] use sui::test_scenario;
    #[test_only] use sui::display;

    #[test]
    // test `name` function
    fun nft_name_test() {
        let name = b"Artfi";
        let description = b"Artfi_NFT";
        let nft_url = b"Artfi_NFT";
        let fraction_id = 12;
        let artfi_royalty = 4;
        let artist_royalty = 3;
        let staking_contract_royalty = 3;
        let royalty = nft::new_royalty(artfi_royalty, artist_royalty, staking_contract_royalty);
        let royalty_info = nft::new_royalty_info(royalty);
        let test_net_nft = nft::new_artfi_nft(
            string::utf8(name),
            string::utf8(description), 
            url::new_unsafe_from_bytes(nft_url), 
            fraction_id,
            &mut royalty_info,
            &mut tx_context::dummy()
        );

        assert!(nft::name(&test_net_nft) == &string::utf8(b"Artfi"), 1);

        let dummy_address = @0xCAFE;
        sui::transfer::public_transfer(test_net_nft, dummy_address);
        test_utils::destroy<nft::RoyaltyInfo>(royalty_info);
        
    }

    // test `description` function
    #[test]
    fun nft_description_test() {
        let name = b"Artfi";
        let description = b"Artfi_NFT";
        let nft_url = b"Artfi_NFT";
        let fraction_id = 12;
        let artfi_royalty = 4;
        let artist_royalty = 3;
        let staking_contract_royalty = 3;
        let royalty = nft::new_royalty(artfi_royalty, artist_royalty, staking_contract_royalty);
        let royalty_info = nft::new_royalty_info(royalty);
        let test_net_nft = nft::new_artfi_nft(
            string::utf8(name),
            string::utf8(description), 
            url::new_unsafe_from_bytes(nft_url), 
            fraction_id,
            &mut royalty_info,
            &mut tx_context::dummy()
        );
        assert!(nft::description(&test_net_nft) == &string::utf8(b"Artfi_NFT"), 1);

        let dummy_address = @0xCAFE;
        sui::transfer::public_transfer(test_net_nft, dummy_address);
        test_utils::destroy<nft::RoyaltyInfo>(royalty_info);
        
    }

    #[test]
    // test `url` function
    fun nft_url_test() {
        let name = b"Artfi";
        let description = b"Artfi_NFT";
        let nft_url = b" ";
        let fraction_id = 12;
        let artfi_royalty = 4;
        let artist_royalty = 3;
        let staking_contract_royalty = 3;
        let royalty = nft::new_royalty(artfi_royalty, artist_royalty, staking_contract_royalty);
        let royalty_info = nft::new_royalty_info(royalty); 
        let test_net_nft = nft::new_artfi_nft(
            string::utf8(name),
            string::utf8(description), 
            url::new_unsafe_from_bytes(nft_url), 
            fraction_id,
            &mut royalty_info,
            &mut tx_context::dummy()
        );
        assert!(nft::url(&test_net_nft) ==  &url::new_unsafe_from_bytes(nft_url), 1);

        test_utils::destroy<nft::ArtfiNFT>(test_net_nft);
        test_utils::destroy<nft::RoyaltyInfo>(royalty_info);
    }

    #[test]
    // test `url` function
    fun nft_royalty_test() {
        let name = b"Artfi";
        let description = b"Artfi_NFT";
        let nft_url = b" ";
        let fraction_id = 12;
        let artfi_royalty = 4;
        let artist_royalty = 3;
        let staking_contract_royalty = 3;
        let royalty = nft::new_royalty(artfi_royalty, artist_royalty, staking_contract_royalty);
        let royalty_info = nft::new_royalty_info(royalty); 
        let test_net_nft = nft::new_artfi_nft(
            string::utf8(name),
            string::utf8(description), 
            url::new_unsafe_from_bytes(nft_url), 
            fraction_id,
            &mut royalty_info,
            &mut tx_context::dummy()
        );
        let royalty_instance = nft::new_royalty(4, 3, 3); 
        assert!(nft::royalty(&test_net_nft, &royalty_info) == royalty_instance, 1);

        test_utils::destroy<nft::ArtfiNFT>(test_net_nft);
        test_utils::destroy<nft::Royalty>(royalty_instance);
        test_utils::destroy<nft::RoyaltyInfo>(royalty_info);
    }

    #[test]
    // test `url` function
    fun nft_artfi_royalty_test() {
        let name = b"Artfi";
        let description = b"Artfi_NFT";
        let nft_url = b" ";
        let fraction_id = 12;
        let artfi_royalty = 4;
        let artist_royalty = 3;
        let staking_contract_royalty = 3;
        let royalty = nft::new_royalty(artfi_royalty, artist_royalty, staking_contract_royalty);
        let royalty_info = nft::new_royalty_info(royalty); 
        let test_net_nft = nft::new_artfi_nft(
            string::utf8(name),
            string::utf8(description), 
            url::new_unsafe_from_bytes(nft_url), 
            fraction_id,
            &mut royalty_info,
            &mut tx_context::dummy()
        );
        assert!(nft::artfi_royalty(&test_net_nft, &royalty_info) ==  4, 1);

        test_utils::destroy<nft::ArtfiNFT>(test_net_nft);
        test_utils::destroy<nft::RoyaltyInfo>(royalty_info);
    }

    #[test]
    // test `url` function
    fun nft_artist_royalty_test() {
        let name = b"Artfi";
        let description = b"Artfi_NFT";
        let nft_url = b" ";
        let fraction_id = 12;
        let artfi_royalty = 4;
        let artist_royalty = 3;
        let staking_contract_royalty = 3;
        let royalty = nft::new_royalty(artfi_royalty, artist_royalty, staking_contract_royalty);
        let royalty_info = nft::new_royalty_info(royalty); 
        let test_net_nft = nft::new_artfi_nft(
            string::utf8(name),
            string::utf8(description), 
            url::new_unsafe_from_bytes(nft_url), 
            fraction_id,
            &mut royalty_info,
            &mut tx_context::dummy()
        );
        assert!(nft::artist_royalty(&test_net_nft, &royalty_info) ==  3, 1);

        test_utils::destroy<nft::ArtfiNFT>(test_net_nft);
        test_utils::destroy<nft::RoyaltyInfo>(royalty_info);
    }

    #[test]
    // test `url` function
    fun nft_staking_contract_royalty_test() {
        let name = b"Artfi";
        let description = b"Artfi_NFT";
        let nft_url = b" ";
        let fraction_id = 12;
        let artfi_royalty = 4;
        let artist_royalty = 3;
        let staking_contract_royalty = 3;
        let royalty = nft::new_royalty(artfi_royalty, artist_royalty, staking_contract_royalty);
        let royalti_info = nft::new_royalty_info(royalty);
        let test_net_nft = nft::new_artfi_nft(
            string::utf8(name),
            string::utf8(description), 
            url::new_unsafe_from_bytes(nft_url), 
            fraction_id,
            &mut royalti_info,
            &mut tx_context::dummy()
        );
        assert!(nft::staking_contract_royalty(&test_net_nft, &royalti_info) ==  3, 1);

        test_utils::destroy<nft::ArtfiNFT>(test_net_nft);
        test_utils::destroy<nft::RoyaltyInfo>(royalti_info);
    }

    #[test]
    fun test_module_init() {

        let initial_owner = @0xCAFE;
        let final_owner = @0xFACE;

        let scenario = test_scenario::begin(initial_owner);
        {   
            test_scenario::sender(&scenario);

            nft::test_init(test_scenario::ctx(&mut scenario));

        };

        test_scenario::next_tx(&mut scenario,initial_owner);
        {
            let admin_cap = test_scenario::take_from_sender<nft::AdminCap>(&scenario);

            nft::transfer_minter_cap(&admin_cap, final_owner, test_scenario::ctx(&mut scenario));

             test_utils::destroy<nft::AdminCap>(admin_cap);

        };

        test_scenario::end(scenario);
    }

    #[test]
    fun test_transfer_minter_cap() {

        let initial_owner = @0xCAFE;
        let final_owner = @0xFACE;

        let scenario = test_scenario::begin(initial_owner);
        {   
            test_scenario::sender(&scenario);

            nft::test_init(test_scenario::ctx(&mut scenario));

        };

        test_scenario::next_tx(&mut scenario,initial_owner);
        {
            let admin_cap = test_scenario::take_from_sender<nft::AdminCap>(&scenario);

            nft::transfer_minter_cap(&admin_cap, final_owner, test_scenario::ctx(&mut scenario));

             test_utils::destroy<nft::AdminCap>(admin_cap);

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

            nft::test_init(test_scenario::ctx(&mut scenario));

        };

        test_scenario::next_tx(&mut scenario,initial_owner);
        {
            let admin_cap = test_scenario::take_from_sender<nft::AdminCap>(&scenario);

            nft::transfer_admin_cap(admin_cap, final_owner);

        };

        test_scenario::end(scenario);
    }

    #[test]
    fun test_mint_nft() {

        let url = b" ";
        let fraction_id = 12;

        let initial_owner = @0xCAFE;
        let final_owner = @0xFACE;

        let scenario = test_scenario::begin(initial_owner);
        {   
            test_scenario::sender(&scenario);

            nft::test_init(test_scenario::ctx(&mut scenario));

        };

        test_scenario::next_tx(&mut scenario, initial_owner);
        {

            let minter_cap = test_scenario::take_from_sender<nft::MinterCap>(&scenario);
            let display_object = test_scenario::take_shared<display::Display<nft::ArtfiNFT>>(&scenario);
            let royalti_info = test_scenario::take_shared<nft::RoyaltyInfo>(&scenario);
            nft::mint_nft(
                &minter_cap, 
                &display_object,
                url, 
                final_owner, 
                fraction_id, 
                &mut royalti_info,
                test_scenario::ctx(&mut scenario)
            );

            test_utils::destroy<nft::MinterCap>(minter_cap);
            test_scenario::return_shared<display::Display<nft::ArtfiNFT>>(display_object);
            test_scenario::return_shared(royalti_info);
        };

        test_scenario::next_tx(&mut scenario,final_owner);
        {
            let nftToken = test_scenario::take_from_sender<nft::ArtfiNFT>(&scenario);

            assert!(nft::name(&nftToken) == &string::utf8(b"Artfi"), 1);
            assert!(nft::description(&nftToken) == &string::utf8(b"Artfi_NFT"), 1);
            assert!(nft::url(&nftToken) == &url::new_unsafe_from_bytes(url), 1);
            let royalty_instance = nft::new_royalty(4, 3, 3);

            let royalti_info = test_scenario::take_shared<nft::RoyaltyInfo>(&scenario);
            assert!(nft::royalty(&nftToken, &royalti_info) == royalty_instance, 1);

            test_utils::destroy<nft::ArtfiNFT>(nftToken);
            test_utils::destroy<nft::Royalty>(royalty_instance);
            test_scenario::return_shared<nft::RoyaltyInfo>(royalti_info);
            
        };

        test_scenario::end(scenario);
    }

    #[test]
    fun test_mint_batch_nft() {

        let url = vector[b" "];
        let fraction_id = vector[12];

        let initial_owner = @0xCAFE;
        let final_owner = @0xFACE;

        let scenario = test_scenario::begin(initial_owner);
        {   
            test_scenario::sender(&scenario);

            nft::test_init(test_scenario::ctx(&mut scenario));

        };

        test_scenario::next_tx(&mut scenario, initial_owner);
        {

            let minter_cap = test_scenario::take_from_sender<nft::MinterCap>(&scenario);
            let display_object = test_scenario::take_shared<display::Display<nft::ArtfiNFT>>(&scenario);
            let royalty_info = test_scenario::take_shared<nft::RoyaltyInfo>(&scenario);

            nft::mint_nft_batch(
                &minter_cap, 
                &display_object,
                &mut royalty_info,
                &url, 
                &vector[final_owner], 
                &fraction_id, 
                test_scenario::ctx(&mut scenario)
            );

            test_utils::destroy<nft::MinterCap>(minter_cap);
            test_scenario::return_shared<nft::RoyaltyInfo>(royalty_info);
            test_scenario::return_shared<display::Display<nft::ArtfiNFT>>(display_object);
        };

        test_scenario::next_tx(&mut scenario,final_owner);
        {
            let nftToken = test_scenario::take_from_sender<nft::ArtfiNFT>(&scenario);

            assert!(nft::name(&nftToken) == &string::utf8(b"Artfi"), 1);
            assert!(nft::description(&nftToken) == &string::utf8(b"Artfi_NFT"), 1);
            assert!(nft::url(&nftToken) == &url::new_unsafe_from_bytes(b" "), 1);

            let royalty_instance = nft::new_royalty(4, 3, 3);

            let royalty_info = test_scenario::take_shared<nft::RoyaltyInfo>(&scenario);
            assert!(nft::royalty(&nftToken, &royalty_info) == royalty_instance, 1);
            test_utils::destroy<nft::ArtfiNFT>(nftToken);
            test_utils::destroy<nft::Royalty>(royalty_instance);
            test_scenario::return_shared<nft::RoyaltyInfo>(royalty_info);
            
        };

        test_scenario::end(scenario);
    }

    #[test]
    fun test_transfer_nft() {

        let url = b" ";
        let fraction_id = 12;

        let initial_owner = @0xCAFE;
        let final_owner = @0xFACE;
        let user = @0xEAFF;

        let scenario = test_scenario::begin(initial_owner);
        {   
            test_scenario::sender(&scenario);

            nft::test_init(test_scenario::ctx(&mut scenario));

        };

        test_scenario::next_tx(&mut scenario, initial_owner);
        {

            let minter_cap = test_scenario::take_from_sender<nft::MinterCap>(&scenario);
            let display_object = test_scenario::take_shared<display::Display<nft::ArtfiNFT>>(&scenario);
            let royalty_info = test_scenario::take_shared<nft::RoyaltyInfo>(&scenario);

            nft::mint_nft(
                &minter_cap, 
                &display_object,
                url, 
                final_owner, 
                fraction_id, 
                &mut royalty_info,
                test_scenario::ctx(&mut scenario)
            );

            test_utils::destroy<nft::MinterCap>(minter_cap);
            test_scenario::return_shared<display::Display<nft::ArtfiNFT>>(display_object);
            test_scenario::return_shared<nft::RoyaltyInfo>(royalty_info);
        };

        test_scenario::next_tx(&mut scenario,final_owner);
        {
            let nftToken = test_scenario::take_from_sender<nft::ArtfiNFT>(&scenario);

            nft::transfer_nft(nftToken, user, test_scenario::ctx(&mut scenario));
            
        };

        test_scenario::next_tx(&mut scenario, user);
        {
            let nftToken = test_scenario::take_from_sender<nft::ArtfiNFT>(&scenario);

            assert!(nft::name(&nftToken) == &string::utf8(b"Artfi"), 1);
            assert!(nft::description(&nftToken) == &string::utf8(b"Artfi_NFT"), 1);
            assert!(nft::url(&nftToken) == &url::new_unsafe_from_bytes(url), 1);
            let royalty_instance = nft::new_royalty(4, 3, 3);

            let royalty_info = test_scenario::take_shared<nft::RoyaltyInfo>(&scenario);
            assert!(nft::royalty(&nftToken, &royalty_info) == royalty_instance, 1);

            test_utils::destroy<nft::ArtfiNFT>(nftToken);
            test_utils::destroy<nft::Royalty>(royalty_instance);
            test_scenario::return_shared<nft::RoyaltyInfo>(royalty_info);
        };

        test_scenario::end(scenario);
    }

    #[test]
    #[expected_failure(abort_code = test_scenario::EEmptyInventory)] 
    fun test_burn_nft() {
        let url = b" ";
        let fraction_id = 12;

        let initial_owner = @0xCAFE;
        let final_owner = @0xFACE;

        let scenario = test_scenario::begin(initial_owner);
        {   
            test_scenario::sender(&scenario);

            nft::test_init(test_scenario::ctx(&mut scenario));

        };

        test_scenario::next_tx(&mut scenario, initial_owner);
        {

            let minter_cap = test_scenario::take_from_sender<nft::MinterCap>(&scenario);
            let display_object = test_scenario::take_from_sender<display::Display<nft::ArtfiNFT>>(&scenario);
            let royalty_info = test_scenario::take_shared<nft::RoyaltyInfo>(&scenario);

            nft::mint_nft(
                &minter_cap, 
                &display_object,
                url, 
                final_owner, 
                fraction_id, 
                &mut royalty_info,
                test_scenario::ctx(&mut scenario)
            );

            test_utils::destroy<nft::MinterCap>(minter_cap);
            test_utils::destroy<display::Display<nft::ArtfiNFT>>(display_object);
            test_scenario::return_shared<nft::RoyaltyInfo>(royalty_info);
            
        };

        test_scenario::next_tx(&mut scenario,final_owner);
        let nftToken;
        {
            nftToken = test_scenario::take_from_sender<nft::ArtfiNFT>(&scenario);
        };

        test_scenario::next_tx(&mut scenario, initial_owner);
        {   
            let admin_cap = test_scenario::take_from_sender<nft::AdminCap>(&scenario);
            let royalty_info = test_scenario::take_shared<nft::RoyaltyInfo>(&scenario);

            nft::burn(nftToken, &mut royalty_info, test_scenario::ctx(&mut scenario));

            test_utils::destroy<nft::AdminCap>(admin_cap); 
            test_scenario::return_shared<nft::RoyaltyInfo>(royalty_info);
        };

        test_scenario::next_tx(&mut scenario, final_owner);
        {
            let nftToken = test_scenario::take_from_sender<nft::ArtfiNFT>(&scenario);

            test_utils::destroy<nft::ArtfiNFT>(nftToken);            
        };

        test_scenario::end(scenario);
    }

    #[test]
    fun test_update_royalty() {

        let initial_owner = @0xCAFE;
        let final_owner = @0xFACE;

        let scenario = test_scenario::begin(initial_owner);
        {   
            test_scenario::sender(&scenario);

            nft::test_init(test_scenario::ctx(&mut scenario));

        };

        test_scenario::next_tx(&mut scenario, initial_owner);
        {   
            let mintCap = test_scenario::take_from_sender<nft::MinterCap>(&scenario);
            let royalty_info = test_scenario::take_shared<nft::RoyaltyInfo>(&scenario);

            nft::update_royalty(&mintCap, &mut royalty_info, 5, 4 , 3, test_scenario::ctx(&mut scenario));

            test_utils::destroy<nft::MinterCap>(mintCap); 
            test_scenario::return_shared<nft::RoyaltyInfo>(royalty_info);
        };

        test_scenario::next_tx(&mut scenario, final_owner);
        {
            let royalty_info = test_scenario::take_shared<nft::RoyaltyInfo>(&scenario);
            let (artfi, artist, staking_contract) = nft::get_default_royalty_fields(&royalty_info);
            assert!(artfi == 5, 1);
            assert!(artist == 4, 1);
            assert!(staking_contract == 3, 1);

            test_scenario::return_shared<nft::RoyaltyInfo>(royalty_info);           
        };

        test_scenario::end(scenario);
    }

    #[test]
    fun test_update_nft_royalty() {

        let url = b" ";
        let fraction_id = 12;
        let initial_owner = @0xCAFE;
        let final_owner = @0xFACE;

        let scenario = test_scenario::begin(initial_owner);
        {   
            test_scenario::sender(&scenario);

            nft::test_init(test_scenario::ctx(&mut scenario));

        };

        test_scenario::next_tx(&mut scenario, initial_owner);
        {

            let minter_cap = test_scenario::take_from_sender<nft::MinterCap>(&scenario);
            let display_object = test_scenario::take_shared<display::Display<nft::ArtfiNFT>>(&scenario);
            let royalty_info = test_scenario::take_shared<nft::RoyaltyInfo>(&scenario);

            nft::mint_nft(
                &minter_cap, 
                &display_object,
                url, 
                final_owner, 
                fraction_id, 
                &mut royalty_info,
                test_scenario::ctx(&mut scenario)
            );

            test_scenario::return_to_sender<nft::MinterCap>(&scenario, minter_cap);
            test_scenario::return_shared<display::Display<nft::ArtfiNFT>>(display_object);
            test_scenario::return_shared<nft::RoyaltyInfo>(royalty_info);
            
        };

        let nft_id;
        test_scenario::next_tx(&mut scenario, final_owner);
        {   
            let nft_object = test_scenario::take_from_sender<nft::ArtfiNFT>(&scenario);
            nft_id = object::id(&nft_object);

            test_scenario::return_to_sender<nft::ArtfiNFT>(&scenario, nft_object);
        };

        test_scenario::next_tx(&mut scenario, initial_owner);
        {
            let mintCap = test_scenario::take_from_sender<nft::MinterCap>(&scenario);
            let royalty_info = test_scenario::take_shared<nft::RoyaltyInfo>(&scenario);

            nft::update_nft_royalty(&mintCap, &mut royalty_info, nft_id, 5, 4 , 3, test_scenario::ctx(&mut scenario));

            test_utils::destroy<nft::MinterCap>(mintCap); 
            test_scenario::return_shared<nft::RoyaltyInfo>(royalty_info);         
        };

        test_scenario::next_tx(&mut scenario, final_owner);
        {
            let royalty_info = test_scenario::take_shared<nft::RoyaltyInfo>(&scenario);
            let nft_object = test_scenario::take_from_sender<nft::ArtfiNFT>(&scenario);

            assert!(nft_id == object::id(&nft_object), 1);
            assert!(nft::artfi_royalty(&nft_object, &royalty_info) == 5, 1);
            assert!(nft::artist_royalty(&nft_object, &royalty_info) == 4, 1);
            assert!(nft::staking_contract_royalty(&nft_object, &royalty_info) == 3, 1);

            test_scenario::return_shared<nft::RoyaltyInfo>(royalty_info);  
            test_scenario::return_to_sender<nft::ArtfiNFT>(&scenario, nft_object);         
        };

        test_scenario::end(scenario);
    }

    #[test]
    #[expected_failure(abort_code = test_scenario::EEmptyInventory)] 
    fun test_will_error_on_transfer_minter_cap_by_other_address() {

        let initial_owner = @0xCAFE;
        let final_owner = @0xFACE;

        let scenario = test_scenario::begin(initial_owner);
        {   
            test_scenario::sender(&scenario);

            nft::test_init(test_scenario::ctx(&mut scenario));

        };

        test_scenario::next_tx(&mut scenario, final_owner);
        {
            let admin_cap = test_scenario::take_from_sender<nft::AdminCap>(&scenario);

            nft::transfer_minter_cap(&admin_cap, final_owner, test_scenario::ctx(&mut scenario));

            test_utils::destroy<nft::AdminCap>(admin_cap);
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

            nft::test_init(test_scenario::ctx(&mut scenario));

        };

        test_scenario::next_tx(&mut scenario, final_owner);
        {
            let admin_cap = test_scenario::take_from_sender<nft::AdminCap>(&scenario);

            nft::transfer_admin_cap(admin_cap, final_owner);

        };
        
        test_scenario::end(scenario);
    }

    #[test]
    #[expected_failure(abort_code = test_scenario::EEmptyInventory)]
    fun test_will_error_on_transfer_nft_by_other_address() {

        let url = b" ";
        let fraction_id = 12;

        let initial_owner = @0xCAFE;
        let final_owner = @0xFACE;
        let user = @0xEAFF;

        let scenario = test_scenario::begin(initial_owner);
        {   
            test_scenario::sender(&scenario);

            nft::test_init(test_scenario::ctx(&mut scenario));

        };

        test_scenario::next_tx(&mut scenario, initial_owner);
        {

            let minter_cap = test_scenario::take_from_sender<nft::MinterCap>(&scenario);
            let display_object = test_scenario::take_from_sender<display::Display<nft::ArtfiNFT>>(&scenario);
            let royalty_object = test_scenario::take_shared<nft::RoyaltyInfo>(&scenario);

            nft::mint_nft(
                &minter_cap, 
                &display_object,
                url, 
                final_owner, 
                fraction_id, 
                &mut royalty_object,
                test_scenario::ctx(&mut scenario)
            );

            test_utils::destroy<nft::MinterCap>(minter_cap);
            test_utils::destroy<display::Display<nft::ArtfiNFT>>(display_object);
            test_scenario::return_shared<nft::RoyaltyInfo>(royalty_object);
        };

        test_scenario::next_tx(&mut scenario, initial_owner);
        {
            let nftToken = test_scenario::take_from_sender<nft::ArtfiNFT>(&scenario);

            nft::transfer_nft(nftToken, user, test_scenario::ctx(&mut scenario));
            
        };

        test_scenario::end(scenario);
    }

    #[test]
    #[expected_failure(abort_code = collection::nft::ELengthNotEqual)] 
    fun test_will_error_on_batch_mint_for_unequal_length_vector() {

        let url = vector[b" ", b"Artfi_NFT"];
        let fraction_id = vector[12];

        let initial_owner = @0xCAFE;
        let final_owner = @0xFACE;

        let scenario = test_scenario::begin(initial_owner);
        {   
            test_scenario::sender(&scenario);

            nft::test_init(test_scenario::ctx(&mut scenario));

        };

        test_scenario::next_tx(&mut scenario, initial_owner);
        {

            let minter_cap = test_scenario::take_from_sender<nft::MinterCap>(&scenario);
            let display_object = test_scenario::take_shared<display::Display<nft::ArtfiNFT>>(&scenario);
            let royalty_object = test_scenario::take_shared<nft::RoyaltyInfo>(&scenario);

            nft::mint_nft_batch(
                &minter_cap, 
                &display_object,
                &mut royalty_object,
                &url, 
                &vector[final_owner], 
                &fraction_id, 
                test_scenario::ctx(&mut scenario)
            );

            test_utils::destroy<nft::MinterCap>(minter_cap);
            test_scenario::return_shared<display::Display<nft::ArtfiNFT>>(display_object);
            test_scenario::return_shared<nft::RoyaltyInfo>(royalty_object);
        };

        test_scenario::end(scenario);
    }

    #[test]
    #[expected_failure(abort_code = test_scenario::EEmptyInventory)] 
    fun test_will_error_on_update_of_royalty_by_other_user() {

        let initial_owner = @0xCAFE;
        let final_owner = @0xFACE;

        let scenario = test_scenario::begin(initial_owner);
        {   
            test_scenario::sender(&scenario);

            nft::test_init(test_scenario::ctx(&mut scenario));

        };

        test_scenario::next_tx(&mut scenario, final_owner);
        {
            let royalty_info = test_scenario::take_shared<nft::RoyaltyInfo>(&scenario);
            let minter_cap = test_scenario::take_from_sender<nft::MinterCap>(&scenario);

            nft::update_royalty(&minter_cap, &mut royalty_info, 4 , 3, 3, test_scenario::ctx(&mut scenario));

            test_scenario::return_shared<nft::RoyaltyInfo>(royalty_info);
            test_utils::destroy<nft::MinterCap>(minter_cap);
        };

        test_scenario::end(scenario);
    }

    #[test]
    #[expected_failure(abort_code = test_scenario::EEmptyInventory)] 
    fun test_will_error_on_update_of_nft_royalty_by_other_user() {

        let url = b" ";
        let fraction_id = 12;

        let initial_owner = @0xCAFE;
        let final_owner = @0xFACE;

        let scenario = test_scenario::begin(initial_owner);
        {   
            test_scenario::sender(&scenario);

            nft::test_init(test_scenario::ctx(&mut scenario));

        };

        let nft_object;

        test_scenario::next_tx(&mut scenario, initial_owner);
        {

            let minter_cap = test_scenario::take_from_sender<nft::MinterCap>(&scenario);
            let display_object = test_scenario::take_from_sender<display::Display<nft::ArtfiNFT>>(&scenario);
            let royalty_info = test_scenario::take_shared<nft::RoyaltyInfo>(&scenario);

            nft::mint_nft(
                &minter_cap, 
                &display_object,
                url, 
                final_owner, 
                fraction_id, 
                &mut royalty_info,
                test_scenario::ctx(&mut scenario)
            );

            nft_object = test_scenario::take_from_sender<nft::ArtfiNFT>(&scenario);

            test_utils::destroy<nft::MinterCap>(minter_cap);
            test_utils::destroy<display::Display<nft::ArtfiNFT>>(display_object);
            test_scenario::return_shared<nft::RoyaltyInfo>(royalty_info);
            
        };

        test_scenario::next_tx(&mut scenario, final_owner);
        {
            let royalty_info = test_scenario::take_shared<nft::RoyaltyInfo>(&scenario);
            let minter_cap = test_scenario::take_from_sender<nft::MinterCap>(&scenario);

            nft::update_nft_royalty(&minter_cap, &mut royalty_info, object::id(&nft_object), 4, 3, 3, test_scenario::ctx(&mut scenario));

            test_scenario::return_shared<nft::RoyaltyInfo>(royalty_info);
            test_utils::destroy<nft::MinterCap>(minter_cap);
        };

        test_scenario::end(scenario);
        test_utils::destroy<nft::ArtfiNFT>(nft_object);
    }
        
}
